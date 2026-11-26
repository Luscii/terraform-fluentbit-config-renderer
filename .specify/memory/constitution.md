<!--
SYNC IMPACT REPORT
==================
Version change: N/A -> 1.0.0 (initial ratification)

Added principles:
  - I. Test-First Imperative
  - II. Simplicity and Anti-Abstraction
  - III. Validate and Format

Added sections:
  - Core Principles (3 principles)
  - Technology Constraints
  - Development Workflow
  - Governance

Removed sections: N/A (initial version)

Templates requiring updates:
  - .specify/templates/plan-template.md ........... OK (no changes needed)
  - .specify/templates/spec-template.md ........... OK (no changes needed)
  - .specify/templates/tasks-template.md .......... OK (no changes needed)
  - .specify/templates/checklist-template.md ...... OK (no changes needed)
  - .specify/templates/agent-file-template.md ..... OK (no changes needed)

Follow-up TODOs: None
==================
-->

# Fluent Bit Configuration Renderer Constitution

## Core Principles

### I. Test-First Imperative

**NON-NEGOTIABLE**: All implementation MUST follow strict Test-Driven
Development (TDD). No implementation code shall be written before the
following conditions are met, in order:

1. **Unit tests are written** covering the intended behavior.
2. **Tests are validated and approved** by the user.
3. **Tests are confirmed to FAIL** (Red phase) proving they exercise
   new or changed behavior.

Only after these three gates pass may implementation code be written
(Green phase). Refactoring follows only after tests pass (Refactor
phase).

**Rationale**: Writing tests first ensures requirements are
unambiguous, implementation stays minimal, and regressions are caught
immediately. Skipping any gate invalidates the development cycle.

### II. Simplicity and Anti-Abstraction

All design decisions MUST favor simplicity over abstraction.

- The initial implementation MUST NOT exceed **3 projects**
  (root module + up to 2 nested modules or supporting packages).
- Additional projects require **documented justification** explaining
  why the existing structure is insufficient and what simpler
  alternatives were evaluated and rejected.
- YAGNI (You Aren't Gonna Need It) applies: do not introduce
  abstractions, helper utilities, or indirection layers for
  hypothetical future requirements.
- Prefer duplication over premature abstraction when the duplicated
  code serves distinct concerns.

**Rationale**: Complexity is the primary threat to maintainability
in infrastructure code. Every abstraction layer adds cognitive load
and must earn its place through demonstrated necessity.

### III. Validate and Format

All changes MUST be validated and formatted before they are
considered complete. The required validation toolchain is available
through pre-commit hooks and MUST be executed:

- `terraform fmt` MUST pass with no formatting changes required.
- `terraform validate` MUST pass with no errors.
- All pre-commit hooks MUST pass successfully.
- No change is complete until validation confirms zero violations.

**Rationale**: Consistent formatting and validated configurations
prevent drift, reduce review friction, and catch errors before they
reach shared branches.

## Technology Constraints

- **Language**: HCL (Terraform >= 1.3)
- **Naming/Tagging**: CloudPosse label module (v0.25.0) is required
  for all resource naming and tagging.
- **Testing**: Terraform native tests (`.tftest.hcl`) with mock
  providers for unit tests and real providers for integration tests.
- **Documentation**: terraform-docs for automated README generation.
- **Commit Convention**: Conventional Commits specification for all
  PR titles and commit messages.

## Development Workflow

1. **Write tests first** (Principle I gate).
2. **Obtain user approval** on test design.
3. **Confirm tests fail** (Red phase).
4. **Implement** the minimum code to make tests pass (Green phase).
5. **Refactor** while keeping tests green (Refactor phase).
6. **Run pre-commit hooks** to validate and format (Principle III).
7. **Commit** using Conventional Commits format.

## Governance

- This constitution supersedes all other development practices
  when conflicts arise.
- Amendments require: (a) a documented rationale, (b) user approval,
  and (c) a version bump following semantic versioning.
- Version policy:
  - **MAJOR**: Principle removal or backward-incompatible redefinition.
  - **MINOR**: New principle or materially expanded guidance added.
  - **PATCH**: Clarifications, wording fixes, non-semantic changes.
- All code reviews and PR approvals MUST verify compliance with
  the principles defined in this constitution.

**Version**: 1.0.0 | **Ratified**: 2026-02-11 | **Last Amended**: 2026-02-11
