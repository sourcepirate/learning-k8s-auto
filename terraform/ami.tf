data "aws_ami" "ubuntu" {
  most_recent = true

  filter = {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter = {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter = {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}
