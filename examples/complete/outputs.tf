output "label_context" {
  value       = module.example.label_context
  description = "Label context from the module"
}

output "label_id" {
  value       = module.example.label_context.id
  description = "Generated label ID"
}

output "label_tags" {
  value       = module.example.label_context.tags
  description = "Generated tags"
}
