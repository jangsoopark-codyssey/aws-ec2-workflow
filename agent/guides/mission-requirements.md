# Mission Requirements

Use this as the self-contained requirements reference for the AWS web-service deployment exercise. The project does not depend on an assignment PDF being present.

## Required configuration

- Region: Seoul (`ap-northeast-2`).
- One VPC, one public subnet, and an Internet Gateway attached to the VPC.
- The subnet route table has `0.0.0.0/0` directed to the Internet Gateway.
- One EC2 instance in the public subnet runs a web server; local `curl http://localhost` returns HTTP 200.
- The instance has outbound internet access.
- Security group: HTTP (80) is reachable from `0.0.0.0/0`; SSH (22) is limited to the learner's current IP or a specified range. Never allow all ports from `0.0.0.0/0`.
- Use a dedicated IAM user or role with only the permissions needed for the exercise. Do not use root or grant `AdministratorAccess`.
- Verify external access using either a browser at `http://<public-ip>` or `GET http://<public-ip>/health` returning HTTP 200 and a fixed response.

## Cost and cleanup

Prefer an eligible micro instance and begin with 8–10 GiB of EBS storage. Do not promise zero cost: eligibility and charges vary by account and AWS terms. Track created resources and verify cleanup of EC2, EBS volumes, Elastic IPs, Internet Gateway, VPC, subnets, and route tables. Check NAT Gateway, load balancers, and RDS if used. A final Billing Dashboard review is recommended.

HTTPS and Docker are optional extensions. Do not present them as required unless the user expands the task.
