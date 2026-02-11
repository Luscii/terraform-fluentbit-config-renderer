# Quickstart: Fluent Bit Configuration Renderer

## Minimal Usage (Classic Format)

```hcl
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "luscii"
  environment = "production"
  name        = "fluentbit"
}

module "fluentbit_config" {
  source = "github.com/Luscii/terraform-fluentbit-config-renderer"

  name    = module.label.name
  context = module.label.context

  service = [
    {
      properties = [
        ["Flush", "5"],
        ["Log_Level", "info"],
        ["HTTP_Server", "On"],
        ["HTTP_Listen", "0.0.0.0"],
        ["HTTP_Port", "2020"]
      ]
    }
  ]

  inputs = [
    {
      properties = [
        ["Name", "tail"],
        ["Tag", "app.logs"],
        ["Path", "/var/log/containers/*.log"],
        ["Parser", "docker"],
        ["DB", "/var/log/flb.db"],
        ["Mem_Buf_Limit", "5MB"]
      ]
    }
  ]

  outputs = [
    {
      properties = [
        ["Name", "cloudwatch_logs"],
        ["Match", "app.*"],
        ["region", "eu-west-1"],
        ["log_group_name", "/ecs/my-app"],
        ["log_stream_prefix", "container/"],
        ["auto_create_group", "true"]
      ]
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

  name    = module.label.name
  context = module.label.context

  parsers = [
    {
      properties = [
        ["Name", "docker"],
        ["Format", "json"],
        ["Time_Key", "time"],
        ["Time_Format", "%Y-%m-%dT%H:%M:%S.%L%z"],
        ["Time_Keep", "Off"]
      ]
    },
    {
      properties = [
        ["Name", "apache"],
        ["Format", "regex"],
        ["Regex", "^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \\[(?<time>[^\\]]*)\\]"],
        ["Time_Key", "time"],
        ["Time_Format", "%d/%b/%Y:%H:%M:%S %z"]
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
