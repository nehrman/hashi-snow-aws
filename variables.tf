####################
# GLOBAL VARIABLES #
####################

# Variable used to define which cloud provider should be use to deploy pTFE
variable "cloud_provider" {
  default = "aws"
}

variable "global_environment" {
  default = "dev"
}

variable "global_owner" {
  default = "neh"
}

variable "global_purpose" {
  default = "testing"
}

variable "global_vm_apps" {
  default = "ptfe"
}

variable "global_admin_username" {
  default = "ptfeadmin"
}

# Variable used to define which region in regards to which cloud provider

variable "cloud_region" {
  type = "map"

  default = {
    arm = "francecentral"
    aws = "eu-central-1"
    gcp = "eu-west1"
  }
}

# Variable used to define which dns zone in regards to which cloud provider

variable "cloud_dns_zone" {
  type = "map"

  default = {
    arm = "demoaz"
    aws = "demoaws"
    gcp = "demogcp"
  }
}

# Variable uses to define the count of Instances to deploy
variable "vault_vm_count" {
  default = "6"
}

variable "consul_vm_count" {
  default = "0"
}

# Global variable for SSH key name

variable "global_key_name" {
  default = "pTFE-test"
}

# SSH Public Key used for connection 

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4oo5BbgZwTRrm9H0gVBveYV6Rx/7ORskgz0MGcAfTRFlYfkpnZFDEox9B1xBavWUCpIKwTLgHwzcepiQ9+8hK280pMpCqnp5Q3e2EGJ3tHji6vPhZFNFjhq2b8nhY1aQFxt31L3pX2kZwjPa5cfRkeyUCwxqbbyar5sks8JxBA2l+KhelM1fR8jcXHF9MUWHfxL8bjw9AmD24p3j35UmU3yQZGShITvFdEgnLOaOXjwqylrTK0XzV4R0AO7sJrse97xZaD3jYUEFCxqf1xo2rRSD2y2goQ8WnVv66Ep9CVg/jMG99UCWNCfKZSCsopM4xBP5h5YOSC6QyBDBjXfT/ nicolas@MacBook-Pro-de-Nicolas.local"
}

# Global Address space Variable

variable "global_address_space" {
  description = "Define the global address space used by Cloud Network"
  default     = "10.0.0.0/16"
}

# Global CIDR Blocks list used for Security Rules configuration

variable "ec2_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

# Global variables used to define configuration of security rules whatever the cloud provider is

variable "ec2_custom_security_rules" {
  description = "Create all security rules needed by default for Azure"
  type        = "list"

  default = [
    {
      type        = "ingress"
      from_port   = "8300"
      to_port     = "8301"
      protocol    = "tcp"
      description = "Consul Serf"
    },
    {
      type        = "ingress"
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      description = "SSH access TFE"
    },
    {
      type        = "ingress"
      from_port   = "8200"
      to_port     = "8200"
      protocol    = "tcp"
      description = "HTTP access Vault API"
    },
    {
      type        = "ingress"
      from_port   = "8201"
      to_port     = "8201"
      protocol    = "tcp"
      description = "HTTP access Vault Cluster"
    },
    {
      type        = "ingress"
      from_port   = "8500"
      to_port     = "8500"
      protocol    = "tcp"
      description = "Access Consul"
    },
    {
      type        = "egress"
      from_port   = "0"
      to_port     = "65535"
      protocol    = "-1"
      description = "Allow all"
    },
  ]
}
