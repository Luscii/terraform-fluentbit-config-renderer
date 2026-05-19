# Tests for multi-source routing with tag-based filtering (US3)

# T032: Multi-source routing classic format test
run "multi_source_routing_classic" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.frontend"
        extra_properties = {
          Path = "/var/log/frontend/*.log"
        }
      },
      {
        name = "tail"
        tag  = "app.backend"
        extra_properties = {
          Path = "/var/log/backend/*.log"
        }
      }
    ]

    filters = [
      {
        name  = "grep"
        match = "*"
        extra_properties = {
          Regex = "log ERROR"
        }
      }
    ]

    outputs_ = [
      {
        name  = "cloudwatch_logs"
        match = "app.frontend"
        extra_properties = {
          region         = "eu-west-1"
          log_group_name = "/ecs/frontend"
        }
      },
      {
        name  = "cloudwatch_logs"
        match = "app.backend"
        extra_properties = {
          region         = "eu-west-1"
          log_group_name = "/ecs/backend"
        }
      }
    ]
  }

  # 5 sections total: 2 INPUT + 1 FILTER + 2 OUTPUT
  assert {
    condition     = length(local.sections) == 5
    error_message = "Expected 5 sections, got ${length(local.sections)}"
  }

  # Canonical ordering: INPUTs before FILTERs before OUTPUTs
  assert {
    condition     = local.sections[0].type == "INPUT"
    error_message = "First section should be INPUT, got ${local.sections[0].type}"
  }

  assert {
    condition     = local.sections[1].type == "INPUT"
    error_message = "Second section should be INPUT, got ${local.sections[1].type}"
  }

  assert {
    condition     = local.sections[2].type == "FILTER"
    error_message = "Third section should be FILTER, got ${local.sections[2].type}"
  }

  assert {
    condition     = local.sections[3].type == "OUTPUT"
    error_message = "Fourth section should be OUTPUT, got ${local.sections[3].type}"
  }

  assert {
    condition     = local.sections[4].type == "OUTPUT"
    error_message = "Fifth section should be OUTPUT, got ${local.sections[4].type}"
  }

  # Classic format contains all section headers
  assert {
    condition     = strcontains(output.classic_config, "[INPUT]")
    error_message = "Classic config should contain [INPUT] header"
  }

  assert {
    condition     = strcontains(output.classic_config, "[FILTER]")
    error_message = "Classic config should contain [FILTER] header"
  }

  assert {
    condition     = strcontains(output.classic_config, "[OUTPUT]")
    error_message = "Classic config should contain [OUTPUT] header"
  }

  # Tags and matches are rendered correctly
  assert {
    condition     = strcontains(output.classic_config, "app.frontend")
    error_message = "Classic config should contain app.frontend tag/match"
  }

  assert {
    condition     = strcontains(output.classic_config, "app.backend")
    error_message = "Classic config should contain app.backend tag/match"
  }

  # Both log groups rendered
  assert {
    condition     = strcontains(output.classic_config, "/ecs/frontend")
    error_message = "Classic config should contain /ecs/frontend log group"
  }

  assert {
    condition     = strcontains(output.classic_config, "/ecs/backend")
    error_message = "Classic config should contain /ecs/backend log group"
  }
}

# T033: Multi-source routing YAML format test
run "multi_source_routing_yaml" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.frontend"
        extra_properties = {
          Path = "/var/log/frontend/*.log"
        }
      },
      {
        name = "tail"
        tag  = "app.backend"
        extra_properties = {
          Path = "/var/log/backend/*.log"
        }
      }
    ]

    filters = [
      {
        name  = "grep"
        match = "*"
        extra_properties = {
          Regex = "log ERROR"
        }
      }
    ]

    outputs_ = [
      {
        name  = "cloudwatch_logs"
        match = "app.frontend"
        extra_properties = {
          region         = "eu-west-1"
          log_group_name = "/ecs/frontend"
        }
      },
      {
        name  = "cloudwatch_logs"
        match = "app.backend"
        extra_properties = {
          region         = "eu-west-1"
          log_group_name = "/ecs/backend"
        }
      }
    ]
  }

  # YAML pipeline structure
  assert {
    condition     = strcontains(output.yaml_config, "\"pipeline\":")
    error_message = "YAML config should contain pipeline: mapping"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"inputs\":")
    error_message = "YAML config should contain inputs: list"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"filters\":")
    error_message = "YAML config should contain filters: list"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"outputs\":")
    error_message = "YAML config should contain outputs: list"
  }

  # Tags and matches present in YAML
  assert {
    condition     = strcontains(output.yaml_config, "app.frontend")
    error_message = "YAML config should contain app.frontend tag/match"
  }

  assert {
    condition     = strcontains(output.yaml_config, "app.backend")
    error_message = "YAML config should contain app.backend tag/match"
  }

  # Both log groups present
  assert {
    condition     = strcontains(output.yaml_config, "/ecs/frontend")
    error_message = "YAML config should contain /ecs/frontend log group"
  }

  assert {
    condition     = strcontains(output.yaml_config, "/ecs/backend")
    error_message = "YAML config should contain /ecs/backend log group"
  }
}
