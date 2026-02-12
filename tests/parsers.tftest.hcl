# Tests for PARSER and MULTILINE_PARSER rendering

# T023: PARSER rendering tests
run "parser_classic_rendering" {
  command = plan

  variables {
    parsers = [
      {
        name     = "docker"
        format   = "json"
        time_key = "time"
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "[PARSER]")
    error_message = "Classic parsers config should contain [PARSER] header"
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "    Name     docker")
    error_message = "Classic parsers config should contain Name property aligned to Time_Key width"
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "    Format   json")
    error_message = "Classic parsers config should contain Format property"
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "    Time_Key time")
    error_message = "Classic parsers config should contain Time_Key property"
  }

  # Parsers should NOT appear in main classic_config
  assert {
    condition     = output.classic_config == ""
    error_message = "Main classic config should be empty when only parsers defined"
  }
}

run "parser_yaml_rendering" {
  command = plan

  variables {
    parsers = [
      {
        name     = "docker"
        format   = "json"
        time_key = "time"
      }
    ]
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"parsers\":")
    error_message = "YAML config should contain parsers: key"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"Name\": \"docker\"")
    error_message = "YAML config should contain parser Name"
  }
}

# T024: MULTILINE_PARSER tests with duplicate keys (rules)
run "multiline_parser_classic_rendering" {
  command = plan

  variables {
    multiline_parsers = [
      {
        name = "multiline-java"
        type = "regex"
        rules = [
          {
            state      = "start_state"
            regex      = "/^\\d{4}/"
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

  assert {
    condition     = strcontains(output.classic_parsers_config, "[MULTILINE_PARSER]")
    error_message = "Classic parsers config should contain [MULTILINE_PARSER] header"
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "    Name multiline-java")
    error_message = "Classic parsers config should contain Name property"
  }

  # Both rule entries should be present (duplicate keys)
  assert {
    condition     = strcontains(output.classic_parsers_config, "    rule start_state")
    error_message = "Classic parsers config should contain first rule entry"
  }

  assert {
    condition     = strcontains(output.classic_parsers_config, "    rule cont")
    error_message = "Classic parsers config should contain second rule entry"
  }
}

run "multiline_parser_yaml_rendering" {
  command = plan

  variables {
    multiline_parsers = [
      {
        name = "multiline-java"
        type = "regex"
      }
    ]
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"multiline_parsers\":")
    error_message = "YAML config should contain multiline_parsers: key"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"name\": \"multiline-java\"")
    error_message = "YAML config should contain multiline parser name"
  }
}

# T025: Section ordering with PARSERs
run "section_ordering_with_parsers" {
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

    parsers = [
      {
        name   = "docker"
        format = "json"
      }
    ]
  }

  # Verify canonical ordering in local.sections: INPUT before OUTPUT before PARSER
  assert {
    condition = (
      local.sections[0].type == "INPUT" &&
      local.sections[1].type == "OUTPUT" &&
      local.sections[2].type == "PARSER"
    )
    error_message = "Sections should be in canonical order: INPUT, OUTPUT, PARSER"
  }

  # Verify classic config contains pipeline sections in order
  assert {
    condition = (
      index(split("\n", output.classic_config), "[INPUT]") <
      index(split("\n", output.classic_config), "[OUTPUT]")
    )
    error_message = "Classic config: INPUT should appear before OUTPUT"
  }

  # Verify parsers are in separate classic_parsers_config
  assert {
    condition     = strcontains(output.classic_parsers_config, "[PARSER]")
    error_message = "Parsers should appear in classic_parsers_config"
  }

  # Verify parsers are NOT in main classic_config
  assert {
    condition     = !strcontains(output.classic_config, "[PARSER]")
    error_message = "Parsers should NOT appear in main classic_config"
  }
}
