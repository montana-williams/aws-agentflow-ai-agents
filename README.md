# AgentFlow AI Agents — AWS Serverless Infrastructure

Fully serverless AWS infrastructure for AgentFlow — a B2B AI automation platform built with Terraform IaC, designed to scale from 200 to 2,000 business customers processing up to 500,000 AI agent jobs per day.

---

## Project Overview

This project provisions production-grade serverless infrastructure for AgentFlow, a Series A SaaS platform that allows businesses to deploy AI automation workflows via API. Built entirely with Terraform across 6 modules and 23 resources.

- **Terraform** (v1.7.5+)
- **AWS Provider** (v6.x)
- **GitHub Codespaces** (browser-based IaC environment)

---

## Architecture Overview

**Security Layer**
WAF with AWS Managed Rule Sets (CommonRuleSet, KnownBadInputsRuleSet) protects the platform from common web exploits and malicious traffic. In production WAF associates via CloudFront — HTTP API Gateway (v2) does not support direct WAFv2 association.

**API Layer**
HTTP API Gateway serves as the front door for all customer requests. Cognito JWT authorizer authenticates and authorizes every API call before any compute runs. Per-customer throttling prevents noisy neighbor issues across 2,000 business customers.

**Job Processing**
Lambda Function 1 accepts the request, writes the job to DynamoDB as `PENDING`, returns a Job ID to the customer immediately, and queues the job in SQS for async processing — ensuring sub-200ms acknowledgment regardless of job complexity.

Lambda Function 2 is triggered by SQS, processes the agent workflow, calls external APIs and webhooks, and updates DynamoDB to `COMPLETE`. On failure the job retries up to 3 times before routing to the Dead Letter Queue.

**Data Layer**
DynamoDB stores all job state with `JobId` as the partition key. PAY_PER_REQUEST billing scales automatically with bursty traffic. Point In Time Recovery enabled for RPO zero — no billing data is ever lost.

**Observability**
CloudWatch alarms monitor Lambda error rates and DLQ depth. SNS delivers real-time alerts to the engineering team. CloudTrail provides a full infrastructure audit trail for compliance and billing accuracy.

---

## AWS Services Used

| Service | Purpose |
|---|---|
| API Gateway (HTTP) | Front door for all API requests — cost optimized over REST |
| Cognito | Customer identity, API key management, JWT authorization |
| WAF | Managed rule sets — CommonRuleSet, KnownBadInputsRuleSet |
| Lambda | Serverless compute — job intake (L1) and job processing (L2) |
| SQS | Async job queue — decouples intake from processing |
| SQS DLQ | Dead letter queue — captures failed jobs after 3 retries |
| DynamoDB | NoSQL job state store — PAY_PER_REQUEST, PITR enabled |
| CloudWatch | Usage metering, Lambda error alarms, DLQ depth monitoring |
| SNS | Engineer alerting — email notifications on alarm triggers |
| CloudTrail | Full infrastructure audit trail — S3 backed |
| S3 | CloudTrail log storage |

---

## Module Structure
modules/
├── auth/          # Cognito User Pool and App Client
├── api_gateway/   # HTTP API, JWT Authorizer, Default Stage
├── waf/           # WAFv2 Web ACL with managed rule sets
├── jobflow/       # IAM Role, Lambda functions, SQS queues
├── database/      # DynamoDB table
└── monitoring/    # CloudWatch alarms, SNS, CloudTrail

---

## Key Architecture Decisions

- **Fully serverless** — No EC2, no ECS. Every service scales to zero and back automatically, matching AgentFlow's bursty unpredictable traffic patterns
- **Async job processing** — SQS decouples API acknowledgment from job execution, ensuring sub-200ms response times regardless of agent complexity
- **Billing captured at the edge** — API Gateway records the billable event before any downstream failures can cause missed or duplicate billing
- **PAY_PER_REQUEST DynamoDB** — Matches bursty traffic without provisioned waste
- **Per-customer throttling** — API Gateway rate limiting prevents noisy neighbor impact across 2,000 customers
- **RPO zero** — DynamoDB PITR ensures no job or billing data is ever lost

---

## Architecture Note — WAF Association

`aws_wafv2_web_acl_association` does not support API Gateway v2 HTTP APIs. The WAF Web ACL is provisioned and ready. In a production deployment it would be associated via Amazon CloudFront sitting in front of API Gateway, which fully supports WAFv2 association.

---

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

---

## Author

**Montana Williams** | AWS Certified Cloud Practitioner | Help Desk → Cloud Engineer | Active Security Clearance

[LinkedIn](https://www.linkedin.com/in/montana-williams-5b2b81258) • [GitHub](https://github.com/montana-williams)