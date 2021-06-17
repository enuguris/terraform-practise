variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "enable_ppg" {
  type        = bool
  description = "Enable Proximity Placement Group. Accepts true/false"
  default     = false
}

variable "proximity_placement_group" {
  type        = string
  description = "Proximity Placement Group Name"
}

variable "enable_avset" {
  type        = bool
  description = "Enable Availability Set"
  default     = false
}

variable "availability_set" {
  type        = string
  description = "Availability Set Name"
}

variable "tags" {
  type        = map(any)
  description = "Tags"
}
