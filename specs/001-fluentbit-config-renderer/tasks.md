# Tasks: Fluent Bit Configuration Renderer

**Input**: Design documents from `/specs/001-fluentbit-config-renderer/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Required by constitution Principle I (Test-First Imperative). Tests MUST be written and FAIL before implementation.

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

- [ ] T001 Remove existing placeholder main.tf, variables.tf, outputs.tf content and replace with empty shells per plan structure
- [ ] T002 Create versions.tf with `terraform { required_version = ">= 1.3" }` (no required_providers block — pure rendering module)
- [ ] T003 Create templates/ directory with empty classic.tftpl file at templates/classic.tftpl
- [ ] T004 Define all input variables in variables.tf: service, inputs, filters, outputs_, parsers, multiline_parsers (each as `list(object({ properties = list(list(string)) }))` with default `[]`)
- [ ] T005 Add validation block to service variable in variables.tf: `length(var.service) <= 1`
- [ ] T006 Define outputs in outputs.tf: classic_config and yaml_config (initially empty string values)

**Checkpoint**: Module structure exists, `terraform init && terraform validate` passes with all variables defaulting to empty.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Canonical local that normalizes all input variables into a single ordered list of sections. This MUST be complete before any rendering work.

**CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T007 Write test for canonical sections local in tests/basic.tftest.hcl: given service, inputs, filters, outputs_, parsers, multiline_parsers variables, assert local.sections produces a flat list of objects with `type` and `properties` fields in canonical order (SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER)
- [ ] T008 Confirm T007 test FAILS (Red phase)
- [ ] T009 Implement canonical sections local in locals.tf: build `local.sections` as a flat ordered list from all input variables, each entry tagged with its section type string
- [ ] T010 Run `terraform test tests/basic.tftest.hcl` to confirm T007 passes (Green phase)
- [ ] T011 Run `pre-commit run --all-files` to validate and format

**Checkpoint**: `local.sections` produces correct canonical ordering. All downstream rendering consumes this single local.

---

## Phase 3: User Story 1 - Render a Basic Fluent Bit Configuration (Priority: P1)

**Goal**: Render SERVICE, INPUT, FILTER, OUTPUT sections in classic INI-style format via `templatefile()` and in YAML format.

**Independent Test**: Provide minimal inputs (one INPUT, one OUTPUT) and assert rendered outputs match valid Fluent Bit syntax in both formats.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T012 [P] [US1] Write classic format rendering tests in tests/basic.tftest.hcl: assert classic_config output contains `[SERVICE]` block with indented key-value pairs when service variable provided; assert `[INPUT]` and `[OUTPUT]` blocks render correctly; assert empty input produces empty string; assert per-section key alignment
- [ ] T013 [P] [US1] Write YAML format rendering tests in tests/basic.tftest.hcl: assert yaml_config output contains `service:` mapping, `pipeline:` with `inputs:` and `outputs:` lists when variables provided; assert empty input produces empty string
- [ ] T014 [P] [US1] Write omission tests in tests/basic.tftest.hcl: assert no `[SERVICE]` header when service is empty; assert no `pipeline.filters` key in YAML when filters is empty
- [ ] T015 [P] [US1] Write ordering test in tests/basic.tftest.hcl: assert multiple OUTPUT sections render in input order in classic_config
- [ ] T016 [US1] Confirm T012-T015 tests FAIL (Red phase)

### Implementation for User Story 1

- [ ] T017 [US1] Create classic format template at templates/classic.tftpl: iterate over sections list, render `[TYPE]` header, indent each property key-value pair with 4 spaces, align keys per-section to longest key width, separate sections with blank line
- [ ] T018 [US1] Implement classic_config rendering in locals.tf: use `templatefile("${path.module}/templates/classic.tftpl", { sections = local.sections })` to produce `local.classic_config`
- [ ] T019 [US1] Implement yaml_config rendering in locals.tf: transform `local.sections` into Fluent Bit YAML schema structure (`service` map, `pipeline.inputs`/`filters`/`outputs` lists) and render via `yamlencode()`; store as `local.yaml_config`
- [ ] T020 [US1] Wire outputs in outputs.tf: set classic_config value to `local.classic_config`, yaml_config to `local.yaml_config`
- [ ] T021 [US1] Run `terraform test tests/basic.tftest.hcl` to confirm T012-T015 pass (Green phase)
- [ ] T022 [US1] Run `pre-commit run --all-files` to validate and format

**Checkpoint**: Basic rendering works for SERVICE, INPUT, FILTER, OUTPUT in both classic and YAML formats. Module is independently usable.

---

## Phase 4: User Story 2 - Render PARSER and MULTILINE_PARSER Sections (Priority: P2)

**Goal**: Extend rendering to PARSER and MULTILINE_PARSER sections, including duplicate key support (e.g., `rule` entries).

**Independent Test**: Provide PARSER and MULTILINE_PARSER definitions and assert correct rendering in both formats, including canonical section ordering.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T023 [P] [US2] Write PARSER rendering tests in tests/parsers.tftest.hcl: assert classic_config contains `[PARSER]` block with Name, Format, Time_Key properties; assert yaml_config contains `parsers:` list with correct entries
- [ ] T024 [P] [US2] Write MULTILINE_PARSER tests in tests/parsers.tftest.hcl: assert classic_config renders multiple `rule` entries (duplicate keys) correctly; assert yaml_config handles multiline_parsers list
- [ ] T025 [P] [US2] Write section ordering test in tests/parsers.tftest.hcl: given INPUT, OUTPUT, and PARSER sections, assert classic_config renders in order SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER
- [ ] T026 [US2] Confirm T023-T025 tests FAIL (Red phase)

### Implementation for User Story 2

- [ ] T027 [US2] Update templates/classic.tftpl to handle PARSER and MULTILINE_PARSER section types (should already work if template iterates local.sections generically — verify and fix if needed)
- [ ] T028 [US2] Update YAML rendering in locals.tf to include `parsers` and `multiline_parsers` top-level keys in the YAML schema output (outside `pipeline`)
- [ ] T029 [US2] Run `terraform test tests/parsers.tftest.hcl` to confirm T023-T025 pass (Green phase)
- [ ] T030 [US2] Run `terraform test` to confirm all tests still pass (no regressions)
- [ ] T031 [US2] Run `pre-commit run --all-files` to validate and format

**Checkpoint**: PARSER and MULTILINE_PARSER sections render correctly. Duplicate keys work. Canonical ordering is enforced.

---

## Phase 5: User Story 3 - Multiple Log Sources with Tag-Based Routing (Priority: P3)

**Goal**: Validate that multiple INPUTs with distinct tags and multiple OUTPUTs with distinct Match patterns render correctly in both formats.

**Independent Test**: Define two INPUTs with different tags and two OUTPUTs with different Match patterns, assert all four sections render with correct tag/match values.

### Tests for User Story 3

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T032 [P] [US3] Write multi-source routing test in tests/routing.tftest.hcl: define 2 INPUTs (tags `app.frontend`, `app.backend`), 1 FILTER (Match `*`), 2 OUTPUTs (Match `app.frontend`, `app.backend`); assert classic_config contains all 5 sections in correct order with correct tag/match values
- [ ] T033 [P] [US3] Write YAML multi-source test in tests/routing.tftest.hcl: assert yaml_config `pipeline.inputs` has 2 entries, `pipeline.filters` has 1 entry, `pipeline.outputs` has 2 entries with correct properties
- [ ] T034 [US3] Confirm T032-T033 tests FAIL (Red phase) — if they already pass (because generic rendering handles this), mark as PASS and skip implementation

### Implementation for User Story 3

- [ ] T035 [US3] If T032-T033 failed: investigate and fix rendering logic in locals.tf and templates/classic.tftpl to handle multiple instances of the same section type
- [ ] T036 [US3] Run `terraform test tests/routing.tftest.hcl` to confirm T032-T033 pass (Green phase)
- [ ] T037 [US3] Run `terraform test` to confirm all tests still pass (no regressions)
- [ ] T038 [US3] Run `pre-commit run --all-files` to validate and format

**Checkpoint**: Multi-source routing renders correctly. All user stories are independently functional.

---

## Phase 6: Validation Tests

**Purpose**: Input validation edge cases

- [ ] T039 [P] Write validation tests in tests/validation.tftest.hcl: assert service variable rejects lists with more than 1 entry (expect_failures); assert empty properties list renders section header only; assert special characters in property values pass through unescaped
- [ ] T040 Confirm T039 tests FAIL (Red phase)
- [ ] T041 Fix any validation issues discovered (if needed) in variables.tf or locals.tf
- [ ] T042 Run `terraform test tests/validation.tftest.hcl` to confirm T039 passes (Green phase)
- [ ] T043 Run `terraform test` to confirm all tests pass

**Checkpoint**: All input validation edge cases covered.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Examples, documentation, final validation

- [ ] T044 [P] Update examples/basic/ to demonstrate minimal usage (1 INPUT + 1 OUTPUT) without CloudPosse label module, showing both classic_config and yaml_config outputs
- [ ] T045 [P] Update examples/complete/ to demonstrate all section types (SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER) with multiple entries and duplicate keys
- [ ] T046 Run `terraform-docs markdown . --output-file README.md` to regenerate documentation
- [ ] T047 Run `pre-commit run --all-files` for final validation
- [ ] T048 Run quickstart.md validation: apply the quickstart example and verify output matches expected classic and YAML config

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2
- **User Story 2 (Phase 4)**: Depends on Phase 2 (can run parallel to Phase 3)
- **User Story 3 (Phase 5)**: Depends on Phase 2 (can run parallel to Phase 3/4)
- **Validation (Phase 6)**: Depends on Phase 3 (needs rendering logic)
- **Polish (Phase 7)**: Depends on all user story phases

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Template changes before locals rendering logic
- Classic format before YAML format
- Run all tests after each story completes (regression check)
- Run pre-commit after each story

### Parallel Opportunities

- T012, T013, T014, T015 can run in parallel (different test scenarios, same file but independent run blocks)
- T023, T024, T025 can run in parallel
- T032, T033 can run in parallel
- T044, T045 can run in parallel
- User Stories 2 and 3 can run in parallel after Phase 2 (different test/implementation files)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (canonical local)
3. Complete Phase 3: User Story 1 (basic rendering)
4. **STOP and VALIDATE**: `terraform test` passes, `pre-commit run --all-files` passes
5. Module is usable for basic Fluent Bit configs

### Incremental Delivery

1. Setup + Foundational -> Structure ready
2. User Story 1 -> Basic rendering (MVP!)
3. User Story 2 -> Parser support
4. User Story 3 -> Multi-source routing validation
5. Validation + Polish -> Production ready

---

## Notes

- [P] tasks = different files or independent test blocks, no dependencies
- [Story] label maps task to specific user story for traceability
- Constitution Principle I requires TDD: tests MUST fail before implementation
- Constitution Principle III requires pre-commit validation after each phase
- US3 tests may already pass if generic rendering handles multiple sections — this is expected and acceptable
- The `outputs_` variable uses trailing underscore to avoid Terraform reserved word collision
