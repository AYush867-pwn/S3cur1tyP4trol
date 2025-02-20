provider "aws" {
  region = "ap-south-1"
}



variable "enable_security" {
  type    = bool
  default = false
}
variable "enable_sns" {
  type    = bool
  default = false
}

module "security" {
  source = "./security/"
  count  = var.enable_security ? 1 : 0
}

module "sns" {
  source         = "./sns/"
  email_endpoint = var.email_endpoint
  topic_name     = var.topic_name
}

module "cpu" {
  source        = "./alarm/cpu"
  count         = lookup(lookup(var.alarm_config, "EC2", {}), "High_CPU_Utilization", false) ? 1 : 0
  sns_topic_arn = module.sns.topic_arn
}
module "inetwork" {
  source        = "./alarm/inetwork"
  count         = lookup(lookup(var.alarm_config, "EC2", {}), "High_Low_Network_Inbound", false) ? 1 : 0
  sns_topic_arn = module.sns.topic_arn
}

module "onetwork" {
  source        = "./alarm/onetwork"
  count         = lookup(lookup(var.alarm_config, "EC2", {}), "High_Low_Network_Outbound", false) ? 1 : 0
  sns_topic_arn = module.sns.topic_arn
}



