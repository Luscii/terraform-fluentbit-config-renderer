# Data Model: Fluent Bit Configuration Renderer

## Entities

### Section

A Fluent Bit configuration block. Each section has a type and an
ordered list of properties.

| Attribute  | Type                    | Description                        |
|------------|-------------------------|------------------------------------|
| type       | string (enum)           | SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER |
| properties | list(tuple(string, string)) | Ordered key-value tuples. Duplicate keys allowed. |

### Configuration (canonical local)

The normalized intermediate representation built from all input
variables. This is the single source of truth from which both
classic and YAML formats are rendered.

| Attribute          | Type            | Description                      |
|--------------------|-----------------|----------------------------------|
| service            | list(Section)   | 0 or 1 SERVICE sections          |
| inputs             | list(Section)   | 0+ INPUT sections                |
| filters            | list(Section)   | 0+ FILTER sections               |
| outputs            | list(Section)   | 0+ OUTPUT sections               |
| parsers            | list(Section)   | 0+ PARSER sections               |
| multiline_parsers  | list(Section)   | 0+ MULTILINE_PARSER sections     |

### Rendered Output

| Attribute       | Type   | Description                            |
|-----------------|--------|----------------------------------------|
| classic_config  | string | Complete classic INI-style config       |
| yaml_config     | string | Complete YAML config                    |

## Variable Input Structure

Each section type is accepted as a separate Terraform variable
using **typed objects** with named attributes for common
engine-level properties, plus an `extra_properties` map for
plugin-specific settings (Constitution Principle V).

### Hybrid Typed Model

Common Fluent Bit engine properties are typed as named attributes.
Plugin-specific properties use `extra_properties = map(string)`.

```hcl
# Example: inputs variable with typed common properties
variable "inputs" {
  type = list(object({
    name             = string              # Required: plugin name
    tag              = optional(string)     # Tag for records
    alias            = optional(string)     # Instance identifier
    log_level        = optional(string)     # Per-plugin log level
    mem_buf_limit    = optional(string)     # Memory buffer limit
    storage_type     = optional(string)     # memory or filesystem
    routable         = optional(bool)       # Whether records are routable
    threaded         = optional(bool)       # Run in own thread
    extra_properties = optional(map(string), {})  # Plugin-specific
  }))
  default = []
}
```

### MULTILINE_PARSER rules

Rules for MULTILINE_PARSER are modeled as a typed list of objects
to handle the "duplicate key" pattern in a type-safe way:

```hcl
rules = optional(list(object({
  state      = string    # State name (first must be "start_state")
  regex      = string    # Match pattern
  next_state = string    # Target state for continuation
})), [])
```

### Property Normalization

Typed attributes are normalized into `[key, value]` tuples in
`locals.tf` before rendering. The canonical `local.sections` list
remains the single intermediate representation, unchanged from the
freeform model. Only the variable-to-canonical conversion logic
changes.

## Data Flow

```text
Input Variables        Normalization          Canonical Local           Rendered Outputs
(typed objects)        (locals.tf)            (same as before)          (unchanged)
─────────────────      ─────────────────      ─────────────────         ──────────────────
var.service     ─┐     Convert typed attrs
var.inputs      ─┤     + extra_properties     local.sections            output.classic_config
var.filters     ─┼──►  into [key, value]  ──► (ordered list of all ──►  output.yaml_config
var.outputs_    ─┤     tuples                  sections by type)
var.parsers     ─┤
var.multiline   ─┘
  _parsers
```

## Section Ordering (canonical)

Sections are ordered in the canonical local as follows:
1. SERVICE (0 or 1)
2. INPUT (0+, preserving input order)
3. FILTER (0+, preserving input order)
4. OUTPUT (0+, preserving input order)
5. PARSER (0+, preserving input order)
6. MULTILINE_PARSER (0+, preserving input order)

This matches the Fluent Bit documentation convention.
