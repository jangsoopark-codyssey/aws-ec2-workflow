# Subagent Workflow

Use this workflow for complex tasks that benefit from independent drafting, verification, and critique. Do not delegate trivial, tightly coupled, or sensitive work when delegation adds overhead. Use subagents only when the runtime supports them; otherwise, the main agent performs the roles sequentially and must not claim subagents were used.

## Roles

### Main agent: coordinator

- Owns the conversation with the user, task scope, source selection, acceptance criteria, and final response.
- Breaks work into bounded assignments and gives each subagent the relevant context, source material, output format, and constraints.
- Assigns one writer per output file at a time. Reviewers return findings; they do not silently overwrite the producer's files.
- Reconciles disagreements, incorporates accepted findings, checks the final artifact, and reports limitations.

### Producer: author

- Creates the requested draft or artifact from the assigned sources and acceptance criteria.
- Marks assumptions and unresolved gaps; does not invent evidence or claim unperformed work.
- Reports what was created, source basis, and any decisions needing coordinator attention.

### Validator: requirements checker

- Checks each acceptance criterion against the draft and source material.
- Flags unsupported claims, omissions, contradictions, broken references, and mismatches with the requested format.
- Reports findings with precise locations and evidence; does not rewrite the whole deliverable unless assigned.

### Reviewer: independent critic

- Reads the draft as its intended audience would.
- Evaluates clarity, organization, terminology, logical flow, and likely misunderstandings.
- Separates blocking issues from optional improvements and gives actionable suggestions.

## Workflow

1. The main agent defines the deliverable, authoritative sources, constraints, and acceptance criteria.
2. The producer drafts the assigned output. Independent source research or artifact checks may run in parallel when their inputs do not depend on the draft.
3. The validator and reviewer assess the same draft independently using the shared criteria.
4. The main agent resolves conflicting findings, assigns revisions if needed, and checks the revised result against all blocking findings.
5. If a commit is requested, the main agent completes the pre-commit checks in `git-and-review.md`, stages only intended files, and presents the final staged diff, summary, and validation results to the user.
6. The main agent waits for the user's explicit approval before committing. Any change after that review requires a fresh review and approval. Without approval, leave the changes uncommitted.

## Coordination Rules

- Keep each assignment narrow, with an explicit output and completion condition.
- Share the same source-of-truth files and terminology across roles. Do not ask agents to rely on missing attachments or unstated context.
- Avoid duplicate edits to the same file. Have reviewers return comments unless they are explicitly assigned a separate output.
- Subagent approval is not user approval. The main agent must preserve the user's final review and approval gate before any commit.
- Do not expose credentials or private data in delegated context.
- Do not let delegation authorize external communication, AWS changes, publication, or other consequential actions that the user has not requested.
- The main agent remains accountable for the final result; subagent agreement does not replace source checks.
