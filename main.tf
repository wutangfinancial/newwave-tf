terraform {
  required_version = "0.11.7" 
}


# provider "aws" {
#  version = "~> 1.21"
#  access_key = "AKIAJE4YJ2UMPLKN7FZA"
#  secret_key = "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"
#  region     = "us-east-1"
#}
# resource "aws_vpc" "default" {
#   # (resource arguments)
#   cidr_block = "172.30.0.0/16"
#  tags {
#    Name = "vpc-4ef90e2a"
#  }
#}
#
# resource "aws_internet_gateway" "default" {
#  vpc_id = "${aws_vpc.default.id}"
#}
#
# #resource "aws_instance" "jenkins" {
#  ami           = "ami-467ca739"
#  instance_type = "t2.micro"
#  subnet_id = "${aws_vpc.default.id}"
#}

output "ipv4_address" {
  value = "${vultr_server.jenkins.ipv4_address}"
}

output "default_password" {
  sensitive = true
  value = "${vultr_server.jenkins.default_password}"
}

resource "vultr_ssh_key" "sal_at_tf" {
  name = "For VMs created from terraform"

  # get the public key from a local file.
  #
  # create the example_rsa.pub file with:
  #
  #	ssh-keygen -t rsa -b 4096 -C 'terraform'
  public_key = "${file("/home/sal/.ssh/id_rsa.pub")}"
}

resource "vultr_server" "jenkins" {
  name = "Jenkins created from terraform"

  tag = "jenkins"

  hostname = "jenkins.detwa.com"

  # set the region. 1 is New Jersey.
  # get the list of regions with the command: vultr regions
  region_id = 1

  # set the plan. 200 is 512 MB RAM,20 GB SSD,0.50 TB BW.
  # get the list of plans with the command: vultr plans --region 1
  plan_id = 200

  # set the OS image. 244 is Debian 9 x64 (stretch).
  # get the list of OSs with the command: vultr os
  os_id = 244

  # enable IPv6.
  ipv6 = true

  # enable private networking.
  private_networking = true

  # enable one or more ssh keys on the root account.
  ssh_key_ids = ["${vultr_ssh_key.sal_at_tf.id}"]

  # execute a command on the local machine.
  provisioner "local-exec" {
    command = "echo local-exec ${vultr_server.jenkins.ipv4_address}"
  }
}
