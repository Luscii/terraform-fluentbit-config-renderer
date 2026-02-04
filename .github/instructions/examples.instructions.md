---
applyTo: "examples/**/*,README.md"
---

# Terraform Module Examples Instructions

## Quick Reference

**When creating examples:**
- README must include: Minimal Setup + Advanced Setup
- Examples directory structure: `examples/{basic,complete,scenario}/`
- Each example needs: main.tf, variables.tf, outputs.tf, versions.tf, README.md
- Use `source = "../../"` for local module references
- Test all examples: `terraform init`, `terraform validate`, `terraform plan`
- Document purpose, prerequisites, and cleanup in example README

**Cross-references:**
- Example templates, file structure, patterns → Use the **terraform-examples** skill
- README documentation → [documentation.instructions.md](./documentation.instructions.md)
- Terraform code style → [terraform.instructions.md](./terraform.instructions.md)
- Visual diagrams → Use the **mermaid-diagrams** skill for workflow diagrams and example visualizations

---

## Overview

Examples are a critical part of module documentation, demonstrating real-world usage patterns and helping users quickly understand how to implement the module. This guide covers the workflow and decision-making for creating examples. For technical templates and patterns, see the **terraform-examples** skill.

## When to Create Examples

**Decision Matrix:**

### Inline Examples Only (No examples/ directory)
- ✅ Simple module with single use case
- ✅ All variations fit in 30-100 lines
- ✅ Documentation changes only
- ✅ Minor bug fixes
- ✅ No distinct scenarios needed

### Examples Directory Required
- ✅ Module supports multiple distinct use cases
- ✅ Configurations too complex for inline (>100 lines)
- ✅ New features added
- ✅ Users benefit from complete, runnable configurations
- ✅ Testing requires full examples

## Main README.md Examples

**See [documentation.instructions.md](./documentation.instructions.md) for README structure and formatting.**
**See the **terraform-examples** skill for example templates and code patterns.**

The Examples section in the main README.md must contain:

### 1. Minimal Setup (Required)

**Purpose:**
- Help users get started quickly
- Show only required variables
- Demonstrate the simplest use case
- Serve as a starting point for customization

**Template available in terraform-examples skill**

**Best Practices:**
- Include all required variables
- Use sensible default values
- Show context integration (CloudPosse label)
- Keep it under 30 lines when possible
- Avoid optional features
- Use realistic but generic values

### 2. Extended/Advanced Setup (Required)

**Purpose:**
- Demonstrate real-world usage
- Show integration with other resources
- Highlight important optional features
- Provide a production-ready example

**Template available in terraform-examples skill**

**Best Practices:**
- Show realistic production configurations
- Demonstrate module output usage
- Include integration with related resources
- Show CloudPosse label context usage
- Include comments for complex configurations
- Demonstrate multiple features working together
- Keep it under 100 lines when possible

### 3. Additional Scenario Examples (Optional)

For modules with distinct use cases, provide additional inline examples.

**Template available in terraform-examples skill**

## Examples Directory Structure

**When to Create an Examples Directory:**
- Module supports multiple distinct use cases
- Configurations are too complex for inline examples
- You want to provide tested, working examples
- Users benefit from seeing complete, runnable configurations

**Standard Structure:**

See **terraform-examples** skill for complete directory structure and file templates.

```
examples/
├── README.md           # Overview of all examples
├── basic/              # Minimal working example
├── complete/           # Full-featured example
└── {scenario}/         # Use-case specific example
```

### Common Scenario Directories

**See terraform-examples skill for complete list and templates.**

Create separate directories for common use cases based on module type:
- ECS Service: with-load-balancer/, service-connect-only/, etc.
- Load Balancer: public-alb/, internal-alb/, with-waf/
- Secrets: new-secrets/, existing-secrets/, mixed/

## Workflow

### Creating Examples

1. **Determine Need:**
   - Review decision matrix above
   - Check if inline examples sufficient
   - Identify distinct use cases

2. **Plan Structure:**
   - List required examples (basic, complete, scenarios)
   - Map scenarios to example directories
   - Identify shared prerequisites

3. **Create Examples:**
   - Use templates from **terraform-examples** skill
   - Start with basic, then complete
   - Add scenario-specific examples
   - Ensure all 5 files per example

4. **Test Examples:**
   - Run `terraform init` in each directory
   - Run `terraform validate`
   - Run `terraform fmt`
   - Run `terraform plan` (should succeed)
   - Optionally run `terraform apply` to verify

5. **Document:**
   - Create example-specific README.md
   - Create examples/README.md with navigation
   - Update main README.md if needed

6. **Validate:**
   - Use example checklist below
   - Review all files present
   - Verify source references correct

### Example Checklist

Before finalizing an example:

- [ ] Example has clear, specific purpose
- [ ] All required files present (main.tf, variables.tf, outputs.tf, versions.tf, README.md)
- [ ] Code formatted (`terraform fmt`)
- [ ] Code validates (`terraform validate`)
- [ ] Variables have descriptions and sensible defaults
- [ ] Outputs documented
- [ ] README explains purpose, usage, cleanup
- [ ] Prerequisites documented
- [ ] Example tested
- [ ] Module source reference correct (`source = "../../"`)
- [ ] Version constraints specified
- [ ] Comments explain non-obvious choices

## Best Practices

### Do's

✅ **Follow standard structure** - Use consistent file and directory names
✅ **Test thoroughly** - All examples must work (init, validate, plan)
✅ **Document completely** - Clear purpose, usage, prerequisites, cleanup
✅ **Keep realistic** - Production-like configurations and values
✅ **Stay current** - Update when module changes
✅ **Use templates** - Follow patterns from **terraform-examples** skill
✅ **Provide defaults** - Sensible defaults for easy testing
✅ **Show integration** - Demonstrate output usage and resource connections

### Don'ts

❌ **Don't create placeholders** - Every example must be complete and working
❌ **Don't overcomplicate** - Keep focused on specific use case
❌ **Don't skip documentation** - Always explain purpose and usage
❌ **Don't hardcode** - Use variables for customizable values
❌ **Don't skip context** - Always show CloudPosse label integration
❌ **Don't commit untested** - Run at least terraform plan
❌ **Don't mix concerns** - One example = one use case
❌ **Don't duplicate** - Share patterns via examples/README.md
