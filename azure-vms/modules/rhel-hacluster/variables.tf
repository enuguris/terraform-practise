variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

/*
variable "nsg_name" {
  description = "Network Security Group"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}

variable "snet_name" {
  description = "Subnet Name"
  type        = string
}
*/

variable "bootdiag_storage_account" {
  description = "Storage Account to store boot diagnostic"
  type        = string
}

variable "vm_size" {
  description = "VM Size"
  type        = string
  default     = "Standard_A2_V2"
}

variable "admin_username" {
  description = "SSH Admin Username"
  type        = string
  default     = "vmimport"
}

variable "ssh_pubkey_path" {
  description = "SSH PublicKey Path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "publisher" {
  description = "Publisher Name"
  type        = string
  default     = "RedHat"
}

variable "offer" {
  description = "Offered by"
  type        = string
  default     = "RHEL"
}


variable "sku" {
  description = "SKU"
  type        = string
  default     = "8_4"
}

variable "os_version" {
  description = "OS Version"
  type        = string
  default     = "latest"
}

variable "license_type" {
  description = "Licence Type"
  type        = string
  default     = "RHEL_BYOS"
}

variable "plan" {
  description = "Subscription Plan details"
  type        = map(any)
  default = {
    name      = "8_4"
    publisher = "RedHat"
    product   = "RHEL"
  }
}

variable "caching" {
  description = "Disk Cache Type"
  type        = string
  default     = "ReadWrite"
}

variable "storage_account_type" {
  description = "Storage Account Type"
  type        = string
  default     = "Standard_LRS"
}

variable "tags" {
  description = "Tags"
  type        = map(any)
}

variable "enable_avset" {
  description = "Create Availibility Set - true/false"
  type        = bool
  default     = false
}

variable "enable_ppg" {
  description = "Create Proximity Placement Group - true/false"
  type        = bool
  default     = false
}

variable "availability_set" {
  description = "Availability Set Name"
  type        = string
  default     = ""
}

variable "proximity_placement_group" {
  description = "Proximity Placement Group Name"
  type        = string
  default     = ""
}

variable "cluster" {
  description = "Map of cluster nodes"
  type = map(object({
    host_name                  = string
    private_ip_addr_allocation = string
    private_ipaddress          = string
  }))
}

variable "create_shareddisk" {
  description = "Create Shared Disk"
  type        = bool
  default     = false
}

variable "shared_disk_name" {
  description = "Shared Disk Name"
  type        = string
}

variable "shared_disk_size_gb" {
  description = "Disk Size in GB"
  type        = number

  validation {
    condition     = var.shared_disk_size_gb >= 256
    error_message = "Shared disk size cannot be less then less than 256 GB."
  }
}

variable "max_shares" {
  description = "Max Shares"
  type        = number
  default     = 2
}



variable "lb_type" {
  description = "Defined if the loadbalancer is private or public"
  type        = string
  default     = "private"
}

variable "frontend_name" {
  description = "Specifies the name of the frontend ip configuration."
  type        = string
}

variable "frontend_private_ip_address" {
  description = "(Optional) Private ip address to assign to frontend. Use it with type = private"
  type        = string
  default     = ""
}

variable "frontend_private_ip_address_allocation" {
  description = "Frontend ip allocation type (Static or Dynamic)"
  type        = string
}

variable "backend_address_pool_name" {
  description = "Backend Address Pool Name"
  type        = string
}

variable "lb_sku" {
  description = "The SKU of the Azure Load Balancer. Accepted values are Basic and Standard."
  type        = string
  default     = "Basic"
}

variable "lb_port" {
  description = "Protocols to be used for lb rules. Format as [frontend_port, protocol, backend_port]"
  type        = map(any)
  default     = {}
}

variable "lb_probe" {
  description = "Protocols to be used for lb health probes. Format as [protocol, port, request_path]"
  type        = map(any)
  default     = {}
}

variable "lb_probe_interval" {
  description = "Probe Interval. Default is 15, minimum is 5."
  type        = number
  default     = 15
}

variable "lb_probe_unhealthy_threshold" {
  description = "Failed probe attempts. Default value is 2."
  type        = number
  default     = 2
}

variable "lb_name" {
  description = "Name of the load balancer."
  type        = string
}

variable "enable_floating_ip" {
  description = "Enable floating ip. Default is false."
  type        = bool
  default     = false
}

variable "idle_timeout_in_minutes" {
  description = "TCP connections idle timeout in mins. Valid values between 4 and 30 minutes. Defaults to 4 mins"
  type        = number
  default     = 4
}

variable "data_disks" {
  description = "List of managed data disk values as key/values"
  type = list(object({
    host_name            = string
    disk_name            = string
    storage_account_type = string
    create_option        = string
    caching              = string
    disk_size_gb         = number
    lun_id               = number
  }))
  default = []
}
