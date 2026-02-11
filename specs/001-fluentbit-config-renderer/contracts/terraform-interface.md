# Terraform Interface Contract

## Input Variables

### context (required)

CloudPosse label context. Standard across all Luscii modules.

```hcl
variable "context" {
  type    = any
  default = { ... }  # Standard CloudPosse defaults
}
```

### name (required)

```hcl
variable "name" {
  type        = string
  description = "Name of the resource to be labeled."
}
```

### service (optional)

```hcl
variable "service" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "SERVICE section. At most one entry."

  validation {
    condition     = length(var.service) <= 1
    error_message = "At most one SERVICE section is allowed."
  }
}
```

### inputs (optional)

```hcl
variable "inputs" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of INPUT sections."
}
```

### filters (optional)

```hcl
variable "filters" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of FILTER sections."
}
```

### outputs_ (optional)

Note: Named `outputs_` with trailing underscore to avoid collision
with Terraform reserved word `outputs`.

```hcl
variable "outputs_" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of OUTPUT sections."
}
```

### parsers (optional)

```hcl
variable "parsers" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of PARSER sections."
}
```

### multiline_parsers (optional)

```hcl
variable "multiline_parsers" {
  type = list(object({
    properties = list(list(string))
  }))
  default     = []
  description = "List of MULTILINE_PARSER sections."
}
```

## Output Values

### classic_config

```hcl
output "classic_config" {
  value       = local.classic_config
  description = "Rendered Fluent Bit configuration in classic INI-style format."
}
```

### yaml_config

```hcl
output "yaml_config" {
  value       = local.yaml_config
  description = "Rendered Fluent Bit configuration in YAML format."
}
```

### label_context

```hcl
output "label_context" {
  value       = module.label.context
  description = "Context of the label for subsequent use."
}
```
