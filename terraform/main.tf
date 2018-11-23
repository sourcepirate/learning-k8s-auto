terraform {
  backend "s3" {
    bucket = "clusterinfo"
    region = "us-east-1"
    key    = "state.tfstate"
  }
}

provider "aws" {}
