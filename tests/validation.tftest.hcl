# Tests for input validation (enum constraints, edge cases)

# T048: Service log_level validation
run "service_log_level_valid" {
  command = plan

  variables {
    service = {
      log_level = "debug"
    }
  }

  assert {
    condition     = strcontains(output.classic_config, "Log_Level")
    error_message = "Valid log_level should render"
  }
}

run "service_log_level_invalid" {
  command = plan

  variables {
    service = {
      log_level = "verbose"
    }
  }

  expect_failures = [
    var.service,
  ]
}

# T048: Parser format validation
run "parser_format_valid" {
  command = plan

  variables {
    parsers = [
      {
        name   = "my-parser"
        format = "json"
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "json")
    error_message = "Valid parser format should render"
  }
}

run "parser_format_invalid" {
  command = plan

  variables {
    parsers = [
      {
        name   = "my-parser"
        format = "xml"
      }
    ]
  }

  expect_failures = [
    var.parsers,
  ]
}

# T048: Multiline parser type validation
run "multiline_parser_type_valid" {
  command = plan

  variables {
    multiline_parsers = [
      {
        name = "my-ml-parser"
        type = "regex"
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "regex")
    error_message = "Valid multiline parser type should render"
  }
}

run "multiline_parser_type_invalid" {
  command = plan

  variables {
    multiline_parsers = [
      {
        name = "my-ml-parser"
        type = "pcre"
      }
    ]
  }

  expect_failures = [
    var.multiline_parsers,
  ]
}

# T048: Empty inputs produce empty config
run "empty_inputs_produce_empty_config" {
  command = plan

  assert {
    condition     = output.classic_config == ""
    error_message = "Empty inputs should produce empty classic config"
  }

  assert {
    condition     = output.yaml_config == ""
    error_message = "Empty inputs should produce empty YAML config"
  }
}

# T048: extra_properties values pass through unescaped
run "extra_properties_passthrough" {
  command = plan

  variables {
    inputs = [
      {
        name = "tail"
        extra_properties = {
          Path  = "/var/log/containers/*.log"
          Regex = "^(?<time>[^ ]+) (?<log>.*)$"
        }
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_config, "/var/log/containers/*.log")
    error_message = "File path with glob should pass through unescaped"
  }

  assert {
    condition     = strcontains(output.classic_config, "^(?<time>[^ ]+) (?<log>.*)$")
    error_message = "Regex pattern should pass through unescaped"
  }
}

# T048: Section with only Name property renders correctly
run "minimal_section_name_only" {
  command = plan

  variables {
    inputs = [
      {
        name = "dummy"
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_config, "[INPUT]")
    error_message = "Minimal INPUT should have section header"
  }

  assert {
    condition     = strcontains(output.classic_config, "Name dummy")
    error_message = "Minimal INPUT should have Name property"
  }
}

# T048: Service with null (default) produces no SERVICE block
run "null_service_no_section" {
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
    error_message = "Null service should not produce SERVICE section"
  }
}
