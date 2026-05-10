---
title: Git Solutions Collection
date: 2023-01-22 15:58:03
categories:
  - Git
tags:
  - cli
---

Recipes for the Git situations that come up often enough to forget the exact incantation.

<!-- more -->

## Amend the last commit

```bash
git commit --amend                # also opens $EDITOR for the message
git commit --amend --no-edit      # keep the existing message
```

Don't amend a commit that's already been pushed to a shared branch; force-push rewrites others' history.

## Force-push safely

```bash
git push --force-with-lease
```

Pushes only if the remote ref is still exactly what was last fetched locally. Catches the case where someone else pushed to the same branch in the meantime. Plain `--force` will obliterate that work.

## Switch branches and discard changes (modern verbs)

`switch` and `restore` (Git 2.23+) replace the overloaded `checkout`:

```bash
git switch other-branch                  # was: git checkout other-branch
git switch -c new-branch                 # create + switch
git restore .                            # discard all unstaged changes
git restore --staged .                   # unstage everything
git restore --source=HEAD~3 file.js      # pull a single file from 3 commits ago
```

## Pull until a specific commit

[Stack Overflow](https://stackoverflow.com/questions/31462683/git-pull-till-a-particular-commit):

```bash
git fetch origin <branch>
git merge <commit_hash>
```

## "Your branch and 'origin/main' have diverged"

[Stack Overflow](https://stackoverflow.com/questions/19864934/git-your-branch-and-origin-master-have-diverged-how-to-throw-away-local-com). Discards local commits in favour of the remote:

```bash
git fetch origin
git reset --hard origin/main             # or origin/master
```

## Edit, squash, or reorder recent commits

```bash
git rebase -i HEAD~5
```

In the rebase-todo editor: `pick` keeps the commit, `reword` opens the message, `edit` pauses for amends, `squash`/`fixup` fold the commit into the previous one, deleting a line drops the commit entirely.

## Cherry-pick a single commit

```bash
git cherry-pick <hash>
git cherry-pick <hash1>^..<hash2>        # range, inclusive of both ends
```

## Find the commit that broke something

```bash
git bisect start
git bisect bad                           # current revision is broken
git bisect good <known_good_hash>
# Then test each revision Git checks out and mark it:
git bisect good   # or
git bisect bad
# When it converges, exit:
git bisect reset
```

## Work on multiple branches in parallel (worktrees)

```bash
git worktree add ../proj-fix bugfix-branch
# Same .git, separate working tree. Edit both checkouts in parallel.
git worktree remove ../proj-fix
```

## Recover a deleted branch

The reflog remembers commits even when no ref points to them:

```bash
git reflog                                # locate the tip SHA
git switch -c recovered-branch <sha>
```

## [Recover a dropped stash entry](https://stackoverflow.com/questions/89332/how-to-recover-a-dropped-stash-in-git)

If you ran the following by mistake:

```bash
git stash pop
git checkout -- .
```

Find the dangling commit and reapply it:

```bash
gitk --all $( git fsck --no-reflog | awk '/dangling commit/ {print $3}' )
git stash apply <stash_hash>
```

## [Remove all unreachable objects](https://stackoverflow.com/questions/3765234/listing-and-deleting-git-commits-that-are-under-no-branch-dangling/4528593#4528593)

> Warning: also removes any stashed entries that aren't referenced by a branch.

```bash
git reflog expire --expire-unreachable=now --all
git gc --prune=now
```

## [Commit case-sensitive-only filename changes](https://www.geeksforgeeks.org/git/how-to-commit-case-sensitive-only-filename-changes-in-git/)

```bash
git config --global core.ignorecase false
git mv filename.txt Filename.txt
git commit -m "Case sensitive file rename"
```

## [Untrack files newly added to `.gitignore`](https://stackoverflow.com/questions/1274057/how-do-i-make-git-forget-about-a-file-that-was-tracked-but-is-now-in-gitignore)

```bash
git rm --cached <file>
git rm -r --cached <folder>              # recursive, for directories
```
