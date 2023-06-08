variable "project_name" {
  type        = string
  default     = "longdv-lab4"
  description = "name of this project"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "cidr for vpc"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "cidr for public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "cidr for private subnet"
}

variable "all_ip" {
  type        = string
  default     = "0.0.0.0/0"
  description = "all ip"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "t2 micro"
}
