module "example" {
  source = "../../"

  service = [
    {
      properties = [
        ["Flush", "5"],
        ["Log_Level", "info"]
      ]
    }
  ]

  inputs = [
    {
      properties = [
        ["Name", "tail"],
        ["Tag", "app.logs"],
        ["Path", "/var/log/*.log"]
      ]
    }
  ]

  filters = [
    {
      properties = [
        ["Name", "grep"],
        ["Match", "*"],
        ["Regex", "log ERROR"]
      ]
    }
  ]

  outputs_ = [
    {
      properties = [
        ["Name", "cloudwatch_logs"],
        ["Match", "app.*"],
        ["region", "eu-west-1"],
        ["log_group_name", "/ecs/my-app"]
      ]
    }
  ]

  parsers = [
    {
      properties = [
        ["Name", "docker"],
        ["Format", "json"],
        ["Time_Key", "time"]
      ]
    }
  ]

  multiline_parsers = [
    {
      properties = [
        ["Name", "multiline-java"],
        ["type", "regex"],
        ["rule", "\"start_state\" \"/^\\d{4}-\\d{2}-\\d{2}/\" \"cont\""],
        ["rule", "\"cont\" \"/^\\s/\" \"cont\""]
      ]
    }
  ]
}
