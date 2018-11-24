variable "cluster" {
  default = "baby"
}

variable "region" {
  default = "us-east-1"
}

variable "cidr" {
  default = "10.240.0.0/24"
}

variable "worker_count" {
  default = 2
}

variable "master_count" {
  default = 1
}

variable "etcd_count" {
  default = 1
}

variable "type" {
  default = "t2.micro"
}
