terraform {
  required_providers {
    opsgenie = {
      source = "opsgenie/opsgenie"
      version = "0.6.29"
    }
  }
}

variable "opsgenie_api_url" {
  type = string
}

provider "opsgenie" {
  api_url = var.opsgenie_api_url
}

resource "opsgenie_user" "test" {
  username  = "user@domain.com"
  full_name = "Test User"
  role      = "User"
}
