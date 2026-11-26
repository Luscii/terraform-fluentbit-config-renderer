# Terraform Interface Contract

## Input Variables

### service (optional)

Global Fluent Bit engine settings. At most one entry.

```hcl
variable "service" {
  type = optional(object({
    flush        = optional(string, "1")
    grace        = optional(number, 5)
    log_level    = optional(string, "info")
    log_file     = optional(string)
    http_server  = optional(string)
    http_listen  = optional(string, "0.0.0.0")
    http_port    = optional(number, 2020)
    parsers_file = optional(string)
    storage_path = optional(string)
    extra_properties = optional(map(string), {})
  }))
  default     = null
  description = <<-EOT
    Fluent Bit SERVICE section. Controls global engine behavior.
    At most one SERVICE section is allowed per configuration.
    Use extra_properties for less common settings like daemon,
    dns.mode, scheduler.*, storage.sync, etc.
  EOT

  validation {
    condition = var.service == null ? true : contains(
      ["off", "error", "warn", "info", "debug", "trace"],
      var.service.log_level
    )
    error_message = "log_level must be one of: off, error, warn, info, debug, trace."
  }
}
```

### inputs (optional)

```hcl
variable "inputs" {
  type = list(object({
    name             = string
    tag              = optional(string)
    alias            = optional(string)
    log_level        = optional(string)
    mem_buf_limit    = optional(string)
    storage_type     = optional(string)
    routable         = optional(bool)
    threaded         = optional(bool)
    extra_properties = optional(map(string), {})
  }))
  default     = []
  description = <<-EOT
    List of Fluent Bit INPUT sections. Each entry defines a data
    source (e.g., tail, forward, syslog). The name attribute
    specifies the plugin. Use extra_properties for plugin-specific
    settings (e.g., Path for tail, Port for forward).
  EOT
}
```

### filters (optional)

```hcl
variable "filters" {
  type = list(object({
    name             = string
    match            = optional(string, "*")
    match_regex      = optional(string)
    alias            = optional(string)
    log_level        = optional(string)
    extra_properties = optional(map(string), {})
  }))
  default     = []
  description = <<-EOT
    List of Fluent Bit FILTER sections. Each entry defines a
    processing step (e.g., grep, modify, kubernetes). The name
    attribute specifies the plugin. Use match or match_regex to
    select which records to process. Use extra_properties for
    plugin-specific settings.
  EOT
}
```

### outputs_ (optional)

Note: Named `outputs_` with trailing underscore to avoid collision
with Terraform reserved word `outputs`.

```hcl
variable "outputs_" {
  type = list(object({
    name             = string
    match            = optional(string, "*")
    match_regex      = optional(string)
    alias            = optional(string)
    log_level        = optional(string)
    retry_limit      = optional(string)
    workers          = optional(number)
    extra_properties = optional(map(string), {})
  }))
  default     = []
  description = <<-EOT
    List of Fluent Bit OUTPUT sections. Each entry defines a
    destination (e.g., cloudwatch_logs, s3, stdout). The name
    attribute specifies the plugin. Use match or match_regex to
    select which records to send. Use extra_properties for
    plugin-specific settings (e.g., region, log_group_name).
  EOT
}
```

### parsers (optional)

```hcl
variable "parsers" {
  type = list(object({
    name        = string
    format      = string
    regex       = optional(string)
    time_key    = optional(string)
    time_format = optional(string)
    time_keep   = optional(bool)
    time_offset = optional(string)
    types       = optional(string)
    extra_properties = optional(map(string), {})
  }))
  default     = []
  description = <<-EOT
    List of Fluent Bit PARSER sections. Each entry defines a log
    parser. The format attribute must be one of: json, regex,
    ltsv, logfmt. When format is "regex", the regex attribute is
    required. Use extra_properties for less common settings like
    Decode_Field, Skip_Empty_Values, etc.
  EOT

  validation {
    condition = alltrue([
      for p in var.parsers :
      contains(["json", "regex", "ltsv", "logfmt"], p.format)
    ])
    error_message = "Parser format must be one of: json, regex, ltsv, logfmt."
  }
}
```

### multiline_parsers (optional)

```hcl
variable "multiline_parsers" {
  type = list(object({
    name          = string
    type          = string
    parser        = optional(string)
    key_content   = optional(string)
    flush_timeout = optional(string)
    rules = optional(list(object({
      state      = string
      regex      = string
      next_state = string
    })), [])
    extra_properties = optional(map(string), {})
  }))
  default     = []
  description = <<-EOT
    List of Fluent Bit MULTILINE_PARSER sections. Each entry
    defines a multiline log parser with state machine rules. The
    type attribute must be one of: regex, endswith, equal.
    Rules define state transitions: state is the current state
    name (first rule must use "start_state"), regex is the match
    pattern, and next_state is the target state.
  EOT

  validation {
    condition = alltrue([
      for p in var.multiline_parsers :
      contains(["regex", "endswith", "equal", "eq"], p.type)
    ])
    error_message = "Multiline parser type must be one of: regex, endswith, equal, eq."
  }
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
