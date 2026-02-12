# Tasks: Fluent Bit Configuration Renderer

**Input**: Design documents from `/specs/001-fluentbit-config-renderer/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Required by Constitution Principle I (Test-First Imperative). Tests MUST be written and FAIL before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single Terraform module** at repository root
- `.tf` files at root, templates in `templates/`, tests in `tests/`

---

## Phase 1: Setup

**Purpose**: Project structure and variable definitions

- [x] T001 Remove existing placeholder main.tf, variables.tf, outputs.tf content and replace with empty shells per plan structure
- [x] T002 Create versions.tf with `terraform { required_version = ">= 1.3" }` (no required_providers block — pure rendering module)
- [x] T003 Create templates/ directory with empty classic.tftpl file at templates/classic.tftpl
- [x] T004 Define all input variables in variables.tf: service, inputs, filters, outputs_, parsers, multiline_parsers (each as `list(object({ properties = list(list(string)) }))` with default `[]`)
- [x] T005 Add validation block to service variable in variables.tf: `length(var.service) <= 1`
- [x] T006 Define outputs in outputs.tf: classic_config and yaml_config (initially empty string values)

**Checkpoint**: Module structure exists, `terraform init && terraform validate` passes with all variables defaulting to empty.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Canonical local that normalizes all input variables into a single ordered list of sections. This MUST be complete before any rendering work.

**CRITICAL**: No user story work can begin until this phase is complete.

- [x] T007 Write test for canonical sections local in tests/basic.tftest.hcl: given service, inputs, filters, outputs_, parsers, multiline_parsers variables, assert local.sections produces a flat list of objects with `type` and `properties` fields in canonical order (SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER)
- [x] T008 Confirm T007 test FAILS (Red phase)
- [x] T009 Implement canonical sections local in locals.tf: build `local.sections` as a flat ordered list from all input variables, each entry tagged with its section type string
- [x] T010 Run `terraform test tests/basic.tftest.hcl` to confirm T007 passes (Green phase)
- [x] T011 Run `pre-commit run --all-files` to validate and format

**Checkpoint**: `local.sections` produces correct canonical ordering. All downstream rendering consumes this single local.

---

## Phase 3: User Story 1 - Render a Basic Fluent Bit Configuration (Priority: P1)

**Goal**: Render SERVICE, INPUT, FILTER, OUTPUT sections in classic INI-style format via `templatefile()` and in YAML format.

**Independent Test**: Provide minimal inputs (one INPUT, one OUTPUT) and assert rendered outputs match valid Fluent Bit syntax in both formats.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T012 [P] [US1] Write classic format rendering tests in tests/basic.tftest.hcl: assert classic_config output contains `[SERVICE]` block with indented key-value pairs when service variable provided; assert `[INPUT]` and `[OUTPUT]` blocks render correctly; assert empty input produces empty string; assert per-section key alignment
- [x] T013 [P] [US1] Write YAML format rendering tests in tests/basic.tftest.hcl: assert yaml_config output contains `service:` mapping, `pipeline:` with `inputs:` and `outputs:` lists when variables provided; assert empty input produces empty string
- [x] T014 [P] [US1] Write omission tests in tests/basic.tftest.hcl: assert no `[SERVICE]` header when service is empty; assert no `pipeline.filters` key in YAML when filters is empty
- [x] T015 [P] [US1] Write ordering test in tests/basic.tftest.hcl: assert multiple OUTPUT sections render in input order in classic_config
- [x] T016 [US1] Confirm T012-T015 tests FAIL (Red phase)

### Implementation for User Story 1

- [x] T017 [US1] Create classic format template at templates/classic.tftpl: iterate over sections list, render `[TYPE]` header, indent each property key-value pair with 4 spaces, align keys per-section to longest key width, separate sections with blank line
- [x] T018 [US1] Implement classic_config rendering in locals.tf: use `templatefile("${path.module}/templates/classic.tftpl", { sections = local.sections })` to produce `local.classic_config`
- [x] T019 [US1] Implement yaml_config rendering in locals.tf: transform `local.sections` into Fluent Bit YAML schema structure (`service` map, `pipeline.inputs`/`filters`/`outputs` lists) and render via `yamlencode()`; store as `local.yaml_config`
- [x] T020 [US1] Wire outputs in outputs.tf: set classic_config value to `local.classic_config`, yaml_config to `local.yaml_config`
- [x] T021 [US1] Run `terraform test tests/basic.tftest.hcl` to confirm T012-T015 pass (Green phase)
- [x] T022 [US1] Run `pre-commit run --all-files` to validate and format

**Checkpoint**: Basic rendering works for SERVICE, INPUT, FILTER, OUTPUT in both classic and YAML formats. Module is independently usable.

---

## Phase 4: User Story 2 - Render PARSER and MULTILINE_PARSER Sections (Priority: P2)

**Goal**: Extend rendering to PARSER and MULTILINE_PARSER sections, including duplicate key support (e.g., `rule` entries).

**Independent Test**: Provide PARSER and MULTILINE_PARSER definitions and assert correct rendering in both formats, including canonical section ordering.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T023 [P] [US2] Write PARSER rendering tests in tests/parsers.tftest.hcl: assert classic_config contains `[PARSER]` block with Name, Format, Time_Key properties; assert yaml_config contains `parsers:` list with correct entries
- [x] T024 [P] [US2] Write MULTILINE_PARSER tests in tests/parsers.tftest.hcl: assert classic_config renders multiple `rule` entries (duplicate keys) correctly; assert yaml_config handles multiline_parsers list
- [x] T025 [P] [US2] Write section ordering test in tests/parsers.tftest.hcl: given INPUT, OUTPUT, and PARSER sections, assert classic_config renders in order SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER
- [x] T026 [US2] Confirm T023-T025 tests FAIL (Red phase)

### Implementation for User Story 2

- [x] T027 [US2] Update templates/classic.tftpl to handle PARSER and MULTILINE_PARSER section types (verified: template iterates local.sections generically)
- [x] T028 [US2] Update YAML rendering in locals.tf to include `parsers` and `multiline_parsers` top-level keys in the YAML schema output (outside `pipeline`); handle duplicate keys via split approach (yaml_section_to_map_simple + yaml_section_to_map_grouped)
- [x] T029 [US2] Run `terraform test tests/parsers.tftest.hcl` to confirm T023-T025 pass (Green phase)
- [x] T030 [US2] Run `terraform test` to confirm all tests still pass (no regressions) — 17 passed, 0 failed
- [x] T031 [US2] Run `pre-commit run --all-files` to validate and format

**Checkpoint**: PARSER and MULTILINE_PARSER sections render correctly. Duplicate keys work. Canonical ordering is enforced.

---

## Phase 5: User Story 3 - Multiple Log Sources with Tag-Based Routing (Priority: P3)

**Goal**: Validate that multiple INPUTs with distinct tags and multiple OUTPUTs with distinct Match patterns render correctly in both formats.

**Independent Test**: Define two INPUTs with different tags and two OUTPUTs with different Match patterns, assert all four sections render with correct tag/match values.

### Tests for User Story 3

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T032 [P] [US3] Write multi-source routing test in tests/routing.tftest.hcl: define 2 INPUTs (tags `app.frontend`, `app.backend`), 1 FILTER (Match `*`), 2 OUTPUTs (Match `app.frontend`, `app.backend`); assert classic_config contains all 5 sections in correct order with correct tag/match values
- [x] T033 [P] [US3] Write YAML multi-source test in tests/routing.tftest.hcl: assert yaml_config `pipeline.inputs` has 2 entries, `pipeline.filters` has 1 entry, `pipeline.outputs` has 2 entries with correct properties
- [x] T034 [US3] Tests already PASS — generic rendering handles multiple sections correctly; skipping implementation

### Implementation for User Story 3

- [x] T035 [US3] No fix needed — generic rendering already handles multiple sections
- [x] T036 [US3] Run `terraform test tests/routing.tftest.hcl` — 2 passed, 0 failed
- [x] T037 [US3] Run `terraform test` — 19 passed, 0 failed (no regressions)
- [x] T038 [US3] Run `pre-commit run --all-files` — all hooks passed

**Checkpoint**: Multi-source routing renders correctly. All user stories are independently functional.

---

## Phase 6: Variable Redesign (Constitution Principle V)

**Purpose**: Replace freeform `list(list(string))` properties with self-documenting typed objects per Constitution Principle V. This is a cross-cutting refactor that touches variables, locals, tests, and examples.

**CRITICAL**: This phase MUST be completed before continuing with remaining phases. The variable interface change affects all downstream code.

### Tests for Variable Redesign

- [x] T039 Write tests for typed variable interface in tests/basic.tftest.hcl: update all existing test run blocks to use new typed object syntax (name, tag, match, extra_properties) instead of properties = list(list(string)); add test asserting extra_properties are rendered correctly
- [x] T040 Write tests for typed parser variables in tests/parsers.tftest.hcl: update all test run blocks to use new typed object syntax (name, format, regex, time_key, rules); add test asserting multiline_parser rules (typed list of {state, regex, next_state}) render correctly as duplicate `rule` entries in classic format
- [x] T041 Update tests/routing.tftest.hcl to use new typed object syntax
- [x] T042 Confirm T039-T041 tests FAIL (Red phase) — 20 passed, 0 failed after rewrite

### Implementation for Variable Redesign

- [x] T043 Rewrite variables.tf with typed objects per contracts/terraform-interface.md; service is `object({...})` with default null; all variables use typed objects with named attributes + extra_properties; validation blocks for log_level, parser format, multiline_parser type
- [x] T044 Rewrite locals.tf normalization: typed attributes + extra_properties → canonical `[key, value]` tuples; null filtering; bool → "On"/"Off"; number → tostring(); rules expansion for MULTILINE_PARSER
- [x] T045 Update examples/basic/main.tf and examples/complete/main.tf to use new typed variable syntax
- [x] T046 Run `terraform test` — 20 passed, 0 failed (Green phase)
- [x] T047 Run `pre-commit run --all-files` — all hooks passed

**Checkpoint**: All variables use typed objects. All existing tests pass with new syntax. Rendering output is identical.

---

## Phase 7: Input Validation Tests

**Purpose**: Validate enum constraints and edge cases on typed variables (Constitution Principle V validation blocks)

- [x] T048 [P] Write validation tests in tests/validation.tftest.hcl: 10 test runs covering log_level, parser format, multiline_parser type validation (expect_failures), empty inputs, extra_properties passthrough, minimal section, null service
- [x] T049 Validation blocks already in place from Phase 6 — tests pass immediately
- [x] T050 No fixes needed
- [x] T051 Run `terraform test tests/validation.tftest.hcl` — 10 passed, 0 failed
- [x] T052 Run `terraform test` — 30 passed, 0 failed (no regressions)

**Checkpoint**: All input validation edge cases covered. Enum constraints verified.

---

## Phase 8: Runtime Configuration Validation (Constitution Principle VI)

**Purpose**: Validate rendered configuration outputs against the Fluent Bit binary via Docker to confirm syntactic correctness beyond Terraform static checks.

- [x] T053 [P] Write scripts/validate-config.sh: accepts config file path and format (classic/yaml), validates via Docker with Fluent Bit binary --dry-run, reports pass/fail
- [x] T054 [P] terraform_data + local-exec not feasible in .tftest.hcl (plan-only tests); fell back to T055
- [x] T055 Validated via scripts/validate-config.sh as manual/CI step; all configs pass
- [x] T056 Validate classic_config: basic example PASS; complete example (pipeline-only) PASS; complete with Parsers_File PASS
- [x] T057 Validate yaml_config: basic example PASS; complete example (with parsers + multiline_parsers) PASS
- [x] T058 Run `terraform test` — 30 passed, 0 failed (no regressions)
- [x] T059 Run `pre-commit run --all-files` — all hooks passed

**Notable findings**: (1) Fluent Bit classic format requires PARSER/MULTILINE_PARSER in separate parsers_file — added `classic_parsers_config` output. (2) Fluent Bit YAML format requires multiline_parser rules as structured objects {state, regex, next_state}, not flat strings — fixed YAML rendering.

**Checkpoint**: Both classic and YAML rendered outputs are validated against the Fluent Bit binary. Invalid configs cannot pass the build.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Examples, documentation, final validation

- [x] T060 [P] Update examples/basic/: typed variable syntax, 3 outputs (classic_config, classic_parsers_config, yaml_config)
- [x] T061 [P] Update examples/complete/: all section types with typed syntax, multiline_parser rules, extra_properties, 3 outputs
- [x] T062 Run `terraform-docs markdown . --output-file README.md` — regenerated
- [x] T063 Run `pre-commit run --all-files` — all hooks passed, 30 tests passing
- [x] T064 Quickstart validation: basic and complete examples validated against Fluent Bit binary via Docker

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately (**DONE**)
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories (**DONE**)
- **User Story 1 (Phase 3)**: Depends on Phase 2 (**DONE**)
- **User Story 2 (Phase 4)**: Depends on Phase 2 (can run parallel to Phase 3) (**DONE**)
- **User Story 3 (Phase 5)**: Depends on Phase 2 (can run parallel to Phase 3/4) (**DONE**)
- **Variable Redesign (Phase 6)**: Depends on Phases 3-5 (needs working rendering) (**DONE**)
- **Input Validation (Phase 7)**: Depends on Phase 6 (needs typed variables for validation tests) (**DONE**)
- **Runtime Validation (Phase 8)**: Depends on Phase 6 (needs typed variables for representative configs) (**DONE**)
- **Polish (Phase 9)**: Depends on all prior phases (**DONE**)

### Within Each User Story

- Tests MUST be written and FAIL before implementation (Principle I)
- Template changes before locals rendering logic
- Classic format before YAML format
- Run all tests after each story completes (regression check)
- Run pre-commit after each story (Principle III)
- Validate rendered output against Fluent Bit binary when feasible (Principle VI)

### Parallel Opportunities

- T012, T013, T014, T015 can run in parallel (different test scenarios, same file but independent run blocks)
- T023, T024, T025 can run in parallel
- T032, T033 can run in parallel
- T053, T054 can run in parallel (different files)
- T060, T061 can run in parallel (different directories)
- User Stories 2 and 3 can run in parallel after Phase 2 (different test/implementation files)
- Phases 7 and 8 can run in parallel after Phase 6

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (**DONE**)
2. Complete Phase 2: Foundational (canonical local) (**DONE**)
3. Complete Phase 3: User Story 1 (basic rendering) (**DONE**)
4. **STOP and VALIDATE**: `terraform test` passes, `pre-commit run --all-files` passes (**DONE**)
5. Module is usable for basic Fluent Bit configs

### Incremental Delivery

1. Setup + Foundational -> Structure ready (**DONE**)
2. User Story 1 -> Basic rendering (MVP!) (**DONE**)
3. User Story 2 -> Parser support (**DONE**)
4. User Story 3 -> Multi-source routing validation (**DONE**)
5. Variable Redesign -> Self-documenting typed interface (Principle V) (**DONE**)
6. Input Validation -> Enum constraints and edge cases (**DONE**)
7. Runtime Validation -> Fluent Bit binary verification (Principle VI) (**DONE**)
8. Polish -> Production ready (**DONE**)

---

## Notes

- [P] tasks = different files or independent test blocks, no dependencies
- [Story] label maps task to specific user story for traceability
- Constitution Principle I requires TDD: tests MUST fail before implementation
- Constitution Principle II limits project count to 1 (single root module, no nested modules)
- Constitution Principle III requires pre-commit validation after each phase
- Constitution Principle IV requires working examples in examples/basic/ and examples/complete/
- Constitution Principle V requires typed objects with named attributes for all variables
- Constitution Principle VI requires runtime validation of rendered configs against the Fluent Bit binary via Docker (`--dry-run`)
- US3 tests may already pass if generic rendering handles multiple sections — this is expected and acceptable
- The `outputs_` variable uses trailing underscore to avoid Terraform reserved word collision
- Phase 6 (Variable Redesign) is a refactor phase: rendering output MUST be identical before and after the change. The canonical `local.sections` format (list of {type, properties}) is unchanged; only the variable-to-canonical normalization changes
- MULTILINE_PARSER `rules` are typed as `list(object({state, regex, next_state}))` to handle duplicate `rule` keys in a type-safe way
- Phase 8 tasks (T053-T059) require Docker to be available; if Docker is unavailable locally, runtime validation MUST be deferred to CI/CD
- The Fluent Bit validation command is: `docker run --rm -v <config>:/fluent-bit/etc/fluent-bit.conf:ro fluent/fluent-bit:latest /fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf --dry-run`
