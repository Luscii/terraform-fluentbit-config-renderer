module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "example"
  environment = "production"
  stage       = "prod"
  name        = "complete"
  attributes  = ["demo"]

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "Example"
  }
}

module "example" {
  source = "../../"

  name = module.label.name

  context = module.label.context
}
