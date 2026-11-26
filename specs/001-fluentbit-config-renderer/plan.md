# Implementation Plan: Fluent Bit Configuration Renderer

**Branch**: `001-fluentbit-config-renderer` | **Date**: 2026-02-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-fluentbit-config-renderer/spec.md`

## Summary

Terraform module that accepts Fluent Bit configuration sections
(SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER) as
**self-documenting typed variables** with named attributes for
common engine-level properties and `extra_properties` maps for
plugin-specific settings. Typed attributes are normalized into a
single canonical local, then rendered to both classic INI-style
and YAML configuration outputs. The classic format uses
`templatefile()` for readability. Validation blocks enforce enum
constraints (log_level, parser format, multiline parser type).
Designed for use with AWS for Fluent Bit init process but
generates config files only — S3 storage is out of scope.

## Technical Context

**Language/Version**: HCL (Terraform >= 1.3)
**Primary Dependencies**: None (pure HCL, no external modules)
**Storage**: N/A (pure rendering module, no state)
**Testing**: Terraform native tests (`.tftest.hcl`) with mock providers
**Target Platform**: Any (Terraform module consumed by other modules)
**Project Type**: Single Terraform module
**Performance Goals**: N/A (plan-time rendering only)
**Constraints**: Pure Terraform — no external providers, scripts, or
binaries. All rendering via HCL functions and `templatefile()`.
**Scale/Scope**: Handles configurations with 20+ sections of mixed
types without plan-time issues.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Test-First Imperative

- **PASS**: All implementation MUST follow TDD. Tests written in
  `.tftest.hcl` files before any rendering logic. Tests must fail
  (Red) before implementation proceeds (Green).
- **Gate**: No `.tf` implementation files modified until
  corresponding `.tftest.hcl` tests exist and fail.

### Principle II: Simplicity and Anti-Abstraction

- **PASS**: Single root module (1 project). No nested modules.
  Templates directory contains `.tftpl` files but these are data
  files, not separate projects.
- **Gate**: Project count = 1. No abstractions beyond what Terraform
  natively provides (`locals`, `templatefile`).

### Principle III: Validate and Format

- **PASS**: All changes validated via `terraform fmt`, `terraform
  validate`, and pre-commit hooks before completion.
- **Gate**: `pre-commit run --all-files` must pass after each
  implementation phase.

### Principle IV: Examples

- **PASS**: Examples in `examples/basic/` and `examples/complete/`
  demonstrate real usage patterns. Examples are the last step
  before documentation in the implementation workflow.
- **Gate**: Examples must be valid standalone Terraform configs.

### Principle V: Self-Documenting Variables

- **PASS**: All section variables use typed objects with named
  attributes for common engine-level properties. `extra_properties`
  map(string) available for plugin-specific settings. Validation
  blocks enforce enum constraints (log_level, format, type).
- **Gate**: No `list(list(string))` freeform structures. All
  variables have descriptive `description` attributes.

### Principle VI: Runtime Configuration Validation

- **PASS**: Rendered classic and YAML outputs will be validated
  against the Fluent Bit binary via Docker (`--dry-run`) to
  confirm syntactic correctness beyond Terraform static checks.
- **Gate**: Both `classic_config` and `yaml_config` outputs MUST
  pass Fluent Bit's built-in validation before the build is
  considered passing. Validation runs via
  `docker run fluent/fluent-bit:latest --dry-run`.

### Post-Design Re-check

- **Principle I**: PASS — Test plan covers all user stories.
- **Principle II**: PASS — 1 project, no nested modules, no
  unnecessary abstractions.
- **Principle III**: PASS — Validation toolchain unchanged.
- **Principle IV**: PASS — Examples in basic/ and complete/.
- **Principle V**: PASS — Typed objects with named attributes.
- **Principle VI**: PASS — Runtime validation phase added to tasks.

## Project Structure

### Documentation (this feature)

```text
specs/001-fluentbit-config-renderer/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── terraform-interface.md
└── tasks.md             # Created by /speckit.tasks
```

### Source Code (repository root)

```text
terraform-fluentbit-config-renderer/
├── main.tf              # Locals (canonical sections normalization)
├── variables.tf         # service, inputs, filters, outputs_,
│                        #   parsers, multiline_parsers
├── outputs.tf           # classic_config, yaml_config
├── versions.tf          # Terraform >= 1.3
├── locals.tf            # Canonical section normalization + rendering
├── templates/
│   └── classic.tftpl    # templatefile() template for classic format
├── examples/
│   ├── basic/           # Minimal: 1 INPUT + 1 OUTPUT
│   └── complete/        # Full: all section types, multiple entries
└── tests/
    ├── basic.tftest.hcl       # P1: basic rendering
    ├── parsers.tftest.hcl     # P2: parser sections
    ├── routing.tftest.hcl     # P3: multi-source routing
    └── validation.tftest.hcl  # Input validation tests
```

**Structure Decision**: Single Terraform module at repository root.
No nested modules. Template file (`templates/classic.tftpl`) is a
data file consumed by `templatefile()`, not a separate project.
This is the simplest structure that satisfies all requirements.

## Complexity Tracking

> No violations. Single project, no unnecessary abstractions.
