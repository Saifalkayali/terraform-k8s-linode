terraform {
  backend "s3" {
    endpoint                    = "saif-tf-state.us-east-1.linodeobjects.com"
    profile                     = "linode-s3"
    skip_credentials_validation = true
    bucket                      = "saif-tf-state"
    key                         = "infra/state.json"
    region                      = "eu-central-1"
  }
}