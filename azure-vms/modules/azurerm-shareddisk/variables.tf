variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
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

variable "tags" {
  type        = map
  description = "Tags"
}
