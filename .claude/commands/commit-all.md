# Commit All

Group current changes into meaningful semantic commits for a selected CDE workspace scope.

This command must always be run from the CDE workspace root.

Optional argument: `$ARGUMENTS`

Supported scopes:

* empty argument → workspace root scope
* `workspace` → workspace root scope
* `CDE-Backend` → backend repository scope
* `CDE-Frontend` → frontend repository scope
* `backend` → alias for `CDE-Backend`
* `frontend` → alias for `CDE-Frontend`

Do not push or create a pull request unless the user explicitly asks for it.

## Scope Resolution

Resolve `$ARGUMENTS` before running Git commands.

If `$ARGUMENTS` is empty:

```txt
scope = workspace
target = CDE workspace root
```

If `$ARGUMENTS` is `workspace`:

```txt
scope = workspace
target = CDE workspace root
```

If `$ARGUMENTS` is `CDE-Backend` or `backend`:

```txt
scope = backend
target = CDE-Backend/
```

If `$ARGUMENTS` is `CDE-Frontend` or `frontend`:

```txt
scope = frontend
target = CDE-Frontend/
```

If `$ARGUMENTS` contains anything else, stop and ask the user to choose one of:

```txt
workspace
CDE-Backend
CDE-Frontend
```

## Repository Root Rules

First, verify the current directory is the CDE workspace root.

The workspace root must contain:

```txt
CDE-Backend/
CDE-Frontend/
.claude/
openspec/
```

If these folders are not present, stop and ask the user to run the command from the CDE workspace root.

For `workspace` scope:

* Operate from the current workspace root.
* Include only workspace-level files.
* Do not include changes inside `CDE-Backend/`.
* Do not include changes inside `CDE-Frontend/`.

Workspace-level paths include:

```txt
README.md
CLAUDE.md
.claude/
openspec/
docs/
```

For `backend` scope:

* Change directory into `CDE-Backend/`.
* Operate only inside that Git repository.
* Do not include workspace-level files.
* Do not include frontend files.

For `frontend` scope:

* Change directory into `CDE-Frontend/`.
* Operate only inside that Git repository.
* Do not include workspace-level files.
* Do not include backend files.

## Snapshot Commands

For the resolved target, run:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git diff --stat
git diff
git log --oneline -10
```

For workspace scope, also check that backend/frontend changes are not accidentally included:

```bash
git status --short CDE-Backend CDE-Frontend
```

If backend/frontend changes exist while scope is `workspace`, report them as out of scope and do not commit them.

## Safety Checks

Before proposing or creating commits, check for sensitive or suspicious files.

Stop and ask the user before committing if any changed file includes:

* `.env`
* `.env.*`
* credentials
* secrets
* tokens
* private keys
* certificates
* connection strings
* production config
* storage keys
* JWT secrets
* API keys

Also stop if the diff appears to include real secrets or private credentials.

Never use:

```bash
git add .
git add -A
git commit --amend
git reset --hard
git clean -fd
git push --force
git push --force-with-lease
git commit --no-verify
```

## Commit Grouping Rules

Group changes by semantic intent.

Allowed commit types:

* `feat`
* `fix`
* `refactor`
* `test`
* `docs`
* `chore`
* `config`

Recommended scopes:

For workspace scope:

* `workspace`
* `claude`
* `openspec`
* `docs`

For backend scope:

* `backend`
* `api`
* `models`
* `database`
* `auth`
* `tests`

For frontend scope:

* `frontend`
* `viewer`
* `models`
* `ui`
* `state`
* `tests`

Create multiple commits when changes are independent.

Do not mix unrelated changes in the same commit.

Do not mix workspace, backend and frontend changes in one commit.

Examples:

```txt
config(claude): add handoff command
docs(workspace): update AI workflow README
chore(openspec): archive workspace cleanup change
fix(models): include idImage in update dto values
feat(viewer): add model thumbnail navigation
```

Use the recent repository style from `git log --oneline -10` when possible.

If `$ARGUMENTS` contains extra context after the scope, use it as optional message context, but do not force it into commit messages if it does not accurately describe the changes.

## Required Flow

### 1. Analyze

Inspect current changes and classify them by intent.

Return:

1. Resolved scope.
2. Target path.
3. Git repository root.
4. Current branch.
5. Changed files in scope.
6. Changed files explicitly out of scope.
7. Sensitive-file check result.
8. Proposed commit groups.
9. Proposed commit messages.
10. Files in each commit group.
11. Any ambiguity or risk.

### 2. Approval Gate

Before committing, ask:

```txt
Approve this commit plan?
```

Do not create commits until the user explicitly approves.

If the grouping is ambiguous, ask the user before committing.

### 3. Commit Per Group

For each approved group:

* Stage only the files in that group.
* Use explicit file paths.
* Do not stage unrelated files.
* Do not stage out-of-scope files.
* Commit with the approved semantic message.

Use:

```bash
git add <file1> <file2>
git commit -m "<type(scope): message>"
```

### 4. Push

Do not push by default.

Only push if the user explicitly asks for push.

If pushing is requested:

* Use normal `git push`.
* If upstream is missing, use `git push -u origin <current-branch>`.
* Never force push.

### 5. Pull Request

Do not create a PR by default.

Only create a PR if the user explicitly asks for PR creation.

If PR creation is requested:

* Check whether `gh` is available and authenticated.
* Target `develop` unless the user specifies another base branch.
* Use a concise title and useful body.
* If `gh` is unavailable, print the exact command the user should run.

### 6. Final Summary

Return:

1. Scope used.
2. Commits created, with hash and subject.
3. Files included in each commit.
4. Push status.
5. PR status.
6. Remaining uncommitted changes in scope.
7. Remaining out-of-scope changes.
8. Recommended next action.
