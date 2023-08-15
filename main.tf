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

  # Required to Define custom escalation and routing
  delete_default_resources = true

  dynamic "member" {
    for_each = local.test_team_members
    content {
      id   = member.value.id
      role = "user"
    }
  }
}

resource "opsgenie_schedule" "default" {
  name          = "default_schedule"
  description   = "Schedule test"
  timezone      = local.config.timezone
  enabled       = true
  owner_team_id = opsgenie_team.test.id
}

resource "opsgenie_schedule_rotation" "test" {
  schedule_id = opsgenie_schedule.default.id
  name        = "rotation"
  start_date  = "2019-06-18T00:00:00Z"
  type        = "hourly"
  length      = 6

  dynamic "participant" {
    for_each = local.test_team_members
    content {
      id   = participant.value.id
      type = "user"
    }
  }

  time_restriction {
    type = "time-of-day"

    restriction {
      start_hour = 9
      start_min  = 0
      end_hour   = 17
      end_min    = 0
    }
  }
}

resource "opsgenie_escalation" "test" {
  name          = "default_escalation"
  owner_team_id = opsgenie_team.test.id

  rules {
    condition   = "if-not-acked"
    notify_type = "default"
    delay       = 0

    recipient {
      type = "schedule"
      id   = opsgenie_schedule.default.id
    }
  }

  rules {
    condition   = "if-not-acked"
    notify_type = "next"
    delay       = 5 # minutes

    recipient {
      type = "schedule"
      id   = opsgenie_schedule.default.id
    }
  }

  rules {
    condition   = "if-not-acked"
    notify_type = "default"
    delay       = 10 # minutes

    recipient {
      type = "user"
      id   = data.opsgenie_user.admin.id
    }
  }

}

resource "opsgenie_team_routing_rule" "test" {
  # See: https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/team_routing_rule

  name     = "test_routing"
  team_id  = opsgenie_team.test.id
  order    = 0
  timezone = local.config.timezone

  criteria {
    type = "match-all"
  }

  notify {
    id   = opsgenie_escalation.test.id
    type = "escalation"
  }
}

resource "opsgenie_service" "toy" {
  name        = "toy"
  description = "Toy service"
  team_id     = opsgenie_team.test.id
}

resource "opsgenie_heartbeat" "toy_service" {
  name           = var.opsgenie_heartbeat_name
  description    = "Heartbeat for toy service"
  interval_unit  = "minutes"
  interval       = 1
  enabled        = true
  alert_message  = "Missing heartbeat for toy service"
  alert_priority = "P3"
  owner_team_id  = opsgenie_team.test.id
}
