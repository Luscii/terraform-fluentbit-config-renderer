# terraform-module-template

Template repository for creating standardized Terraform modules following Luscii conventions.

## Features

- ✅ **CloudPosse Label Integration** - Consistent resource naming and tagging
- ✅ **TDD Workflow** - Test-driven development with Gherkin scenarios
- ✅ **Complete Examples** - Basic and complete usage examples
- ✅ **Comprehensive Testing** - Terraform native tests with mocking support
- ✅ **Agent Orchestration** - Intelligent workflow with handoffs and feedback loops
- ✅ **Documentation Standards** - terraform-docs integration
- ✅ **Pre-commit Hooks** - Automated validation and formatting

## Quick Start

### Use as Template

1. Click "Use this template" on GitHub
2. Create new repository with pattern: `terraform-{provider}-{name}`
3. Clone and customize for your module

### Using This Module

```terraform
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "luscii"
  environment = "production"
  name        = "example"
}

module "example" {
  source = "github.com/Luscii/terraform-module-template"

  name = module.label.name

  context = module.label.context
}
```

## Examples

### Minimal Setup

```terraform
module "basic" {
  source = "github.com/Luscii/terraform-module-template"

  name = "my-resource"

  context = module.label.context
}
```

### Advanced Setup

For complete examples with all features, see [examples/](./examples/).

## Development Workflow

### Test-Driven Development

1. **Create Feature Scenarios** (`docs/features/`)
   ```bash
   # AI agent: scenario-shaper
   ```

2. **Generate Tests** (`tests/*.tftest.hcl`)
   ```bash
   # AI agent: terraform-tester
   ```

3. **Implement Module** (`main.tf`, `*.tf`)
   ```bash
   # AI agent: terraform-module-specialist
   terraform test  # Validate implementation
   ```

4. **Create Documentation** (`README.md`, descriptions)
   ```bash
   # AI agent: documentation-specialist
   terraform-docs markdown . --output-file README.md
   ```

5. **Build Examples** (`examples/`)
   ```bash
   # AI agent: examples-specialist
   ```

### Pre-commit Hooks

```bash
# Install pre-commit
brew install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## Directory Structure

```
terraform-{provider}-{name}/
├── .github/
│   ├── agents/              # AI agent specifications
│   ├── instructions/        # Development standards
│   └── workflows/           # CI/CD pipelines
├── docs/
│   ├── adr/                 # Architecture Decision Records
│   └── features/            # Gherkin feature files
├── examples/
│   ├── basic/               # Minimal example
│   └── complete/            # Full-featured example
├── tests/                   # Terraform tests
├── main.tf                  # Primary resources
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── versions.tf              # Version constraints
├── README.md                # This file
└── LICENSE                  # License information
```

## Standards and Instructions

All development follows standards in `.github/instructions/`:

- **terraform.instructions.md** - Terraform code standards
- **documentation.instructions.md** - Documentation guidelines
- **examples.instructions.md** - Example creation
- **terraform-tests.instructions.md** - Testing guide
- **file-structure.instructions.md** - Module organization
- **adr.instructions.md** - ADR documentation

## Agent Workflow

### Happy Path (Automatic)
```
implementation-plan → scenario-shaper → terraform-tester →
terraform-module-specialist → documentation-specialist → examples-specialist
```

### Feedback Loops (Manual/Conditional)
- Module ↔ Tester (test adjustments)
- Module → Scenario (scenario issues)
- Module → Plan (critical architecture issues)
- Docs → Module (documentation gaps)
- Examples → Module (module issues)

## Configuration

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource to be labeled. This is used to generate the label key and value. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_label_context"></a> [label\_context](#output\_label\_context) | Context of the label for subsequent use |
<!-- END_TF_DOCS -->
