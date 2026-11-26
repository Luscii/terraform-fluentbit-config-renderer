module "example" {
  source = "../../"

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
