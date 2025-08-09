variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "Surya_Batch_10_New"
}

variable "environment" {
  description = "Tag value for Environment"
  type        = string
  default     = "Skill_test_3"
}
