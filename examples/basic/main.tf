module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "example"
  environment = "dev"
  name        = "basic"
}

module "example" {
  source = "../../"

  name = module.label.name

  context = module.label.context
}
