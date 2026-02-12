locals {
  # ── Normalization: typed attributes → canonical [key, value] tuples ──

  service_sections = var.service != null ? [{
    type = "SERVICE"
    properties = concat(
      var.service.flush != null ? [["Flush", var.service.flush]] : [],
      var.service.grace != null ? [["Grace", tostring(var.service.grace)]] : [],
      var.service.log_level != null ? [["Log_Level", var.service.log_level]] : [],
      var.service.log_file != null ? [["Log_File", var.service.log_file]] : [],
      var.service.http_server != null ? [["HTTP_Server", var.service.http_server]] : [],
      var.service.http_listen != null ? [["HTTP_Listen", var.service.http_listen]] : [],
      var.service.http_port != null ? [["HTTP_Port", tostring(var.service.http_port)]] : [],
      var.service.parsers_file != null ? [["Parsers_File", var.service.parsers_file]] : [],
      var.service.storage_path != null ? [["storage.path", var.service.storage_path]] : [],
      [for k, v in var.service.extra_properties : [k, v]],
    )
  }] : []

  input_sections = [
    for input in var.inputs : {
      type = "INPUT"
      properties = concat(
        [["Name", input.name]],
        input.tag != null ? [["Tag", input.tag]] : [],
        input.alias != null ? [["Alias", input.alias]] : [],
        input.log_level != null ? [["Log_Level", input.log_level]] : [],
        input.mem_buf_limit != null ? [["Mem_Buf_Limit", input.mem_buf_limit]] : [],
        input.storage_type != null ? [["storage.type", input.storage_type]] : [],
        input.routable != null ? [["Routable", input.routable ? "On" : "Off"]] : [],
        input.threaded != null ? [["Threaded", input.threaded ? "On" : "Off"]] : [],
        [for k, v in input.extra_properties : [k, v]],
      )
    }
  ]

  filter_sections = [
    for filter in var.filters : {
      type = "FILTER"
      properties = concat(
        [["Name", filter.name]],
        filter.match_regex != null ? [["Match_Regex", filter.match_regex]] : (
          filter.match != null ? [["Match", filter.match]] : []
        ),
        filter.alias != null ? [["Alias", filter.alias]] : [],
        filter.log_level != null ? [["Log_Level", filter.log_level]] : [],
        [for k, v in filter.extra_properties : [k, v]],
      )
    }
  ]

  output_sections = [
    for output in var.outputs_ : {
      type = "OUTPUT"
      properties = concat(
        [["Name", output.name]],
        output.match_regex != null ? [["Match_Regex", output.match_regex]] : (
          output.match != null ? [["Match", output.match]] : []
        ),
        output.alias != null ? [["Alias", output.alias]] : [],
        output.log_level != null ? [["Log_Level", output.log_level]] : [],
        output.retry_limit != null ? [["Retry_Limit", output.retry_limit]] : [],
        output.workers != null ? [["Workers", tostring(output.workers)]] : [],
        [for k, v in output.extra_properties : [k, v]],
      )
    }
  ]

  parser_sections = [
    for parser in var.parsers : {
      type = "PARSER"
      properties = concat(
        [["Name", parser.name]],
        [["Format", parser.format]],
        parser.regex != null ? [["Regex", parser.regex]] : [],
        parser.time_key != null ? [["Time_Key", parser.time_key]] : [],
        parser.time_format != null ? [["Time_Format", parser.time_format]] : [],
        parser.time_keep != null ? [["Time_Keep", parser.time_keep ? "On" : "Off"]] : [],
        parser.time_offset != null ? [["Time_Offset", parser.time_offset]] : [],
        parser.types != null ? [["Types", parser.types]] : [],
        [for k, v in parser.extra_properties : [k, v]],
      )
    }
  ]

  multiline_parser_sections = [
    for mp in var.multiline_parsers : {
      type = "MULTILINE_PARSER"
      properties = concat(
        [["Name", mp.name]],
        [["type", mp.type]],
        mp.parser != null ? [["parser", mp.parser]] : [],
        mp.key_content != null ? [["key_content", mp.key_content]] : [],
        mp.flush_timeout != null ? [["flush_timeout", mp.flush_timeout]] : [],
        [for rule in mp.rules : ["rule", "${rule.state} ${rule.regex} ${rule.next_state}"]],
        [for k, v in mp.extra_properties : [k, v]],
      )
    }
  ]

  # ── Canonical sections: single ordered list ──

  sections = concat(
    local.service_sections,
    local.input_sections,
    local.filter_sections,
    local.output_sections,
    local.parser_sections,
    local.multiline_parser_sections,
  )

  # ── Classic format: split into pipeline and parsers ──
  # Fluent Bit classic format requires PARSER/MULTILINE_PARSER in a
  # separate parsers_file, not in the main configuration file.

  classic_pipeline_sections = [
    for s in local.sections : s
    if contains(["SERVICE", "INPUT", "FILTER", "OUTPUT"], s.type)
  ]

  classic_parser_sections = [
    for s in local.sections : s
    if contains(["PARSER", "MULTILINE_PARSER"], s.type)
  ]

  # ── Per-section max key width for alignment ──

  classic_pipeline_max_key_widths = [
    for section in local.classic_pipeline_sections :
    length(section.properties) > 0
    ? max([for prop in section.properties : length(prop[0])]...)
    : 0
  ]

  classic_parser_max_key_widths = [
    for section in local.classic_parser_sections :
    length(section.properties) > 0
    ? max([for prop in section.properties : length(prop[0])]...)
    : 0
  ]

  # ── Classic INI-style rendering via templatefile() ──

  # Main config: SERVICE, INPUT, FILTER, OUTPUT only
  classic_config = length(local.classic_pipeline_sections) > 0 ? templatefile(
    "${path.module}/templates/classic.tftpl",
    {
      sections       = local.classic_pipeline_sections
      max_key_widths = local.classic_pipeline_max_key_widths
    }
  ) : ""

  # Parsers config: PARSER and MULTILINE_PARSER only
  classic_parsers_config = length(local.classic_parser_sections) > 0 ? templatefile(
    "${path.module}/templates/classic.tftpl",
    {
      sections       = local.classic_parser_sections
      max_key_widths = local.classic_parser_max_key_widths
    }
  ) : ""

  # ── YAML rendering ──

  # Convert section properties to a simple map (for sections without duplicate keys)
  yaml_section_to_map = {
    for i, section in local.sections : i => {
      for prop in section.properties : prop[0] => prop[1]
    } if section.type != "MULTILINE_PARSER"
  }

  yaml_service = var.service != null ? local.yaml_section_to_map[
    index([for s in local.sections : s.type], "SERVICE")
  ] : {}

  yaml_pipeline_inputs = [
    for i, section in local.sections :
    local.yaml_section_to_map[i]
    if section.type == "INPUT"
  ]

  yaml_pipeline_filters = [
    for i, section in local.sections :
    local.yaml_section_to_map[i]
    if section.type == "FILTER"
  ]

  yaml_pipeline_outputs = [
    for i, section in local.sections :
    local.yaml_section_to_map[i]
    if section.type == "OUTPUT"
  ]

  yaml_parsers = [
    for i, section in local.sections :
    local.yaml_section_to_map[i]
    if section.type == "PARSER"
  ]

  # Multiline parsers need special handling: rules are structured objects
  # in YAML format (state, regex, next_state) rather than flat strings
  yaml_multiline_parsers = [
    for mp in var.multiline_parsers : merge(
      { name = mp.name, type = mp.type },
      mp.parser != null ? { parser = mp.parser } : {},
      mp.key_content != null ? { key_content = mp.key_content } : {},
      mp.flush_timeout != null ? { flush_timeout = mp.flush_timeout } : {},
      length(mp.rules) > 0 ? {
        rules = [
          for rule in mp.rules : {
            state      = rule.state
            regex      = rule.regex
            next_state = rule.next_state
          }
        ]
      } : {},
      { for k, v in mp.extra_properties : k => v },
    )
  ]

  # Build the pipeline object, omitting empty keys
  yaml_pipeline = merge(
    length(local.yaml_pipeline_inputs) > 0 ? { inputs = local.yaml_pipeline_inputs } : {},
    length(local.yaml_pipeline_filters) > 0 ? { filters = local.yaml_pipeline_filters } : {},
    length(local.yaml_pipeline_outputs) > 0 ? { outputs = local.yaml_pipeline_outputs } : {},
  )

  # Build the full YAML structure, omitting empty keys
  yaml_structure = merge(
    length(local.yaml_service) > 0 ? { service = local.yaml_service } : {},
    length(local.yaml_pipeline) > 0 ? { pipeline = local.yaml_pipeline } : {},
    length(local.yaml_parsers) > 0 ? { parsers = local.yaml_parsers } : {},
    length(local.yaml_multiline_parsers) > 0 ? { multiline_parsers = local.yaml_multiline_parsers } : {},
  )

  yaml_config = length(local.yaml_structure) > 0 ? yamlencode(local.yaml_structure) : ""
}
