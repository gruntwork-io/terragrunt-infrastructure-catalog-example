variable "name" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "hash_key_type" {
  type = string
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}
