terraform {
  required_providers {
    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = "0.6.29"
    }
  }
}

locals {
  config = yamldecode(file("config.yaml"))

  test_team_members = concat(
    [for user in local.config.users : opsgenie_user.all[user.email]],
    [data.opsgenie_user.admin]
  )
}

variable "opsgenie_api_url" {
  type = string
}

variable "opsgenie_heartbeat_name" {
  type = string
}

provider "opsgenie" {
  api_url = var.opsgenie_api_url
}

resource "opsgenie_user" "all" {
  for_each  = { for user in local.config.users : user.email => user.name }
  username  = each.key
  full_name = each.value
  locale    = "en_GB"
  timezone  = local.config.timezone
  role      = "User"
}

data "opsgenie_user" "admin" {
  username = local.config.admin_email
}

resource "opsgenie_team" "test" {
  name        = "test"
  description = "This is a test team with all the users"

  dynamic "member" {
    for_each = local.test_team_members
    content {
      id   = member.value.id
      role = "user"
    }
  }
}

# TODO: escalation route, policy, schedule


resource "opsgenie_service" "toy" {
  name        = "toy"
  description = "Toy service"
  team_id     = opsgenie_team.test.id
}

resource "opsgenie_heartbeat" "toy_service" {
  name           = var.opsgenie_heartbeat_name
  description    = "Heartbeat for toy service"
  interval_unit  = "minutes"
  interval       = 10
  enabled        = true
  alert_message  = "Alert!"
  alert_priority = "P3"
  owner_team_id  = opsgenie_team.test.id
}
