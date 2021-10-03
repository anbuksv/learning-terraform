variable "lambda_src_dir"  {
  default = "./src"
}

variable "lambda_function_package_file"  {
  default = "./apigwt-prod-lambda.zip"
}

variable "stage_name" {
  default = "dev"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "/home/anbuksv/.aws/credentials"
  profile = "anbuksv"
}