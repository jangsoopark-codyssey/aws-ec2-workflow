# Documentation Deliverables

Use this guide when preparing the exercise submission. Report only work supported by actual evidence.

## README

Summarize the architecture and verification. State which external check was performed, include its URL or IP when safe, and link to the evidence image. Mark unfinished steps and placeholders clearly.

## Architecture diagram

Show the VPC, public subnet, route table/default route, Internet Gateway, EC2/web server, security group, and external-to-service traffic flow. Use `docs/architecture.png` or `docs/architecture.pdf`.

## Troubleshooting report

For at least one real issue, record symptom, hypothesis, verification, action, result, and prevention. Do not invent an incident. If none has been observed yet, provide a clearly labeled template and mark the incident record incomplete.

## Cleanup checklist

Record resource status and evidence. Distinguish created resources, unused resources, and items still needing verification. Cover EC2, EBS, Elastic IP, Internet Gateway, VPC, subnet, and route table; include optional billable resources if created.

## Evidence

Provide a screenshot demonstrating the external response. For the Docker bonus, also include `docker ps` output. Do not alter evidence in a way that changes its meaning; remove secrets and unrelated personal information before sharing.
