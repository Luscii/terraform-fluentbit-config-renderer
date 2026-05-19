# Quickstart: Fluent Bit Configuration Renderer

## Minimal Usage (Classic Format)

```hcl
module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-config-renderer"

  service = {
    flush     = "5"
    log_level = "info"
    extra_properties = {
      HTTP_Server = "On"
      HTTP_Listen = "0.0.0.0"
      HTTP_Port   = "2020"
    }
  }

  inputs = [
    {
      name = "tail"
      tag  = "app.logs"
      extra_properties = {
        Path          = "/var/log/containers/*.log"
        Parser        = "docker"
        DB            = "/var/log/flb.db"
        Mem_Buf_Limit = "5MB"
      }
    }
  ]

  outputs_ = [
    {
      name  = "cloudwatch_logs"
      match = "app.*"
      extra_properties = {
        region            = "eu-west-1"
        log_group_name    = "/ecs/my-app"
        log_stream_prefix = "container/"
        auto_create_group = "true"
      }
    }
  ]
}
```

## Access Rendered Config

```hcl
# Classic INI-style format
output "classic_config" {
  value = module.fluentbit_config.classic_config
}

# YAML format
output "yaml_config" {
  value = module.fluentbit_config.yaml_config
}
```

## Expected Classic Output

```ini
[SERVICE]
    Flush         5
    Log_Level     info
    HTTP_Server   On
    HTTP_Listen   0.0.0.0
    HTTP_Port     2020

[INPUT]
    Name          tail
    Tag           app.logs
    Path          /var/log/containers/*.log
    Parser        docker
    DB            /var/log/flb.db
    Mem_Buf_Limit 5MB

[OUTPUT]
    Name              cloudwatch_logs
    Match             app.*
    region            eu-west-1
    log_group_name    /ecs/my-app
    log_stream_prefix container/
    auto_create_group true
```

## Expected YAML Output

```yaml
service:
    Flush: "5"
    Log_Level: info
    HTTP_Server: "On"
    HTTP_Listen: 0.0.0.0
    HTTP_Port: "2020"

pipeline:
    inputs:
        - Name: tail
          Tag: app.logs
          Path: /var/log/containers/*.log
          Parser: docker
          DB: /var/log/flb.db
          Mem_Buf_Limit: 5MB

    outputs:
        - Name: cloudwatch_logs
          Match: app.*
          region: eu-west-1
          log_group_name: /ecs/my-app
          log_stream_prefix: container/
          auto_create_group: "true"
```

## With Parsers (Separate File)

```hcl
module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-config-renderer"

  parsers = [
    {
      name        = "docker"
      format      = "json"
      time_key    = "time"
      time_format = "%Y-%m-%dT%H:%M:%S.%L%z"
      time_keep   = false
    },
    {
      name   = "apache"
      format = "regex"
      regex  = "^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \\[(?<time>[^\\]]*)\\]"
      time_key    = "time"
      time_format = "%d/%b/%Y:%H:%M:%S %z"
    }
  ]
}
```

## With Multiline Parser

```hcl
module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-config-renderer"

  multiline_parsers = [
    {
      name = "multiline-java"
      type = "regex"
      rules = [
        {
          state      = "start_state"
          regex      = "/^\\d{4}-\\d{2}-\\d{2}/"
          next_state = "cont"
        },
        {
          state      = "cont"
          regex      = "/^\\s/"
          next_state = "cont"
        }
      ]
    }
  ]
}
```

## Verification

```bash
terraform init
terraform plan
terraform apply

# Verify the rendered config
terraform output -raw classic_config > fluent-bit.conf
terraform output -raw yaml_config > fluent-bit.yaml
```
