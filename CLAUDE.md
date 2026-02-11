# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform module for rendering Fluent Bit configurations, following Luscii conventions. Built on the CloudPosse label module (v0.25.0) for naming/tagging. Modules are distributed via GitHub (`github.com/Luscii/terraform-{provider}-{name}`), NOT the Terraform Registry.

## Commands

```bash
# Format
terraform fmt -recursive

# Validate (requires init first)
terraform init
terraform validate

# Test
terraform test
terraform test -verbose
terraform test tests/specific-test.tftest.hcl

# Lint
tflint --init && tflint

# Security scan
checkov -d . --config-file ./.checkov-config.yml

# Generate docs (injected into README.md between TF_DOCS markers)
terraform-docs markdown . --output-file README.md

# Run all checks at once
pre-commit run --all-files
```

## Constitution (NON-NEGOTIABLE)

See `.specify/memory/constitution.md` for full details. Three principles govern all work:

1. **Test-First Imperative**: Write tests FIRST, get user approval, confirm they FAIL (Red), only then implement (Green), then Refactor. No exceptions.
2. **Simplicity and Anti-Abstraction**: Maximum 3 projects (root + up to 2 nested modules). Additional projects require documented justification. YAGNI applies.
3. **Validate and Format**: `terraform fmt`, `terraform validate`, and all pre-commit hooks MUST pass before any change is considered complete.

## Development Workflow

1. Write `.tftest.hcl` tests in `tests/` covering intended behavior
2. Get user approval on test design
3. Run `terraform test` — confirm tests fail (Red phase)
4. Implement minimum code to pass tests (Green phase)
5. Refactor while tests stay green
6. Run `pre-commit run --all-files`
7. Commit using Conventional Commits (`feat:`, `fix:`, `chore:`, append `!` for breaking changes)

## Terraform Conventions

- **Indentation**: 2 spaces, align `=` signs within blocks
- **Variable order**: `context` variable first in `variables.tf`, then alphabetical
- **Output order**: Alphabetical in `outputs.tf`
- **Resource naming**: Use `this` for the module's primary resource; descriptive names for supporting resources (never repeat the resource type in the identifier)
- **File splitting**: Separate files by resource type using kebab-case (`security-group.tf`, `iam-role-policies.tf`)
- **HCL objects**: Single-line objects use commas; multi-line objects omit commas
- **Label module**: Always use `cloudposse/label/null` v0.25.0 for naming and tagging
- **Module sourcing priority**: Luscii GitHub modules > Official HashiCorp providers > Third-party (last resort)

## Testing Patterns

- **Unit tests**: `command = plan` with `mock_provider` blocks — no real infrastructure
- **Integration tests**: `command = apply` with real providers
- **Validation tests**: Test input constraints with `expect_failures`
- **File naming**: `basic.tftest.hcl`, `unit.tftest.hcl`, `integration.tftest.hcl`, `validation.tftest.hcl`
- **Assertions**: Always include actual values in error messages (`"Expected X, got ${actual}"`)
- **Helper modules**: Place in `tests/setup/` and `tests/final/`

## Key Files

- `.github/instructions/*.instructions.md` — Detailed coding standards (auto-applied by file pattern)
- `.github/agents/*.md` — Specialized AI agent definitions for the TDD workflow
- `.specify/memory/constitution.md` — Project constitution with non-negotiable principles
- `.pre-commit-config.yaml` — All validation hooks
- `.checkov-config.yml` — Security scan configuration (skips: `CKV_TF_1`, `CKV_TF_2`, `CKV_AWS_260`, `CKV2_GHA_1`)
- `.terraform-docs.yml` — Documentation generation config (inject mode into README.md)

## Language

All code, comments, documentation, and commit messages MUST be in English.

## Active Technologies
- HCL (Terraform >= 1.3), pure rendering module, no external dependencies (001-fluentbit-config-renderer)

## Recent Changes
- 001-fluentbit-config-renderer: Added HCL (Terraform >= 1.3) pure rendering module
