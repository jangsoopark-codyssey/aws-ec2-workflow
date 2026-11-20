# Project Structure Guide

This repository documents AWS EC2 and networking concepts and records the B3-1 AWS deployment mission. Check the current repository tree before adding or moving files. Prefer updating an existing document over creating a duplicate.

## Repository map

```text
.
├── AGENTS.md
├── Draft/                         # Git submodule: the Draft web application
├── README.md                      # Repository entry point
├── agent/
│   ├── guides/                    # Project workflow and documentation guidance
│   └── handoff/                   # Dated project handoffs and template
├── assets/images/                 # Mission evidence screenshots
├── docker/                        # Dockerfile and NGINX configuration
├── docs/                          # Mission records and AWS/networking documentation
│   └── terminology/
│       ├── aws/                   # AWS service and resource topics
│       └── networking/            # General networking topics
└── scripts/                       # Docker and HTTPS setup/run scripts
```

## Root files and directories

- `README.md` is the repository entry point. Keep the project purpose, setup flow, and links to detailed documentation there.
- `AGENTS.md` contains repository-specific instructions. Read it before changing project files.
- `Draft/` is the Draft application submodule. Do not duplicate its application source in this repository.
- `docker/` contains the NGINX container build and server configuration, including `Dockerfile`, `Dockerfile.dockerignore`, and `nginx.conf`.
- `scripts/` contains scripts for installing Docker, running the container, installing Certbot, and enabling HTTPS with an IP certificate.
- `assets/images/` contains evidence captured during the AWS mission. Keep filenames numbered and descriptive; do not include credentials, private keys, or other secrets.

## Agent guidance and handoffs

- `agent/guides/` contains instructions for project structure, mission requirements, documentation deliverables, development and validation, writing and formatting, Git/review, and handoffs.
- `agent/handoff/` contains dated handoff notes and the reusable `TEMPLATE.md`.
- Keep durable project rules in the relevant guide. Keep dated task status and open actions in a handoff note.

## Documentation layout

- `docs/terminology.md` is the glossary index. List English terms, abbreviations, and Korean descriptions, and link each term to its detailed topic document.
- `docs/terminology/aws/` contains AWS topics such as `aws.md`, `ec2.md`, `iam.md`, `ebs.md`, `elastic-ip.md`, `internet-gateway.md`, and `vpc.md`.
- `docs/terminology/networking/` contains networking topics such as `ssh.md`, `subnet.md`, and `route-table.md`.
- Detailed topic documents live under `docs/terminology/`. Before adding a topic, inspect the directory and update an existing file if it already covers the subject. Keep glossary links aligned with the actual paths and filenames.
- Mission-specific documents live directly under `docs/` unless a more specific existing directory applies:
  - `architecture.png` — architecture diagram
  - `https.md` — HTTPS setup and certificate renewal
  - `troubleshooting.md` — observed issue, investigation, fix, and result
  - `cleanup-checklist.md` — resource cleanup checklist
  - `checklist.md` — mission progress checklist
- Keep mission screenshots in `assets/images/` as shown in the current tree. Use `docs/evidence/` only if the repository is deliberately reorganized to that convention; do not create a second evidence location without updating the project guidance.

## Current documentation inventory

The current tree includes:

- `docs/architecture.png`
- `docs/checklist.md`
- `docs/https.md`
- `docs/troubleshooting.md`
- `docs/terminology.md`
- AWS topic files under `docs/terminology/aws/`
- Networking topic files under `docs/terminology/networking/`

The supplied tree names the cleanup file `docs/cleanup-ckecklist.md` (misspelled), while the mission artifact convention and prior working copy use `docs/cleanup-checklist.md`. Check the actual Git-tracked filename before editing or linking it, then use one consistent spelling and update references accordingly.

## Adding or changing files

1. Inspect the current tree and relevant existing documents.
2. Place the file in the established directory for its purpose.
3. Search for existing coverage before creating another terminology or mission document.
4. Update `docs/terminology.md`, `README.md`, or other indexes when adding a document that should be discoverable.
5. Update this guide and relevant indexes when a structural change makes their descriptions inaccurate.
6. Keep generated evidence and configuration free of secrets.
