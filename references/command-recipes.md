# GitMem command recipes

Use these recipes when executing GitMem operations from a local project root.
All commands assume the GitMem repository lives at `.gitmem/.git` and the project worktree is `.`.

## Base form

```bash
git --git-dir=.gitmem/.git --work-tree=. <command>
```

## Initialize GitMem

```bash
mkdir -p .gitmem
git init .gitmem
git --git-dir=.gitmem/.git --work-tree=. status
```

## Commit one edited file

```bash
git --git-dir=.gitmem/.git --work-tree=. add -- src/api.ts
git --git-dir=.gitmem/.git --work-tree=. commit -m "agent(edit): src/api.ts\n\nreason: add retry logic"
```

## Show file history

```bash
git --git-dir=.gitmem/.git --work-tree=. log -- src/api.ts
```

## Show recent changes

```bash
git --git-dir=.gitmem/.git --work-tree=. log -n 10
```

## Diff two commits for one file

```bash
git --git-dir=.gitmem/.git --work-tree=. diff <commit_a> <commit_b> -- src/api.ts
```

## Roll back one file to a prior version

```bash
git --git-dir=.gitmem/.git --work-tree=. checkout <commit> -- src/api.ts
```

After a rollback, create a new GitMem commit explaining the restoration.

## Create a checkpoint tag

```bash
git --git-dir=.gitmem/.git --work-tree=. tag gitmem-checkpoint-feature-working
```

## Undo the most recent GitMem change

```bash
git --git-dir=.gitmem/.git --work-tree=. reset --hard HEAD~1
```

## Time-travel the whole project

```bash
git --git-dir=.gitmem/.git --work-tree=. checkout <commit>
```

## Loop guard checklist

Before continuing repeated edits on one file, check:

1. does the same file appear in the last 5 commits?
2. is there a relevant checkpoint tag for a known-good state?
3. should the user be warned before more edits?

Suggested warning:

```text
This file has been modified multiple times recently without a stable checkpoint.
Consider restoring a previous stable version or creating a checkpoint before more edits.
```
