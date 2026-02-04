# Examples

This directory contains examples demonstrating various ways to use this module.

## Available Examples

### [Basic Example](./basic/)

Minimal configuration showing the essential inputs required to use this module.

**Use this when:** You want the simplest possible setup to get started.

**Demonstrates:**
- Required variables only
- Minimal working configuration
- Basic module usage
- CloudPosse label integration

---

### [Complete Example](./complete/)

Full-featured configuration demonstrating all major features and optional parameters.

**Use this when:** You need a production-ready configuration with common features.

**Demonstrates:**
- All important optional features
- Integration with CloudPosse label module
- Output usage
- Production best practices
- Advanced tagging

---

## Running Examples

Each example is self-contained. To run an example:

```bash
cd {example-directory}
terraform init
terraform plan
terraform apply
```

## Prerequisites

Common prerequisites for all examples:

- Terraform >= 1.3
- AWS Provider >= 6.0
- Valid AWS credentials configured

## Cleaning Up

To remove resources created by an example:

```bash
cd {example-directory}
terraform destroy
```
