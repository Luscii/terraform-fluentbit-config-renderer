<!--
SYNC IMPACT REPORT
==================
Version change: 1.2.0 -> 1.3.0 (minor)

Added sections:
  - Core Principles: Added Principle VI (Runtime Configuration
    Validation). Rendered configuration outputs MUST be validated
    against the Fluent Bit binary via Docker to confirm syntactic
    correctness beyond what static analysis provides.

Modified sections:
  - Development Workflow: Added step 5a for runtime validation
    between implementation and pre-commit.

Removed sections: None

Templates requiring updates:
  - .specify/templates/plan-template.md ........... OK (no changes needed)
  - .specify/templates/spec-template.md ........... OK (no changes needed)
  - .specify/templates/tasks-template.md .......... OK (no changes needed)
  - .specify/templates/checklist-template.md ...... OK (no changes needed)
  - .specify/templates/agent-file-template.md ..... OK (no changes needed)

Follow-up TODOs:
  - Spec, plan, and tasks must be updated to include runtime
    validation tasks. A new phase or tasks within the validation
    phase should cover Docker-based config validation.
  - Investigate feasibility of running Docker validation within
    Terraform test suites (terraform_data + local-exec) vs.
    CI/CD pipeline integration.
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

### IV. Examples

All modules MUST include working examples in the `examples/`
directory that demonstrate real usage patterns.

- At minimum, a **basic** example showing the simplest viable usage
  and a **complete** example covering all supported features.
- Examples MUST be valid Terraform configurations that can be
  applied standalone (`terraform init && terraform apply`).
- Examples are the **last implementation step** within the
  development flow, written after all functional code and tests
  pass. They are completed before documentation generation and
  final polish.
- Examples serve as the primary usage documentation for module
  consumers and MUST be kept in sync with the module interface.

**Rationale**: Infrastructure modules are consumed by other
engineers who need concrete, runnable demonstrations of how to use
the module. Examples bridge the gap between variable definitions
and real-world usage patterns, reducing onboarding time and
support burden.

### V. Self-Documenting Variables

Module variables MUST be designed so that the type signature and
description alone provide sufficient guidance for a consumer
(human or AI) to use the module correctly without consulting
external documentation.

- Variable types MUST use **named object attributes** instead of
  freeform structures. For example, prefer
  `object({ name = string, match = optional(string) })` over
  `list(list(string))`.
- Each variable MUST include a `description` that explains its
  purpose, valid values, and relationship to the domain (e.g.,
  which Fluent Bit plugin properties it controls).
- Optional attributes MUST use Terraform's `optional()` type
  modifier with sensible defaults where applicable, so consumers
  see which fields are required vs. optional at the type level.
- Enum-like constraints (e.g., plugin names, log levels) SHOULD
  be enforced via `validation` blocks that list allowed values,
  providing immediate feedback on misconfiguration.
- When a domain has a fixed set of known properties per plugin or
  section type, the variable type MUST enumerate those properties
  as named attributes rather than accepting arbitrary key-value
  pairs.

**Rationale**: Freeform structures like `list(list(string))` offer
no guidance on valid keys, required fields, or value formats.
Strongly-typed variables with named attributes turn the Terraform
type system into living documentation — IDE autocompletion,
`terraform plan` error messages, and AI code assistants all
benefit from explicit type contracts. This dramatically reduces
misconfiguration and support burden.

### VI. Runtime Configuration Validation

Rendered configuration outputs MUST be validated against the
Fluent Bit binary to confirm syntactic correctness beyond what
Terraform's static validation provides.

- The Fluent Bit binary's built-in validation mode MUST be used
  to check rendered configurations for syntax errors. The
  validation command is:
  ```
  docker run --rm \
    -v /path/to/config:/fluent-bit/etc/fluent-bit.conf:ro \
    fluent/fluent-bit:latest \
    /fluent-bit/bin/fluent-bit \
      -c /fluent-bit/etc/fluent-bit.conf \
      --dry-run
  ```
- Validation MUST run via Docker to ensure a consistent,
  reproducible environment independent of local tooling.
- This validation SHOULD be integrated into Terraform test suites
  where technically feasible (e.g., via `terraform_data` with a
  `local-exec` provisioner that writes the rendered config to a
  temp file and runs the Docker validation command). Where test
  integration is not practical, it MUST be integrated into the
  CI/CD pipeline as a mandatory gate.
- Validation failures MUST block merges — an invalid rendered
  configuration MUST NOT be considered a passing build.
- Both classic (INI-style) and YAML rendered outputs MUST be
  validated independently, as each format has distinct parsing
  rules in the Fluent Bit binary.

**Rationale**: Static rendering (template expansion, yamlencode)
can produce output that looks syntactically correct but is
rejected by the Fluent Bit parser. Only the Fluent Bit binary
itself can authoritatively confirm a configuration is valid.
Automated runtime validation prevents configuration errors from
reaching production and provides a tighter feedback loop than
manual testing.

## Technology Constraints

- **Language**: HCL (Terraform >= 1.3)
- **Naming/Tagging**: CloudPosse label module (v0.25.0) is the
  default convention for modules that manage cloud resources.
  Pure rendering or utility modules without cloud resources MAY
  omit the label module.
- **Testing**: Terraform native tests (`.tftest.hcl`) with mock
  providers for unit tests and real providers for integration tests.
- **Documentation**: terraform-docs for automated README generation.
- **Commit Convention**: Conventional Commits specification for all
  PR titles and commit messages.
- **Runtime Validation**: Docker with `fluent/fluent-bit:latest`
  image for configuration syntax validation.

## Development Workflow

1. **Write tests first** (Principle I gate).
2. **Obtain user approval** on test design.
3. **Confirm tests fail** (Red phase).
4. **Implement** the minimum code to make tests pass (Green phase).
5. **Refactor** while keeping tests green (Refactor phase).
6. **Validate rendered output** against Fluent Bit binary via Docker
   (Principle VI gate).
7. **Run pre-commit hooks** to validate and format (Principle III).
8. **Commit** using Conventional Commits format.

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

**Version**: 1.3.0 | **Ratified**: 2026-02-11 | **Last Amended**: 2026-02-11
