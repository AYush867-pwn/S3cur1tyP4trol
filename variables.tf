variable "alarm_config" {
  type = map(map(bool))
}
variable "email_endpoint" {
  description = "Email address for SNS notifications"
  type        = string
  default     = "elliothere867@gmail.com"
}

variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "tf_sns_topic"
}

