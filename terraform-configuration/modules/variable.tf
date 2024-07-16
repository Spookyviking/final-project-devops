variable "vpc_ip_address" {
  description = "Private IP address"
  type        = string
}

variable "name_node" {
  description = "Name of node"
  type        = string
  default     = "manager"
}

variable "vpc_subnet_id" {
  description = "VPC subnet network id"
  type        = string
}

variable "yandex_image_id" {
  description = "Image ID"
  type        = string
  default     = "fd8pecdhv50nec1qf9im"
}
