variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "tf_sns_topic"
}

variable "email_endpoint" {
  description = "Email address for SNS notifications"
  type        = string
  #default     = "elliothere867@gmail.com"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

