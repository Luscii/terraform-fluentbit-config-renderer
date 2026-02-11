locals {
  sections = concat(
    [for s in var.service : { type = "SERVICE", properties = s.properties }],
    [for s in var.inputs : { type = "INPUT", properties = s.properties }],
    [for s in var.filters : { type = "FILTER", properties = s.properties }],
    [for s in var.outputs_ : { type = "OUTPUT", properties = s.properties }],
    [for s in var.parsers : { type = "PARSER", properties = s.properties }],
    [for s in var.multiline_parsers : { type = "MULTILINE_PARSER", properties = s.properties }],
  )

  # Per-section max key width for alignment
  max_key_widths = [
    for section in local.sections :
    length(section.properties) > 0
    ? max([for prop in section.properties : length(prop[0])]...)
    : 0
  ]

  # Classic INI-style rendering via templatefile()
  classic_config = length(local.sections) > 0 ? templatefile(
    "${path.module}/templates/classic.tftpl",
    {
      sections       = local.sections
      max_key_widths = local.max_key_widths
    }
  ) : ""

  # YAML rendering
  # Check if a section has duplicate keys (e.g., multiple "rule" entries)
  yaml_sections_have_duplicates = {
    for i, section in local.sections : i =>
    length(section.properties) != length(distinct([for p in section.properties : p[0]]))
  }

  # For sections WITHOUT duplicate keys, build a simple map
  # For sections WITH duplicate keys, also build a simple map but use last-wins
  # (duplicate key values are rendered as a list via the grouped approach)
  yaml_section_to_map_simple = {
    for i, section in local.sections : i => {
      for prop in section.properties : prop[0] => prop[1]
    } if !local.yaml_sections_have_duplicates[i]
  }

  yaml_section_to_map_grouped = {
    for i, section in local.sections : i => {
      for k, vals in {
        for prop in section.properties : prop[0] => prop[1]...
      } : k => vals
    } if local.yaml_sections_have_duplicates[i]
  }

  yaml_section_to_map = merge(
    local.yaml_section_to_map_simple,
    local.yaml_section_to_map_grouped,
  )

  yaml_service = length(var.service) > 0 ? local.yaml_section_to_map[
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

  yaml_multiline_parsers = [
    for i, section in local.sections :
    local.yaml_section_to_map[i]
    if section.type == "MULTILINE_PARSER"
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
