module "example" {
  source = "../../"

  service = {
    flush     = "5"
    log_level = "info"
  }

  inputs = [
    {
      name = "tail"
      tag  = "app.logs"
      extra_properties = {
        Path = "/var/log/*.log"
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
      match = "app.*"
      extra_properties = {
        region         = "eu-west-1"
        log_group_name = "/ecs/my-app"
      }
    }
  ]

  parsers = [
    {
      name     = "docker"
      format   = "json"
      time_key = "time"
    }
  ]

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
