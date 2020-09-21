variable "name" {
  description = "Name of a specific Kubernetes cluster."

  type = string

  default = null
}

variable "description" {
  description = "A description of the Kubernetes cluster."

  type = string

  default = null
}

variable "folder_id" {
  description = <<-EOF
  The ID of the folder that the Kubernetes cluster belongs to. 
  If it is not provided, the default provider folder is used.
  EOF

  type = string
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the Kubernetes cluster."

  type = map(string)

  default = {}
}

variable "network_id" {
  description = "The ID of the cluster network."

  type = string
}

variable "cluster_ipv4_range" {
  description = <<-EOF
  CIDR block. IP range for allocating pod addresses. It should not overlap with
  any subnet in the network the Kubernetes cluster located in. Static routes will
  be set up for this CIDR blocks in node subnets.
  EOF

  type = string

  default = null
}

variable "node_ipv4_cidr_mask_size" {
  description = <<-EOF
  Size of the masks that are assigned to each node in the cluster. 
  Effectively limits maximum number of pods for each node.
  EOF

  type = string

  default = null
}

variable "service_ipv4_range" {
  description = <<-EOF
  CIDR block. IP range Kubernetes service Kubernetes cluster IP addresses
  will be allocated from. It should not overlap with any subnet in the network
  the Kubernetes cluster located in.
  EOF

  type = string

  default = null
}

variable "service_account_id" {
  description = <<-EOF
  Service account to be used for provisioning Compute Cloud and VPC resources 
  for Kubernetes cluster. Selected service account should have edit role on 
  the folder where the Kubernetes cluster will be located and on the folder 
  where selected network resides.
  EOF

  type    = string
  default = null
}

variable "node_service_account_id" {
  description = <<-EOF
  Service account to be used by the worker nodes of the Kubernetes cluster 
  to access Container Registry or to push node logs and metrics.
  EOF

  type = string

  default = null
}

variable "release_channel" {
  description = "Cluster release channel. Possible values: RAPID, REGULAR, STABLE."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Possible values: RAPID, REGULAR, STABLE."
  }
}

variable "network_policy_provider" {
  description = "Network policy provider for the cluster. Possible values: CALICO."
  type        = string
  default     = "CALICO"

  validation {
    condition     = contains(["CALICO"], var.network_policy_provider)
    error_message = "Possible values: CALICO."
  }
}

variable "kms_provider_key_id" {
  description = "KMS key ID."

  default = null
}

variable "master_version" {
  description = "Version of Kubernetes that will be used for master."

  type = string

  default = null
}

variable "master_public_ip" {
  description = "Boolean flag. When true, Kubernetes master will have visible ipv4 address."

  type = bool

  default = true
}

variable "master_region" {
  description = <<-EOF
  Name of availability region (e.g. "ru-central1"), where master instances will 
  be allocated.
  EOF

  type    = string
  default = "ru-central1"

  validation {
    condition     = contains(["ru-central1"], var.master_region)
    error_message = "Possible values: ru-central1."
  }
}

variable "master_locations" {
  description = <<-EOF
  List of locations where cluster will be created. If list contains only one
  location, will be created zonal cluster, if more than one -- regional.
  EOF

  type = list(object({
    zone      = string
    subnet_id = string
  }))
}

variable "auto_upgrade" {
  description = <<-EOF
  Boolean flag that specifies if master can be upgraded automatically. 
  When omitted, default value is TRUE."
  EOF

  type = bool

  default = true
}

variable "maintenance_window" {
  description = <<-EOF
  This structure specifies maintenance window, when update for master is allowed. 
  When omitted, it defaults to any time. To specify time of day interval, for all days, 
  one element should be provided, with two fields set, start_time and duration.
  EOF

  type = list(object({}))

  default = []
}