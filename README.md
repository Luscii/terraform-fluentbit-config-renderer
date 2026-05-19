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

No modules.

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_filters"></a> [filters](#input\_filters) | List of Fluent Bit FILTER sections. Each entry defines a<br/>processing step (e.g., grep, modify, kubernetes). The name<br/>attribute specifies the plugin. Use match or match\_regex to<br/>select which records to process. Use extra\_properties for<br/>plugin-specific settings. | <pre>list(object({<br/>    name             = string<br/>    match            = optional(string, "*")<br/>    match_regex      = optional(string)<br/>    alias            = optional(string)<br/>    log_level        = optional(string)<br/>    extra_properties = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_inputs"></a> [inputs](#input\_inputs) | List of Fluent Bit INPUT sections. Each entry defines a data<br/>source (e.g., tail, forward, syslog). The name attribute<br/>specifies the plugin. Use extra\_properties for plugin-specific<br/>settings (e.g., Path for tail, Port for forward). | <pre>list(object({<br/>    name             = string<br/>    tag              = optional(string)<br/>    alias            = optional(string)<br/>    log_level        = optional(string)<br/>    mem_buf_limit    = optional(string)<br/>    storage_type     = optional(string)<br/>    routable         = optional(bool)<br/>    threaded         = optional(bool)<br/>    extra_properties = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_multiline_parsers"></a> [multiline\_parsers](#input\_multiline\_parsers) | List of Fluent Bit MULTILINE\_PARSER sections. Each entry<br/>defines a multiline log parser with state machine rules. The<br/>type attribute must be one of: regex, endswith, equal.<br/>Rules define state transitions: state is the current state<br/>name (first rule must use "start\_state"), regex is the match<br/>pattern, and next\_state is the target state. | <pre>list(object({<br/>    name          = string<br/>    type          = string<br/>    parser        = optional(string)<br/>    key_content   = optional(string)<br/>    flush_timeout = optional(string)<br/>    rules = optional(list(object({<br/>      state      = string<br/>      regex      = string<br/>      next_state = string<br/>    })), [])<br/>    extra_properties = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_outputs_"></a> [outputs\_](#input\_outputs\_) | List of Fluent Bit OUTPUT sections. Each entry defines a<br/>destination (e.g., cloudwatch\_logs, s3, stdout). The name<br/>attribute specifies the plugin. Use match or match\_regex to<br/>select which records to send. Use extra\_properties for<br/>plugin-specific settings (e.g., region, log\_group\_name). | <pre>list(object({<br/>    name             = string<br/>    match            = optional(string, "*")<br/>    match_regex      = optional(string)<br/>    alias            = optional(string)<br/>    log_level        = optional(string)<br/>    retry_limit      = optional(string)<br/>    workers          = optional(number)<br/>    extra_properties = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_parsers"></a> [parsers](#input\_parsers) | List of Fluent Bit PARSER sections. Each entry defines a log<br/>parser. The format attribute must be one of: json, regex,<br/>ltsv, logfmt. When format is "regex", the regex attribute is<br/>required. Use extra\_properties for less common settings like<br/>Decode\_Field, Skip\_Empty\_Values, etc. | <pre>list(object({<br/>    name             = string<br/>    format           = string<br/>    regex            = optional(string)<br/>    time_key         = optional(string)<br/>    time_format      = optional(string)<br/>    time_keep        = optional(bool)<br/>    time_offset      = optional(string)<br/>    types            = optional(string)<br/>    extra_properties = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_service"></a> [service](#input\_service) | Fluent Bit SERVICE section. Controls global engine behavior.<br/>At most one SERVICE section is allowed per configuration.<br/>Use extra\_properties for less common settings like daemon,<br/>dns.mode, scheduler.*, storage.sync, etc. | <pre>object({<br/>    flush            = optional(string)<br/>    grace            = optional(number)<br/>    log_level        = optional(string, "info")<br/>    log_file         = optional(string)<br/>    http_server      = optional(string)<br/>    http_listen      = optional(string)<br/>    http_port        = optional(number)<br/>    parsers_file     = optional(string)<br/>    storage_path     = optional(string)<br/>    extra_properties = optional(map(string), {})<br/>  })</pre> | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_classic_config"></a> [classic\_config](#output\_classic\_config) | Rendered Fluent Bit main configuration in classic INI-style format (SERVICE, INPUT, FILTER, OUTPUT sections). |
| <a name="output_classic_parsers_config"></a> [classic\_parsers\_config](#output\_classic\_parsers\_config) | Rendered Fluent Bit parsers configuration in classic INI-style format (PARSER, MULTILINE\_PARSER sections). Must be saved as a separate file referenced by parsers\_file in the SERVICE section. |
| <a name="output_yaml_config"></a> [yaml\_config](#output\_yaml\_config) | Rendered Fluent Bit configuration in YAML format (all sections in one file). |
<!-- END_TF_DOCS -->
