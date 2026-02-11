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
containing a list of objects. Each object's `properties` field is a
list of `[key, value]` tuples to support duplicate keys.

```hcl
# Example: inputs variable
variable "inputs" {
  type = list(object({
    properties = list(tuple([string, string]))
  }))
  default = []
}
```

## Data Flow

```text
Input Variables        Canonical Local           Rendered Outputs
─────────────────      ─────────────────         ──────────────────
var.service     ─┐
var.inputs      ─┤     local.sections            output.classic_config
var.filters     ─┼──►  (ordered list of all  ──► output.yaml_config
var.outputs     ─┤      sections by type)
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
