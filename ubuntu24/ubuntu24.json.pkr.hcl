# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

# The amazon-ami data block is generated from your amazon builder source_ami_filter; a data
# from this block can be referenced in source and locals blocks.
# Read the documentation for data blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/data
# Read the documentation for the Amazon AMI Data Source here:
# https://www.packer.io/plugins/datasources/amazon/ami
data "amazon-ami" "ubuntu24" {
  filters = {
    name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

# All locals variables are generated from variables that uses expressions
# that are not allowed in HCL2 variables.
# Read the documentation for locals blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/locals
locals {
  release_date = "${legacy_isotime("2006-01-02 03:04:05")}"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
# 1 error occurred upgrading the following block:
# unhandled "clean_resource_name" call:
# there is no way to automatically upgrade the "clean_resource_name" call.
# Please manually upgrade to use custom validation rules, `replace(string, substring, replacement)` or `regex_replace(string, substring, replacement)`
# Visit https://packer.io/docs/templates/hcl_templates/variables#custom-validation-rules , https://www.packer.io/docs/templates/hcl_templates/functions/string/replace or https://www.packer.io/docs/templates/hcl_templates/functions/string/regex_replace for more infos.

source "amazon-ebs" "ubuntu24" {
  ami_description             = "{\"os\":\"ubuntu24\", \"env\":\"${var.env}\", \"release_date\":\"${local.release_date}\", \"desc\": \"Official SPS CSE Ubuntu 24 GOLDEN AMI\"}"
  ami_name                    = "SPS CSE Ubuntu 24 x86_64 HVM EBS ENA Golden AMI ${regex_replace(timestamp(), "[^a-zA-Z0-9-]", "")}"
  ami_org_arns                = ["arn:aws:organizations::880141098094:organization/o-45gl6wapoa"]
  ami_regions                 = ["us-east-1", "us-east-2"]
  associate_public_ip_address = false
  ebs_optimized               = true
  ena_support                 = true
  encrypt_boot                = false
  iam_instance_profile        = "SSM_Role_for_CodeBuild"
  instance_type               = "t3.small"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp3"
  }
  launch_block_device_mappings {
    device_name = "/dev/sdb"
    no_device   = true
  }
  launch_block_device_mappings {
    device_name = "/dev/sdc"
    no_device   = true
  }
  security_group_id = "${var.security_group_id}"
  source_ami        = "${data.amazon-ami.ubuntu24.id}"
  sriov_support     = true
  ssh_username      = "${var.os_username}"
  subnet_id         = "${var.subnet_id}"
  tags = {
    Name                = "CSE_Ubuntu24_GoldenAMI"
    codebuild_build_url = "${var.codebuild_build_url}"
    os                  = "ubuntu24"
    release_date        = "${local.release_date}"
    repo                = "https://github.com/SPSCommerce/imagegami"
    source_version      = "${var.codebuild_resolved_source_version}"
    "sps:env"           = "${var.env}"
    "sps:owner"         = "cloudsyseng@spscommerce.com"
    "sps:product"       = "infrastructure"
    "sps:subproduct"    = "golden-ami-pipeline"
    "sps:unit"          = "cloud-engineering"
  }
  temporary_key_pair_type = "ed25519"
}


build {
  description = "Packer for ubuntu24 Ansible"

  sources = ["source.amazon-ebs.ubuntu24"]

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_PIPELINING=True"]
    extra_arguments  = ["--skip-tags=amiprep,openscap", "-T 60", "--extra-vars", "env=${var.env}", "-e install_prometheus=false", "-e install_consul=false", "-e install_vault=false"]
    host_alias       = "ubuntu24"
    playbook_file    = "../../playbook.yml"
    user             = "${var.os_username}"
  }

  provisioner "file" {
    destination = "/tmp/"
    source      = "../../inspec/"
  }

  provisioner "shell" {
    inline              = ["export CHEF_LICENSE=accept-silent", "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -v 5.21.29 -P inspec", "sudo inspec exec /tmp/common_spec --chef-license accept-silent --reporter documentation"]
    name = "Install Chef and execute common_spec"
    pause_before        = "10s"
  }

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_PIPELINING=True"]
    extra_arguments  = ["--tags=openscap", "-T 60"]
    host_alias       = "ubuntu24"
    pause_before     = "10s"
    playbook_file    = "../../playbook.yml"
    user             = "${var.os_username}"
  }

  provisioner "ansible" {
    extra_arguments = ["-b", "--tags=openscap", "--skip-tags=sshd_disable_root_login,accounts_root_path_dirs_no_write,restrict_serial_port_logins,securetty_root_login_console_only,file_ownership_library_dirs,file_ownership_binary_dirs", "-T 60"]
    host_alias      = "ubuntu24"
    pause_before    = "10s"
    playbook_file   = "../../roles/openscap/tasks/ospp-remediations.yml"
    user            = "${var.os_username}"
  }

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_PIPELINING=True"]
    extra_arguments  = ["--tags=amiprep", "-T 60"]
    host_alias       = "ubuntu24"
    pause_before     = "10s"
    playbook_file    = "../../playbook.yml"
    user             = "${var.os_username}"
  }

  post-processor "manifest" {
    custom_data = {
      release_date = "${local.release_date}"
    }
    output     = "manifest.json"
    strip_path = true
  }
}