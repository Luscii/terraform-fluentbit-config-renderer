output "classic_config" {
  value       = module.example.classic_config
  description = "Rendered classic config"
}

output "yaml_config" {
  value       = module.example.yaml_config
  description = "Rendered YAML config"
}
