# Feature Specification: Fluent Bit Configuration Renderer

**Feature Branch**: `001-fluentbit-config-renderer`
**Created**: 2026-02-11
**Status**: Draft
**Input**: User description: "Terraform module that renders valid fluentbit configuration files in both classic and YAML formats"

## Clarifications

### Session 2026-02-11

- Q: Is CloudPosse label module required? → A: No, not needed for this module.
- Q: Support CUSTOM section type? → A: No, excluded for now (YAGNI). Can be added later.
- Q: Key alignment scope in classic format? → A: Per-section (each section aligns to its own longest key).
- Q: Keep context/name variables? → A: No, only Fluent Bit section variables.
- Q: Should variables use freeform list(list(string)) or typed objects?
  → A: Typed objects with named attributes for common engine-level
  properties (name, tag, match, log_level, etc.) plus an
  extra_properties map(string) escape hatch for plugin-specific
  settings. This follows Constitution Principle V (Self-Documenting
  Variables).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Render a Basic Fluent Bit Configuration (Priority: P1)

As a platform engineer, I want to define Fluent Bit configuration
sections (SERVICE, INPUT, FILTER, OUTPUT) as structured Terraform
variables so that the module renders a valid, complete Fluent Bit
classic-format configuration file I can mount into my containers.

**Why this priority**: This is the core value proposition. Without
the ability to render a basic config from structured input, nothing
else matters. A single rendered config with at least SERVICE and one
INPUT/OUTPUT pair is already useful.

**Independent Test**: Can be fully tested by providing minimal
variable inputs (one INPUT, one OUTPUT) and asserting the rendered
output matches valid Fluent Bit classic INI-style syntax.

**Acceptance Scenarios**:

1. **Given** a variable defining a SERVICE section with `Flush 5`
   and `Log_Level info`, **When** the module is applied, **Then**
   the output contains a `[SERVICE]` block with those key-value
   pairs, each key indented with 4 spaces.
2. **Given** variables defining one INPUT (`tail` plugin with a
   `Path` and `Tag`) and one OUTPUT (`stdout` plugin), **When** the
   module is applied, **Then** the rendered config contains both
   `[INPUT]` and `[OUTPUT]` blocks with the correct properties.
3. **Given** no SERVICE section is provided, **When** the module is
   applied, **Then** the rendered config omits the `[SERVICE]` block
   entirely (no empty section headers).
4. **Given** multiple OUTPUT sections targeting different
   destinations, **When** the module is applied, **Then** each
   OUTPUT appears as a separate `[OUTPUT]` block in the rendered
   config, in the order they were defined.

---

### User Story 2 - Render PARSER and MULTILINE_PARSER Sections (Priority: P2)

As a platform engineer, I want to define PARSER and
MULTILINE_PARSER sections so that the module renders them as part of
the configuration for structured log parsing.

**Why this priority**: Parsers are essential for real-world log
processing but are not required for the simplest use case. They
extend the core rendering capability.

**Independent Test**: Can be tested by providing PARSER definitions
and asserting the rendered output contains valid `[PARSER]` blocks
with the correct Format, Regex, and Time_Format properties.

**Acceptance Scenarios**:

1. **Given** a PARSER definition with `Name docker`, `Format json`,
   and `Time_Key time`, **When** the module is applied, **Then**
   the rendered config contains a `[PARSER]` block with those
   properties.
2. **Given** a MULTILINE_PARSER definition with state machine rules,
   **When** the module is applied, **Then** the rendered config
   contains a `[MULTILINE_PARSER]` block with correctly formatted
   `rule` entries.
3. **Given** both PARSER and core pipeline sections (INPUT, OUTPUT),
   **When** the module is applied, **Then** all sections appear in
   the rendered config in the correct canonical order: SERVICE,
   INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER.

---

### User Story 3 - Multiple Log Sources with Tag-Based Routing (Priority: P3)

As a platform engineer running multiple application containers, I
want to define several INPUT sources with distinct tags and route
them to different OUTPUTs using Match patterns so that each
application's logs reach the correct destination.

**Why this priority**: Multi-source routing is the primary
real-world pattern but builds on P1 and P2 capabilities. It
validates that the module handles multiple instances of the same
section type correctly.

**Independent Test**: Can be tested by defining two INPUTs with
different tags and two OUTPUTs with different Match patterns, then
asserting each section renders correctly and independently.

**Acceptance Scenarios**:

1. **Given** two INPUT sections with tags `app.frontend` and
   `app.backend`, and two OUTPUT sections with Match patterns
   `app.frontend` and `app.backend` respectively, **When** the
   module is applied, **Then** the rendered config contains all four
   sections with correct tag/match associations.
2. **Given** a FILTER section with `Match *` (wildcard), **When**
   the module is applied, **Then** the filter block appears between
   the INPUT and OUTPUT blocks in the rendered config.

---

### Edge Cases

- What happens when an empty list of sections is provided? The
  module MUST produce an empty string (no config output).
- What happens when a section has no properties beyond `Name`? The
  module MUST render the section header and the `Name` property
  only.
- What happens when a property value contains special characters
  (regex patterns, file paths with spaces)? The module MUST render
  the value exactly as provided, without escaping or quoting.
- What happens when duplicate keys exist within a section (valid in
  Fluent Bit, e.g., multiple `rule` entries in MULTILINE_PARSER)?
  The module MUST render each entry on its own line.
  MULTILINE_PARSER rules are modeled as a typed list of objects
  (state, regex, next_state) rather than freeform duplicate keys.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Module MUST accept structured input variables
  representing Fluent Bit configuration sections (SERVICE, INPUT,
  FILTER, OUTPUT, PARSER, MULTILINE_PARSER). Variables MUST use
  typed objects with named attributes for common engine-level
  properties (e.g., name, tag, match, log_level) and an
  `extra_properties` map for plugin-specific settings.
- **FR-002**: Module MUST render output in Fluent Bit classic
  INI-style format: section headers in `[BRACKETS]`, properties
  indented with 4 spaces, key-value pairs separated by spaces.
  Classic config MUST be generated via Terraform `templatefile()`
  for readability.
- **FR-002a**: Module MUST also render output in Fluent Bit YAML
  format following the official YAML schema (`service`, `pipeline`
  with `inputs`/`filters`/`outputs`, `parsers`,
  `multiline_parsers`).
- **FR-003**: Module MUST support multiple instances of the same
  section type (e.g., multiple INPUTs, multiple OUTPUTs).
- **FR-004**: Module MUST preserve the order of sections as defined
  in the input variables.
- **FR-005**: Module MUST omit section types that have no entries
  (no empty `[SECTION]` headers).
- **FR-006**: Module MUST align property values within each section
  block for readability. Alignment is per-section: each section
  pads keys to match the longest key within that section.
- **FR-007**: Module MUST expose the rendered configuration as
  Terraform outputs (`classic_config` and `yaml_config`) that can
  be consumed by other modules or resources (e.g., for mounting as
  a container file).
- **FR-007a**: Module MUST use a single canonical local value as
  the intermediate representation. Both classic and YAML outputs
  MUST be rendered from this same canonical local to avoid
  duplication.
- **FR-008**: Module MUST support properties with duplicate keys
  within a single section (required for Fluent Bit `rule` entries
  and `@INCLUDE` directives).
- **FR-009**: Module does NOT require CloudPosse label module
  integration. This is a pure rendering module with no cloud
  resources to name or tag. The module accepts only Fluent Bit
  section variables (no `context` or `name` variables).
- **FR-010**: Module MUST provide self-documenting variables per
  Constitution Principle V. Each section variable MUST use typed
  objects with named attributes for common Fluent Bit engine
  properties. Enum-like fields (log_level, parser format,
  multiline parser type) MUST have validation blocks. An
  `extra_properties` map(string) MUST be available on every
  section variable for plugin-specific settings not covered by
  typed attributes.
- **FR-011**: Rendered configuration outputs (both classic and YAML)
  MUST be validated against the Fluent Bit binary's built-in
  validation mode to confirm syntactic correctness. Validation MUST
  run via Docker (`fluent/fluent-bit:latest --dry-run`) and SHOULD
  be integrated into the Terraform test suite where feasible. Where
  test integration is not practical, it MUST be integrated into the
  CI/CD pipeline as a mandatory gate. An invalid rendered
  configuration MUST NOT be considered a passing build.

### Key Entities

- **Section**: A Fluent Bit configuration block defined by its type
  (SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER) and a
  list of key-value properties.
- **Property**: A key-value pair within a section. Keys are strings;
  values are strings. A section may contain multiple properties with
  the same key.
- **Configuration**: The complete rendered output consisting of zero
  or more sections in canonical order, available in both Fluent Bit
  classic INI-style syntax and YAML format. Both are rendered from
  a single canonical intermediate representation.

## Assumptions

- The module renders both **classic INI-style format** and **YAML
  format**. Classic remains the dominant format in production
  deployments; YAML is the future direction (Fluent Bit v3.2+).
- Property value validation (e.g., checking that a plugin name is
  valid) is NOT in scope for the Terraform module itself. The module
  is a renderer, not a validator. However, rendered output MUST be
  validated against the Fluent Bit binary via Docker to confirm
  syntactic correctness (see FR-011).
- The `@INCLUDE` directive is modeled as a top-level property, not
  as a separate section type.
- The `[CUSTOM]` section type is explicitly out of scope for the
  initial implementation. It can be added in a future iteration.
- Sections are rendered in the order: SERVICE, INPUT, FILTER,
  OUTPUT, PARSER, MULTILINE_PARSER (canonical Fluent Bit ordering),
  with entries within each type preserving their input order.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can define a complete Fluent Bit configuration
  (SERVICE + INPUTs + FILTERs + OUTPUTs) using only Terraform
  variables, without writing any raw config text.
- **SC-002**: The rendered configuration output is directly usable
  by Fluent Bit without modification (valid syntax, correct
  formatting).
- **SC-003**: Users can add or remove log sources and destinations
  by modifying variable values alone, without changing module code.
- **SC-004**: The module correctly handles configurations with 10+
  sections of mixed types without rendering errors or ordering
  issues.
- **SC-005**: Both classic and YAML rendered outputs pass the Fluent
  Bit binary's built-in configuration validation (`--dry-run`) via
  Docker, confirming syntactic correctness beyond static analysis.
