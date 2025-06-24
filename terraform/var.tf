variable "name" {
    description = "Base name"
    type        = string
    default     = "karthik"
}

variable "region"{
      description = "region"
      type        = string
      default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}