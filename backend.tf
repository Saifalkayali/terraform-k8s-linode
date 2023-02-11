terraform {
  backend "s3" {
    endpoint                    = "us-east-1.linodeobjects.com"
    profile                     = "linode-s3"
    skip_credentials_validation = true
    bucket                      = "saif-tf-state"
    key                         = "state.json"
    region                      = "us-east-1"
}
}