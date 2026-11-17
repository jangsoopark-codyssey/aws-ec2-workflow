# Handoff

Use a handoff note when work will continue in a different Codex session or on another computer. Codex CLI conversation history may be local to the machine, so the note should carry only the project context needed to resume the work.

## Location and naming

- Store task-specific handoff notes in `agent/handoff/`.
- Start from `agent/handoff/TEMPLATE.md`.
- Use `YYYY-MM-DD-<task>.md` for each handoff, for example `2026-11-18-aws-ec2-mission.md`.
- Keep the note concise and update or remove stale notes when they are no longer useful.

## Required content

Record the objective, current status, completed work, important decisions and constraints, relevant files and evidence, checks actually performed, unresolved items, and one concrete next action. Include Git branch and commit state when relevant. Separate verified facts from assumptions and planned work.

Do not copy the full conversation. Do not include passwords, access keys, private keys, session tokens, or unnecessary personal or account information.

## Resuming work

The next agent must read the handoff note, inspect the current repository and Git state, and verify that referenced files and results still exist before continuing. The handoff is context, not proof that listed work remains unchanged or that an action is authorized. User approval applies only to the exact reviewed changes; obtain a fresh review and approval if those changes have changed.
