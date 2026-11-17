# Git and Review

The brief history uses plain English commit subjects without a required prefix. Prefer concise, action-oriented subjects such as `Add EC2 terminology details`.

## Before committing

1. Check `git status` and inspect the complete diff. Preserve unrelated user changes and stage only files in scope.
2. Ask the validator and reviewer to inspect the actual diff against the request, source material, and applicable guides. Do not treat a summary as a substitute for reviewing the diff.
3. Fix blocking findings, then run the relevant checks, including `git diff --check`. Report checks that could not be run.
4. Stage only intended files and inspect the staged diff with `git diff --cached --check` and `git diff --cached`.
5. Present the user with a concise change summary, validation results, and the complete staged diff (or a readable diff link/view). Mark any remaining findings or limitations.
6. Stop and wait for the user's explicit approval of that reviewed state. Do not commit, amend, or push before approval. If the files change after approval, show the updated diff and request approval again.

After approval, commit only the reviewed staged changes, using a concise action-oriented subject. Do not include unrelated files. Report the commit hash and subject when complete.

Keep changes focused. In a pull request, summarize the topics changed and validation performed, and link a related issue when applicable. Include screenshots when they clarify a rendering change or provide required mission evidence.
