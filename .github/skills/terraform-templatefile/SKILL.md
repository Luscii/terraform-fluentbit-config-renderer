---
name: terraform-templatefile
description: 'Comprehensive guide and examples for using templatefile() and string templates in Terraform. Use this skill when asked about dynamic file generation, string interpolation, or template syntax in Terraform.'
---


# Terraform Templatefile Skill

> **Note:** For a comprehensive overview of Terraform HCL syntax—including string interpolation, heredocs, template expressions, directives, and formatting—see the [terraform-syntax skill](/.github/skills/terraform-syntax/SKILL.md). Many syntax rules and best practices for templates are covered there and apply directly to templatefile usage.

## When to Use This Skill

- You want to generate files dynamically in Terraform (e.g., config, scripts, policies)
- You use the `templatefile()` function
- You want to apply string templates, interpolation, or conditional logic in templates
- You are looking for examples of template syntax, directives, or whitespace stripping
- If you want to generate a lot of files in a single directory, you can use the [hashicorp/dir/template](https://registry.terraform.io/modules/hashicorp/dir/template/latest) module with template capabilities.

## Content




### 1. templatefile() function

The [templatefile()](https://developer.hashicorp.com/terraform/language/functions/templatefile) function reads an external file and fills in variables:

```hcl
templatefile(path, vars)
```

- `path`: path to the template file (recommended extension: `.tftpl`)
- `vars`: map of variables used in the template

> **Naming convention:** Use the `.tftpl` extension for Terraform template files. This makes it clear that the file is a Terraform template and improves editor support and discoverability.

**Example:**
```hcl
data "template_file" "example" {
	template = file("${path.module}/example.tftpl")
	vars = {
		name = var.name
		port = var.port
	}
}

# Or with templatefile():
output "rendered" {
	value = templatefile("${path.module}/example.tftpl", {
		name = var.name
		port = var.port
	})
}
```

### 2. String Templates & Interpolation

See [string templates](https://developer.hashicorp.com/terraform/language/expressions/strings#string-templates).

- Variables: `${var.name}`
- Expressions: `${1 + 2}`
- Functions: `${upper(var.env)}`

**Example template.tpl:**
```text
server_name = "${name}"
listen_port = ${port}
env = "${upper(env)}"
```

### 3. Directives

See [directives](https://developer.hashicorp.com/terraform/language/expressions/strings#directives).

- `%{if condition}` ... `%{else}` ... `%{endif}`
- `%{for item in list}` ... `%{endfor}`

**Example:**
```text
%{if enable_tls}
tls_enabled = true
%{else}
tls_enabled = false
%{endif}

servers = [
%{ for s in servers ~}
	"${s}",
%{ endfor ~}
]
```

### 4. Whitespace Stripping


See [whitespace stripping](https://developer.hashicorp.com/terraform/language/expressions/strings#whitespace-stripping).

- Use `~` after `%{` or before `}` to remove whitespace.

**Standard for whitespace trimming:**

- `%{~ for ...}`
- `%{~ if ...}`
- `%{ endif ~}`
- `%{ endfor ~}`

This ensures consistent and minimal whitespace in rendered templates, especially for YAML/JSON output.

**Example:**
```text
%{~ for s in servers ~}
	"${s}",
%{ endfor ~}
```

### 5. Best Practices

- Use clear variable names in your template
- Keep templates as generic as possible
- Test templates with `terraform console` or outputs
- Document which variables are expected

> **Tip:** If you need to generate JSON or YAML output, it is often better to use the built-in `jsonencode()` or `yamlencode()` functions instead of writing JSON/YAML syntax manually in a string template. This avoids formatting errors and ensures valid output.

### 6. Common Pitfalls

- Forgetting to include variables in the vars map
- Syntax errors in directives (`%{if ...}`)
- Whitespace issues in YAML/JSON output

### 7. Extra Examples

**Complex template with for/if:**
```text
users = [
%{ for u in users ~}
	{
		name = "${u.name}"
		admin = %{if u.is_admin}true%{else}false%{endif}
	},
%{ endfor ~}
]
```

**Templatefile in resource:**
```hcl
resource "local_file" "config" {
	content  = templatefile("${path.module}/config.tpl", {
		users = var.users
	})
	filename = "${path.module}/rendered.conf"
}
```

### 8. Using the hashicorp/dir/template Module

The [hashicorp/dir/template](https://registry.terraform.io/modules/hashicorp/dir/template/latest) module allows you to render all template files in a directory using Terraform's string template syntax.

- By default, any file in the base directory whose filename ends in `.tmpl` is interpreted as a template.
- You can override the suffix by setting the variable `template_file_suffix` to any string that starts with a period and is followed by one or more non-period characters (e.g., `.tftpl`).
- Templates use Terraform's string template syntax and can use any built-in function except `templatefile` (which is used internally by the module).
- Files without the template file suffix are treated as static files and their local path is returned.

**Example usage:**
```hcl
module "render_templates" {
	source = "hashicorp/dir/template"
	base_dir = "${path.module}/templates"
	template_file_suffix = ".tftpl" # recommended
	vars = {
		name = var.name
		port = var.port
	}
}
```

> **Tip:** Use `.tftpl` as the template file suffix for consistency with the recommended convention in this skill.

---

## References
- [templatefile() function](https://developer.hashicorp.com/terraform/language/functions/templatefile)
- [String templates](https://developer.hashicorp.com/terraform/language/expressions/strings#string-templates)
- [Directives](https://developer.hashicorp.com/terraform/language/expressions/strings#directives)
- [Whitespace stripping](https://developer.hashicorp.com/terraform/language/expressions/strings#whitespace-stripping)
- [terraform-syntax skill](/.github/skills/terraform-syntax)
- [terraform instructions](/.github/instructions/terraform.instructions.md)
