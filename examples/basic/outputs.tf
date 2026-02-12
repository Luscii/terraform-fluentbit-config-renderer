output "classic_config" {
  value       = module.example.classic_config
  description = "Rendered classic config (pipeline sections)"
}

output "classic_parsers_config" {
  value       = module.example.classic_parsers_config
  description = "Rendered classic parsers config (PARSER/MULTILINE_PARSER sections)"
}

output "yaml_config" {
  value       = module.example.yaml_config
  description = "Rendered YAML config (all sections)"
}
