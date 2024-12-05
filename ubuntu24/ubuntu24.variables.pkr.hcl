# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "aws_region" {
  type    = string
  default = "${env("AWS_REGION")}"
}

variable "codebuild_build_url" {
  type    = string
  default = "${env("CODEBUILD_BUILD_URL")}"
}

variable "codebuild_resolved_source_version" {
  type    = string
  default = "${env("CODEBUILD_RESOLVED_SOURCE_VERSION")}"
}

variable "env" {
  type    = string
  default = "${env("ENV")}"
}

variable "os_username" {
  type    = string
  default = "ubuntu"
}

variable "security_group_id" {
  type    = string
  default = "${env("SECURITY_GROUP")}"
}

variable "subnet_id" {
  type    = string
  default = "${env("SUBNET_ID")}"
}