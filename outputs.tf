output "classic_config" {
  value       = local.classic_config
  description = "Rendered Fluent Bit configuration in classic INI-style format."
}

output "yaml_config" {
  value       = local.yaml_config
  description = "Rendered Fluent Bit configuration in YAML format."
}
