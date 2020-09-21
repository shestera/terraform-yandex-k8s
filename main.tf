locals {
  master_regional = length(var.master_locations) > 1 ? [{
    region    = var.master_region
    locations = var.master_locations
  }] : []

  master_zonal = length(var.master_locations) > 1 ? [] : var.master_locations

  maintenance_policy = length(var.maintenance_window) > 1 ? [{
    auto_upgrade       = var.auto_upgrade
    maintenance_window = var.maintenance_window
  }] : []
}

resource "yandex_iam_service_account" "this_sa" {
  count = var.service_account_id == null ? 1 : 0

  name        = "k8s-sa-${var.name}"
  description = "Service account for K8s cluster ${var.name}"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_binding" "this_sa" {
  count = var.service_account_id == null ? 1 : 0

  folder_id = var.folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.this_sa[0].id}"]

  depends_on = [
    yandex_iam_service_account.this_sa,
  ]
}

resource "yandex_iam_service_account" "this_node_sa" {
  count = var.node_service_account_id == null ? 1 : 0

  name        = "k8s-node-sa-${var.name}"
  description = "Service account for K8s cluster ${var.name}"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_binding" "this_node_sa" {
  count = var.node_service_account_id == null ? 1 : 0

  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members   = ["serviceAccount:${yandex_iam_service_account.this_node_sa[0].id}"]

  depends_on = [
    yandex_iam_service_account.this_node_sa,
  ]
}

resource "yandex_kubernetes_cluster" "this" {
  name                     = var.name
  description              = var.description
  folder_id                = var.folder_id
  network_id               = var.network_id
  cluster_ipv4_range       = var.cluster_ipv4_range
  node_ipv4_cidr_mask_size = var.node_ipv4_cidr_mask_size
  service_ipv4_range       = var.service_ipv4_range
  service_account_id       = var.service_account_id == null ? yandex_iam_service_account.this_sa[0].id : var.service_account_id
  node_service_account_id  = var.node_service_account_id == null ? yandex_iam_service_account.this_node_sa[0].id : var.node_service_account_id
  release_channel          = var.release_channel
  network_policy_provider  = var.network_policy_provider

  labels = var.labels

  master {
    version   = var.master_version
    public_ip = var.master_public_ip

    dynamic "zonal" {
      for_each = local.master_zonal

      content {
        zone      = zonal.value["zone"]
        subnet_id = zonal.value["subnet_id"]
      }
    }

    dynamic "regional" {
      for_each = local.master_regional

      content {
        region = regional.value["region"]

        dynamic "location" {
          for_each = regional.value["locations"]

          content {
            zone      = location.value["zone"]
            subnet_id = location.value["subnet_id"]
          }
        }
      }
    }

    dynamic "maintenance_policy" {
      for_each = local.maintenance_policy

      content {
        auto_upgrade = maintenance_policy.value["auto_upgrade"]

        dynamic "maintenance_window" {
          for_each = maintenance_policy.value["maintenance_window"]

          content {
            day        = lookup(maintenance_window.value, "day", null)
            start_time = maintenance_window.value["start_time"]
            duration   = maintenance_window.value["duration"]
          }
        }
      }
    }
  }

  dynamic "kms_provider" {
    for_each = var.kms_provider_key_id == null ? [] : [var.kms_provider_key_id]

    content {
      key_id = kms_provider.value
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.this_sa,
    yandex_resourcemanager_folder_iam_binding.this_node_sa
  ]
}

resource "yandex_kubernetes_node_group" "this" {
  for_each = var.node_groups

  cluster_id  = yandex_kubernetes_cluster.this.id
  name        = each.key
  description = lookup(each.value, "description", null)
  labels      = var.labels
  version     = var.master_version

  node_labels            = lookup(each.value, "node_labels", null)
  node_taints            = lookup(each.value, "node_taints", null)
  allowed_unsafe_sysctls = lookup(each.value, "allowed_unsafe_sysctls", null)

  instance_template {
    platform_id = lookup(each.value, "platform_id", null)
    nat         = lookup(each.value, "nat", null)
    # metadata    = merge(local.common_ssh_keys_metadata, lookup(each.value, "metadata", {}))

    resources {
      cores         = lookup(each.value, "cores", 2)
      core_fraction = lookup(each.value, "core_fraction", 100)
      memory        = lookup(each.value, "memory", 2)
    }

    boot_disk {
      type = lookup(each.value, "boot_disk_type", "network-hdd")
      size = lookup(each.value, "boot_disk_size", 64)
    }

    scheduling_policy {
      preemptible = lookup(each.value, "preemptible", false)
    }
  }

  scale_policy {
    dynamic "fixed_scale" {
      for_each = flatten([lookup(each.value, "fixed_scale", can(each.value["auto_scale"]) ? [] : [{ size = 1 }])])

      content {
        size = fixed_scale.value.size
      }
    }

    dynamic "auto_scale" {
      for_each = flatten([lookup(each.value, "auto_scale", [])])

      content {
        min     = auto_scale.value.min
        max     = auto_scale.value.max
        initial = auto_scale.value.initial
      }
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = var.master_locations

      content {
        zone      = location.value["zone"]
        subnet_id = location.value["subnet_id"]
      }
    }
  }

  # dynamic "maintenance_policy" {
  #   for_each = flatten([lookup(each.value, "maintenance_policy", [])])
  # }

  # deploy_policy {
  #   max_expansion  = 
  #   max_unavailable = 
  # }

  depends_on = [
    yandex_kubernetes_cluster.this
  ]
}