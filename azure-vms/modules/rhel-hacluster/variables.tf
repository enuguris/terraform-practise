variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "nsg_name" {
  type        = string
  description = "Network Security Group"
}

variable "vnet_name" {
  type        = string
  description = "Virtual Network"
}

variable "snet_name" {
  type        = string
  description = "Subnet"
}

variable "vm_size" {
  type        = string
  description = "VM Size"
  default     = "Standard_A2_V2"
}

variable "admin_username" {
  type        = string
  description = "SSH Admin Username"
  default     = "vmimport"
}

variable "ssh_pubkey_path" {
  type        = string
  description = "SSH PublicKey Path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "publisher" {
  type        = string
  description = "Publisher"
  default     = "RedHat"
}

variable "offer" {
  type        = string
  description = "Offered by"
  default     = "RHEL"
}


variable "sku" {
  type        = string
  description = "SKU"
  default     = "8_4"
}

variable "os_version" {
  type        = string
  description = "OS Version"
  default     = "latest"
}

variable "license_type" {
  type        = string
  description = "Licence Type"
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
  type        = string
  description = "Disk Cache Type"
  default     = "ReadWrite"
}

variable "storage_account_type" {
  type        = string
  description = "Storage Account Type"
  default     = "Standard_LRS"
}

variable "tags" {
  description = "Tags"
  type        = map(any)
}

variable "enable_avset" {
  type        = bool
  description = "Create Availibility Set - true/false"
  default     = false
}

variable "enable_ppg" {
  type        = bool
  description = "Create Proximity Placement Group - true/false"
  default     = false
}

variable "availability_set" {
  type        = string
  description = "Availability Set Name"
  default     = ""
}

variable "proximity_placement_group" {
  type        = string
  description = "Proximity Placement Group Name"
  default     = ""
}

variable "cluster" {
  description = "cluster values"
  type = map(object({
    host_name                  = string
    private_ip_addr_allocation = string
    private_ipaddress          = string
  }))
}

variable "create_shareddisk" {
  type        = bool
  default     = false
  description = "Create Shared Disk"
}

variable "shared_disk_name" {
  type        = string
  description = "Shared Disk Name"
}

variable "shared_disk_size_gb" {
  type        = number
  description = "Disk Size in GB"

  validation {
    condition     = var.shared_disk_size_gb >= 256
    error_message = "Shared disk size cannot be less then less than 256 GB."
  }
}

variable "max_shares" {
  type        = number
  description = "Max Shares"
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
