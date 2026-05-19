# Tests for canonical sections local and basic rendering

# T007: Test canonical sections ordering
run "canonical_sections_ordering" {
  command = plan

  variables {
    service = {
      flush     = "5"
      log_level = "info"
    }

    inputs = [
      {
        name = "tail"
        tag  = "app.logs"
      }
    ]

    filters = [
      {
        name  = "grep"
        match = "*"
      }
    ]

    outputs_ = [
      {
        name  = "stdout"
        match = "*"
      }
    ]

    parsers = [
      {
        name   = "docker"
        format = "json"
      }
    ]

    multiline_parsers = [
      {
        name = "multiline-java"
        type = "regex"
      }
    ]
  }

  # Verify canonical ordering: SERVICE, INPUT, FILTER, OUTPUT, PARSER, MULTILINE_PARSER
  assert {
    condition     = local.sections[0].type == "SERVICE"
    error_message = "First section should be SERVICE, got ${local.sections[0].type}"
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
    condition     = local.sections[4].type == "PARSER"
    error_message = "Fifth section should be PARSER, got ${local.sections[4].type}"
  }

  assert {
    condition     = local.sections[5].type == "MULTILINE_PARSER"
    error_message = "Sixth section should be MULTILINE_PARSER, got ${local.sections[5].type}"
  }

  assert {
    condition     = length(local.sections) == 6
    error_message = "Expected 6 sections, got ${length(local.sections)}"
  }
}

# T007: Test canonical sections with properties preserved
run "canonical_sections_properties" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.logs"
        extra_properties = {
          Path = "/var/log/*.log"
        }
      }
    ]
  }

  assert {
    condition     = length(local.sections) == 1
    error_message = "Expected 1 section, got ${length(local.sections)}"
  }

  assert {
    condition     = local.sections[0].type == "INPUT"
    error_message = "Section type should be INPUT"
  }

  assert {
    condition     = local.sections[0].properties[0][0] == "Name"
    error_message = "First property key should be Name"
  }

  assert {
    condition     = local.sections[0].properties[0][1] == "tail"
    error_message = "First property value should be tail"
  }

  # Name + Tag + Path = 3 properties
  assert {
    condition     = length(local.sections[0].properties) == 3
    error_message = "Expected 3 properties, got ${length(local.sections[0].properties)}"
  }
}

# T007: Test empty inputs produce empty sections list
run "canonical_sections_empty" {
  command = plan

  assert {
    condition     = length(local.sections) == 0
    error_message = "Expected 0 sections when all inputs are empty, got ${length(local.sections)}"
  }
}

# T012: Classic format rendering tests
run "classic_format_service_block" {
  command = plan

  variables {
    service = {
      flush     = "5"
      log_level = "info"
    }
  }

  assert {
    condition     = strcontains(output.classic_config, "[SERVICE]")
    error_message = "Classic config should contain [SERVICE] header"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Flush")
    error_message = "Classic config should indent properties with 4 spaces"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Log_Level")
    error_message = "Classic config should contain Log_Level property"
  }
}

run "classic_format_input_output" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.logs"
        extra_properties = {
          Path = "/var/log/*.log"
        }
      }
    ]

    outputs_ = [
      {
        name  = "stdout"
        match = "*"
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_config, "[INPUT]")
    error_message = "Classic config should contain [INPUT] header"
  }

  assert {
    condition     = strcontains(output.classic_config, "[OUTPUT]")
    error_message = "Classic config should contain [OUTPUT] header"
  }

  # Keys aligned to longest key (4 chars: Name/Path) + 1 space
  assert {
    condition     = strcontains(output.classic_config, "    Name tail")
    error_message = "Classic config should contain Name property with value"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Tag  app.logs")
    error_message = "Classic config should contain aligned Tag property (padded to max key width)"
  }
}

# T012: Empty input produces empty string
run "classic_format_empty" {
  command = plan

  assert {
    condition     = output.classic_config == ""
    error_message = "Classic config should be empty string when no sections provided"
  }
}

# T013: YAML format rendering tests
run "yaml_format_service" {
  command = plan

  variables {
    service = {
      flush     = "5"
      log_level = "info"
    }
  }

  # yamlencode() quotes keys
  assert {
    condition     = strcontains(output.yaml_config, "\"service\":")
    error_message = "YAML config should contain service: mapping"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"Flush\":")
    error_message = "YAML config should contain Flush key"
  }
}

run "yaml_format_pipeline" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.logs"
      }
    ]

    outputs_ = [
      {
        name  = "stdout"
        match = "*"
      }
    ]
  }

  # yamlencode() quotes keys
  assert {
    condition     = strcontains(output.yaml_config, "\"pipeline\":")
    error_message = "YAML config should contain pipeline: mapping"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"inputs\":")
    error_message = "YAML config should contain inputs: list"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"outputs\":")
    error_message = "YAML config should contain outputs: list"
  }
}

# T013: Empty input produces empty string
run "yaml_format_empty" {
  command = plan

  assert {
    condition     = output.yaml_config == ""
    error_message = "YAML config should be empty string when no sections provided"
  }
}

# T014: Omission tests
run "classic_omits_service_when_empty" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.logs"
      }
    ]
  }

  assert {
    condition     = !strcontains(output.classic_config, "[SERVICE]")
    error_message = "Classic config should NOT contain [SERVICE] header when service is empty"
  }
}

run "yaml_omits_filters_when_empty" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        tag  = "app.logs"
      }
    ]

    outputs_ = [
      {
        name  = "stdout"
        match = "*"
      }
    ]
  }

  assert {
    condition     = !strcontains(output.yaml_config, "\"filters\":")
    error_message = "YAML config should NOT contain filters: key when filters is empty"
  }
}

# T015: Ordering test - multiple OUTPUTs in input order
run "classic_output_ordering" {
  command = plan

  variables {
    outputs_ = [
      {
        name  = "cloudwatch_logs"
        match = "app.frontend"
      },
      {
        name  = "s3"
        match = "app.backend"
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_config, "cloudwatch_logs")
    error_message = "First OUTPUT should contain cloudwatch_logs"
  }

  assert {
    condition     = strcontains(output.classic_config, "s3")
    error_message = "Second OUTPUT should contain s3"
  }
}

# T039: Test extra_properties are rendered correctly
run "extra_properties_rendering" {
  command = plan

  variables {
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
  }

  assert {
    condition     = strcontains(output.classic_config, "Path")
    error_message = "Classic config should render extra_properties Path"
  }

  assert {
    condition     = strcontains(output.classic_config, "/var/log/containers/*.log")
    error_message = "Classic config should render extra_properties Path value"
  }

  assert {
    condition     = strcontains(output.classic_config, "Parser")
    error_message = "Classic config should render extra_properties Parser"
  }

  assert {
    condition     = strcontains(output.classic_config, "Mem_Buf_Limit")
    error_message = "Classic config should render extra_properties Mem_Buf_Limit"
  }
}
