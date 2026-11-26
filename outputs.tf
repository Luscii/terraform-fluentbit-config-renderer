output "classic_config" {
  value       = local.classic_config
  description = "Rendered Fluent Bit main configuration in classic INI-style format (SERVICE, INPUT, FILTER, OUTPUT sections)."
}

output "classic_parsers_config" {
  value       = local.classic_parsers_config
  description = "Rendered Fluent Bit parsers configuration in classic INI-style format (PARSER, MULTILINE_PARSER sections). Must be saved as a separate file referenced by parsers_file in the SERVICE section."
}

output "yaml_config" {
  value       = local.yaml_config
  description = "Rendered Fluent Bit configuration in YAML format (all sections in one file)."
}
