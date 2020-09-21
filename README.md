## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| yandex | ~> 0.43.0 |

## Providers

| Name | Version |
|------|---------|
| yandex | ~> 0.43.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_upgrade | Boolean flag that specifies if master can be upgraded automatically. <br>When omitted, default value is TRUE." | `bool` | `true` | no |
| cluster\_ipv4\_range | CIDR block. IP range for allocating pod addresses. It should not overlap with<br>any subnet in the network the Kubernetes cluster located in. Static routes will<br>be set up for this CIDR blocks in node subnets. | `string` | `null` | no |
| description | A description of the Kubernetes cluster. | `string` | `null` | no |
| folder\_id | The ID of the folder that the Kubernetes cluster belongs to. <br>If it is not provided, the default provider folder is used. | `string` | n/a | yes |
| kms\_provider\_key\_id | KMS key ID. | `any` | `null` | no |
| labels | A set of key/value label pairs to assign to the Kubernetes cluster. | `map(string)` | `{}` | no |
| maintenance\_window | This structure specifies maintenance window, when update for master is allowed. <br>When omitted, it defaults to any time. To specify time of day interval, for all days, <br>one element should be provided, with two fields set, start\_time and duration. | `list(object({}))` | `[]` | no |
| master\_locations | List of locations where cluster will be created. If list contains only one<br>location, will be created zonal cluster, if more than one -- regional. | <pre>list(object({<br>    zone      = string<br>    subnet_id = string<br>  }))</pre> | n/a | yes |
| master\_public\_ip | Boolean flag. When true, Kubernetes master will have visible ipv4 address. | `bool` | `true` | no |
| master\_region | Name of availability region (e.g. "ru-central1"), where master instances will <br>be allocated. | `string` | `"ru-central1"` | no |
| master\_version | Version of Kubernetes that will be used for master. | `string` | `null` | no |
| name | Name of a specific Kubernetes cluster. | `string` | `null` | no |
| network\_id | The ID of the cluster network. | `string` | n/a | yes |
| network\_policy\_provider | Network policy provider for the cluster. Possible values: CALICO. | `string` | `"CALICO"` | no |
| node\_ipv4\_cidr\_mask\_size | Size of the masks that are assigned to each node in the cluster. <br>Effectively limits maximum number of pods for each node. | `string` | `null` | no |
| node\_service\_account\_id | Service account to be used by the worker nodes of the Kubernetes cluster <br>to access Container Registry or to push node logs and metrics. | `string` | `null` | no |
| release\_channel | Cluster release channel. Possible values: RAPID, REGULAR, STABLE. | `string` | `"REGULAR"` | no |
| service\_account\_id | Service account to be used for provisioning Compute Cloud and VPC resources <br>for Kubernetes cluster. Selected service account should have edit role on <br>the folder where the Kubernetes cluster will be located and on the folder <br>where selected network resides. | `string` | `null` | no |
| service\_ipv4\_range | CIDR block. IP range Kubernetes service Kubernetes cluster IP addresses<br>will be allocated from. It should not overlap with any subnet in the network<br>the Kubernetes cluster located in. | `string` | `null` | no |

## Outputs

No output.
