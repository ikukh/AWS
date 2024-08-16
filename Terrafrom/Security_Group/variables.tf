variable "region" {
  default = "eu-central-1"
}

variable "dynamic_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201,8300, 9200, 9500]
}