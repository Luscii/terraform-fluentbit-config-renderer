module "example" {
  source = "../../"

  inputs = [
    {
      properties = [
        ["Name", "tail"],
        ["Tag", "app.logs"],
        ["Path", "/var/log/*.log"]
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
}
