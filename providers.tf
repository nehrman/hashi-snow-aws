provider "aws" {
  region = "${lookup(var.cloud_region, "aws")}"
  version = "~> 2.0"
}
