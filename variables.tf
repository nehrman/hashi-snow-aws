####################
# GLOBAL VARIABLES #
####################

# Variable used to define which cloud provider should be use to deploy pTFE
variable "cloud_provider" {
}

variable "global_environment" {
}

variable "global_owner" {
}

variable "global_purpose" {
}

variable "global_vm_apps" {
}

variable "global_admin_username" {
}

# Variable used to define which region in regards to which cloud provider

variable "cloud_region" {
  type = "map"
}

# Variable used to define which dns zone in regards to which cloud provider

variable "cloud_dns_zone" {
  type = "map"
}

# Variable uses to define the count of Instances to deploy
variable "vault_vm_count" {
}

variable "consul_vm_count" {
}

# Global variable for SSH key name

variable "global_key_name" {
}

# SSH Public Key used for connection 

variable "ssh_public_key" {
}

# Global Address space Variable

variable "global_address_space" {
  description = "Define the global address space used by Cloud Network"
}

# Global CIDR Blocks list used for Security Rules configuration

variable "ec2_cidr_blocks" {
  type = "list"
}

# Global variables used to define configuration of security rules whatever the cloud provider is

variable "ec2_custom_security_rules" {
  description = "Create all security rules needed by default for Azure"
  type        = "list"
}
