# Research: Fluent Bit Configuration Renderer

## Decision 1: Output Formats — Classic INI + YAML

**Decision**: Support both classic INI-style and YAML output formats.

**Rationale**: The user explicitly requested both formats. Classic
INI remains the dominant format in production (especially with AWS
for Fluent Bit init process). YAML is the new standard (Fluent Bit
v3.2+) and supports additional features like processors.

**Alternatives considered**:
- Classic only: Would miss YAML-specific features and future
  direction. Rejected because user explicitly requested both.
- YAML only: Would break compatibility with existing deployments
  using classic format. Rejected.

## Decision 2: Data Model — Single Canonical Local, Dual Rendering

**Decision**: Accept input as structured Terraform variables (lists
of objects), normalize into a single canonical `locals` value, then
render to classic or YAML via separate rendering paths.

**Rationale**: Eliminates duplication. One input definition produces
both formats. The canonical local serves as the single source of
truth. Classic config uses `templatefile()` for readability. YAML
uses `yamlencode()`.

**Alternatives considered**:
- Separate variables per format: Duplicates input, violates DRY.
  Rejected.
- Raw string input: Defeats the purpose of structured validation.
  Rejected.

## Decision 3: Classic Format Schema (from Fluent Bit docs)

**Decision**: Follow the documented classic mode format/schema.

**Key rules**:
- Sections delimited by `[SECTION_NAME]` in brackets
- All section content MUST be indented (4 spaces standard)
- Key-value pairs separated by spaces (not `=`)
- Multiple keys with the same name are allowed (e.g., `rule` in
  MULTILINE_PARSER)
- Comments use `#` prefix, must be on own line (no end-of-line
  comments), must be indented under a section
- `@INCLUDE` directive for including other config files
- Section types: SERVICE, INPUT, FILTER, OUTPUT, PARSER,
  MULTILINE_PARSER, CUSTOM

**Source**: https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/format-schema

## Decision 4: YAML Format Schema

**Decision**: Follow the Fluent Bit YAML schema structure.

**Key rules**:
- Top-level keys: `service`, `pipeline`, `parsers`,
  `multiline_parsers`
- `pipeline` contains: `inputs`, `filters`, `outputs` (each a list)
- Each list entry has `name` (plugin) and key-value properties
- `service` is a flat map of key-value pairs
- `parsers` and `multiline_parsers` are lists of parser definitions

**Example**:
```yaml
service:
    flush: 5
    log_level: info

pipeline:
    inputs:
        - name: tail
          tag: app.logs
          path: /var/log/*.log

    filters:
        - name: grep
          match: app.*
          regex: log ERROR

    outputs:
        - name: cloudwatch_logs
          match: app.*
          region: us-east-1
          log_group_name: /app/logs
```

## Decision 5: AWS for Fluent Bit Init Process Integration

**Decision**: Module generates config files only. Storage (S3) and
init process configuration are out of scope.

**Key findings**:
- AWS for Fluent Bit init process loads configs from S3 using
  `aws_fluent_bit_init_s3_[number]` environment variables
- Downloads to `/init/fluent-bit-init-s3-files/` in the container
- Creates main `fluent-bit-init.conf` with `@INCLUDE` directives
- Parser files are auto-detected and loaded with `-R` flags
- Supports both `.conf` (classic) and `.yaml` files
- ECS metadata variables are injected automatically

**Implications for this module**:
- Output must be valid standalone config files
- Parser sections should be renderable as separate files (for `-R`
  flag compatibility)
- No S3 upload logic needed — consuming modules handle that

## Decision 6: Classic Config Rendering via templatefile()

**Decision**: Use Terraform `templatefile()` for classic format
rendering.

**Rationale**: The user explicitly requested templates for
readability. `templatefile()` separates the format logic from the
data transformation, making the classic format output human-readable
and maintainable. The template file lives in `templates/` directory.

**Alternatives considered**:
- Pure HCL string interpolation with `join()`: Works but produces
  unreadable rendering logic. Rejected per user request.
- External script: Adds dependency, breaks pure Terraform. Rejected.

## Decision 7: Variable Structure for Section Input

**Decision**: Use a list of objects for each section type. Each
object contains a list of key-value tuples (not a map) to support
duplicate keys.

**Rationale**: Fluent Bit allows duplicate keys within a section
(e.g., multiple `rule` entries in MULTILINE_PARSER). Terraform maps
cannot have duplicate keys. A list of `[key, value]` tuples
preserves order and allows duplicates.

**Example input structure**:
```hcl
inputs = [
  {
    properties = [
      ["Name", "tail"],
      ["Tag", "app.logs"],
      ["Path", "/var/log/*.log"]
    ]
  }
]
```

**Alternatives considered**:
- Map of properties: Cannot support duplicate keys. Rejected.
- Single flat string list: Loses structure, harder to validate.
  Rejected.
