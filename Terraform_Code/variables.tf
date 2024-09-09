variable "stack_name" {
  description = "Name of the stack"
  type        = string
  default     = "appmesh-workshop"  # 원하는 기본값으로 설정
}

variable "region" {
  description = "region"
  type        = string
  default     = "ap-northeast-2"  # 원하는 기본값으로 설정
}

variable "latest_ami_id" {
  description = "The latest Amazon Linux 2 AMI ID"
  type        = string
  default     = "ami-0023481579962abd4"
}