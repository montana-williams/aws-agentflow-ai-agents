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
}

# WAF Web ACL Association removed — aws_wafv2_web_acl_association does not support
# API Gateway v2 HTTP APIs. In production this WAF would be associated via CloudFront
# sitting in front of API Gateway. See README for architecture note.