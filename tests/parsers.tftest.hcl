# Tests for PARSER and MULTILINE_PARSER rendering

# T023: PARSER rendering tests
run "parser_classic_rendering" {
  command = plan

  variables {
    parsers = [
      {
        properties = [
          ["Name", "docker"],
          ["Format", "json"],
          ["Time_Key", "time"]
        ]
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_config, "[PARSER]")
    error_message = "Classic config should contain [PARSER] header"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Name     docker")
    error_message = "Classic config should contain Name property aligned to Time_Key width"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Format   json")
    error_message = "Classic config should contain Format property"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Time_Key time")
    error_message = "Classic config should contain Time_Key property"
  }
}

run "parser_yaml_rendering" {
  command = plan

  variables {
    parsers = [
      {
        properties = [
          ["Name", "docker"],
          ["Format", "json"],
          ["Time_Key", "time"]
        ]
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

# T024: MULTILINE_PARSER tests with duplicate keys
run "multiline_parser_classic_rendering" {
  command = plan

  variables {
    multiline_parsers = [
      {
        properties = [
          ["Name", "multiline-java"],
          ["type", "regex"],
          ["rule", "start_state /^\\d{4}/ cont"],
          ["rule", "cont /^\\s/ cont"]
        ]
      }
    ]
  }

  assert {
    condition     = strcontains(output.classic_config, "[MULTILINE_PARSER]")
    error_message = "Classic config should contain [MULTILINE_PARSER] header"
  }

  assert {
    condition     = strcontains(output.classic_config, "    Name multiline-java")
    error_message = "Classic config should contain Name property"
  }

  # Both rule entries should be present (duplicate keys)
  assert {
    condition     = strcontains(output.classic_config, "    rule start_state")
    error_message = "Classic config should contain first rule entry"
  }

  assert {
    condition     = strcontains(output.classic_config, "    rule cont")
    error_message = "Classic config should contain second rule entry"
  }
}

run "multiline_parser_yaml_rendering" {
  command = plan

  variables {
    multiline_parsers = [
      {
        properties = [
          ["Name", "multiline-java"],
          ["type", "regex"]
        ]
      }
    ]
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"multiline_parsers\":")
    error_message = "YAML config should contain multiline_parsers: key"
  }

  assert {
    condition     = strcontains(output.yaml_config, "\"Name\": \"multiline-java\"")
    error_message = "YAML config should contain multiline parser Name"
  }
}

# T025: Section ordering with PARSERs
run "section_ordering_with_parsers" {
  command = plan

  variables {
    inputs = [
      {
        properties = [
          ["Name", "tail"],
          ["Tag", "app.logs"]
        ]
      }
    ]

    outputs_ = [
      {
        properties = [
          ["Name", "stdout"],
          ["Match", "*"]
        ]
      }
    ]

    parsers = [
      {
        properties = [
          ["Name", "docker"],
          ["Format", "json"]
        ]
      }
    ]
  }

  # Verify canonical ordering: INPUT before OUTPUT before PARSER
  assert {
    condition = (
      local.sections[0].type == "INPUT" &&
      local.sections[1].type == "OUTPUT" &&
      local.sections[2].type == "PARSER"
    )
    error_message = "Sections should be in canonical order: INPUT, OUTPUT, PARSER"
  }

  # Verify classic config reflects this ordering
  assert {
    condition = (
      index(split("\n", output.classic_config), "[INPUT]") <
      index(split("\n", output.classic_config), "[OUTPUT]")
    )
    error_message = "Classic config: INPUT should appear before OUTPUT"
  }

  assert {
    condition = (
      index(split("\n", output.classic_config), "[OUTPUT]") <
      index(split("\n", output.classic_config), "[PARSER]")
    )
    error_message = "Classic config: OUTPUT should appear before PARSER"
  }
}
