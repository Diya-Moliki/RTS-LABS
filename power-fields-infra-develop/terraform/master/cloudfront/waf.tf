
locals {
  client_id = "${var.application_name}-${var.environment}-${var.client_name}"
}

resource aws_waf_ipset ip_set {
  name = "whitelist-${local.client_id}-ipset"

  dynamic "ip_set_descriptors" {
    for_each = var.ip_set_descriptors
    content {
      value = ip_set_descriptors.value["value"]
      type  = ip_set_descriptors.value["type"]
    }
  }
}

resource aws_waf_rule waf_rule {
  name        = "allow-${local.client_id}-rule"
  metric_name = "wIPAllow${var.application_name}${var.environment}rule"

  predicates {
    data_id = aws_waf_ipset.ip_set.id
    negated = false
    # i.e. Allow
    type = "IPMatch"
  }
}

resource aws_waf_byte_match_set public_assets {
  name = "allow-${local.client_id}-public-assets-rule"

  byte_match_tuples {
    text_transformation = "NONE"
    positional_constraint = "STARTS_WITH"
    target_string = "/public-assets/"
    field_to_match {
      type = "URI"
    }
  }
}

resource aws_waf_rule public_assets {
  depends_on = [aws_waf_byte_match_set.public_assets]
  name = "allow-${local.client_id}-public-assets-rule"
  metric_name        = "allow${var.application_name}${var.environment}${var.client_name}PublicAssetsRule"
  predicates {
    data_id = aws_waf_byte_match_set.public_assets.id
    negated = false
    type    = "ByteMatch"
  }
}

// note, you must use WAF Classic view to see these in the console
// https://console.aws.amazon.com/wafv2/home?region=global#/webacls
resource aws_waf_web_acl waf_acl {
  name        = "allow-${var.application_name}-${var.environment}-${var.client_name}-acl"
  metric_name = "wIPAllow${var.application_name}${var.environment}acl"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_waf_rule.waf_rule.id
    type     = "REGULAR"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 2
    rule_id  = aws_waf_rule.public_assets.id
    type     = "REGULAR"
  }
}
