variable "aws_region" {
  default     = "us-east-1"
}

variable "ecr_repo_name" {
  type    = string
  default = "app-book"
}

variable "image_tag" {
  type    = string
  default = "1.0.0"
}
variable "app_path" {
  type    = string
  default = "../../app-mvn"
}