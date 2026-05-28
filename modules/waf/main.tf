resource "aws_wafv2_web_acl" "agentflow_waf" {
    name           = "${var.project_name}-waf"
    scope          = "REGIONAL"
    description    = "Web Address Firewall"

    default_action {
        allow{ }
    }

    visibility_config {
       cloudwatch_metrics_enabled = true
       metric_name                = "${var.project_name}-waf"
       sampled_requests_enabled   = true 
    }

    rule {
        name     = "AWSManagedRulesCommonRuleSet"
        priority = 1

        override_action {
            none { }
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesCommonRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "AWSManagedRulesCommonRuleSet"
            sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
        priority = 2

         override_action {
            none { }
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesKnownBadInputsRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
            sampled_requests_enabled   = true
    }
}

resource "aws_wafv2_web_acl_association" "agentflow" {
    resource_arn = var.api_gateway_arn
    web_acl_arn  = aws_wafv2_web_acl.agentflow_waf.arn
}