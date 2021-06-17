output "proximity_placement_group_id" {
  value = element(concat(data.azurerm_proximity_placement_group.ppg.*.id, [""]), 0)
}

output "availability_set_id" {
  value = element(concat(data.azurerm_availability_set.avset.*.id, [""]), 0)
}
