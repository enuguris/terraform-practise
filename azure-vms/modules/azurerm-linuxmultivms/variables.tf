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

/*
variable "host_name" {
  type        = string
  description = "HostName"
}

variable "private_ip_addr_allocation" {
  type        = string
  description = "Can be of type Static/Dynamic"
}

variable "public_ip_addr_allocation" {
  type        = string
  description = "Can be of type Static/Dynamic"
}

variable "private_ipaddress" {
  type        = string
  description = "Private IP Address"
}

variable "ip_addr_version" {
  type        = string
  description = "IPv4 or IPv6"
  default     = "IPv4"
}
*/

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
  type = map(object({
    host_name                  = string
    private_ip_addr_allocation = string
    public_ip_addr_allocation  = string
    private_ipaddress          = string
    ip_addr_version            = string
  }))
  description = "cluster values"
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

