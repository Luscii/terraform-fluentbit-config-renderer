---
name: terraform-regex-patterns
description: 'Provides regex patterns, syntax, flags, and usage examples for Terraform regex functions: regex, regexall, and replace. Use this skill when asked about regular expressions, pattern matching, or string replacement in Terraform code.'
---

# Terraform Regex Patterns Skill

## Overview

This skill provides a curated set of regular expression (regex) patterns and usage examples for use with Terraform's built-in regex functions:
- `regex(pattern, string)`
- `regexall(pattern, string)`
- `replace(string, substring/pattern, replacement)`

It also covers syntax, sequences, and flags as documented in the [Terraform regex function documentation](https://developer.hashicorp.com/terraform/language/functions/regex).

---

## Syntax and Flags


Terraform uses [RE2 syntax](https://github.com/google/re2/wiki/Syntax). Flags are set inline in the pattern, e.g. `(?i)` for case-insensitive.

### Sequences

| Sequence         | Description                                                      |
|------------------|------------------------------------------------------------------|
| `.`              | any character except newline                                     |
| `^`              | start of string                                                  |
| `$`              | end of string                                                    |
| `*`              | zero or more                                                     |
| `+`              | one or more                                                      |
| `?`              | zero or one                                                      |
| `[...]`          | character class                                                  |
| `[xyz]`          | any character listed between the brackets (`x`, `y`, `z`)        |
| `[^xyz]`         | any character except those listed between the brackets           |
| `(...)`          | capture group                                                    |
| `\d`             | ASCII digits `[0-9]`                                             |
| `\D`             | anything except ASCII digits                                     |
| `\w`             | word character `[0-9A-Za-z_]`                                    |
| `\W`             | anything except the characters matched by `\w`                   |
| `\s`             | whitespace                                                       |
| `[[:alnum:]]`    | same as `[0-9A-Za-z]`                                            |
| `[[:alpha:]]`    | same as `[A-Za-z]`                                               |
| `[[:ascii:]]`    | any ASCII character                                              |
| `[[:blank:]]`    | ASCII tab or space                                               |
| `[[:cntrl:]]`    | ASCII/Unicode control characters                                 |
| `[[:digit:]]`    | same as `[0-9]`                                                  |
| `[[:graph:]]`    | all "graphical" (printable) ASCII characters                     |
| `[[:lower:]]`    | same as `[a-z]`                                                  |
| `[[:print:]]`    | same as `[[:graph:]]`                                            |
| `[[:punct:]]`    | same as `[!-/:-@[-`{-~]`                                         |
| `[[:space:]]`    | same as `[\t\n\v\f\r ]`                                          |
| `[[:upper:]]`    | same as `[A-Z]`                                                  |
| `[[:word:]]`     | same as `\w`                                                     |
| `[[:xdigit:]]`   | same as `[0-9A-Fa-f]`                                            |

### Flags
Some of the matching behaviors described above can be modified by setting matching flags, activated using either the (?flags) operator (to activate within the current sub-pattern) or the (?flags:x) operator (to match x with the modified flags). Each flag is a single letter, and multiple flags can be set at once by listing multiple letters in the flags position. The available flags are listed in the table below:

| Flag | Meaning |
| `i` | Case insensitive: a literal letter in the pattern matches both lowercase and uppercase versions of that letter |
| `m` | The ^ and $ operators also match the beginning and end of lines within the string, marked by newline characters; behavior of `\A` and `\z` is unchanged |
| `s` | The `.` operator also matches newline |
| `U` | The meaning of presence or absense `?` after a repetition operator is inverted. For example, `x*` is interpreted like `x*?` and vice-versa. |

---

## Usage Examples

### Validate Email Address
```hcl
regex("^[\w._%+-]+@[\w.-]+\\.[a-zA-Z]{2,}$", var.email)
```

### Extract Digits from String
```hcl
regexall("\\d+", var.input)
```

### Replace All Whitespace with Dash
```hcl
replace(var.input, "\\s+", "-")
```

### Match AWS ARN
```hcl
regex("^arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]*:.*$", var.arn)
```

### Case-Insensitive Match
```hcl
regex("(?i)^prod$", var.env)
```

### Extract Lowercase Letters from String
```hcl
regex("[a-z]+", "53453453.345345aaabbbccc23454")
# returns: aaabbbccc
```

### Extract Date Parts from String
```hcl
regexall("\\d+", "2019-02-01")
# returns: ["2019", "02", "01"]
```

### Parse URL Scheme and Authority
```hcl
regex("^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?", "https://terraform.io/docs/")
# returns: { "authority" = "terraform.io", "scheme" = "https" }
```

### Error: Pattern Did Not Match
```hcl
regex("[a-z]+", "53453453.34534523454")
# error: pattern did not match any part of the given string
```

---

## Pattern Library

| Pattern | Description | Example |
|---------|-------------|---------|
| `^prod$` | Exact match for "prod" | `regex("^prod$", var.env)` |
| `(?i)^dev$` | Case-insensitive "dev" | `regex("(?i)^dev$", var.env)` |
| `^\d{4}-\d{2}-\d{2}$` | Date YYYY-MM-DD | `regex("^\d{4}-\d{2}-\d{2}$", var.date)` |
| `^[a-zA-Z0-9_-]+$` | Alphanumeric, dash, underscore | `regex("^[a-zA-Z0-9_-]+$", var.name)` |
| `^arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]*:.*$` | AWS ARN | `regex("^arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]*:.*$", var.arn)` |
| `(?i)error|fail|critical` | Match error keywords (case-insensitive) | `regex("(?i)error|fail|critical", var.log)` |
| `^\s*$` | Empty or whitespace | `regex("^\s*$", var.input)` |

---

## References
- [Terraform regex function](https://developer.hashicorp.com/terraform/language/functions/regex)
- [RE2 syntax](https://github.com/google/re2/wiki/Syntax)

---

## How to Use
- Use these patterns directly in `regex`, `regexall`, or `replace` functions in Terraform.
- Adjust patterns as needed for your use case.
- For complex validation, combine multiple patterns or use `regexall` for all matches.
