---
title: Git Solutions Collection
date: 2023-01-22 15:58:03
categories: Git
tags:
---

Reference commands for common Git situations.

## Amend a commit
``` bash
git commit --amend
```

## [Git pull till a particular commit](https://stackoverflow.com/questions/31462683/git-pull-till-a-particular-commit)
``` bash
git fetch remote <branch_name>
git merge <commit_hash>
```

## [Your branch and 'origin/master' have diverged](https://stackoverflow.com/questions/19864934/git-your-branch-and-origin-master-have-diverged-how-to-throw-away-local-com)
Use `origin/main` if your default branch is `main`.
``` bash
git fetch origin
git reset --hard origin/master   # or origin/main
```

## [Remove all unreachable objects](https://stackoverflow.com/questions/3765234/listing-and-deleting-git-commits-that-are-under-no-branch-dangling/4528593#4528593)
{% note warning %}
### Warning
This command will remove all stashed objects.
{% endnote %}
``` bash
git reflog expire --expire-unreachable=now --all
git gc --prune=now
```

<!-- more -->

## [Remove tracked files in `.gitignore`](https://stackoverflow.com/questions/1274057/how-do-i-make-git-forget-about-a-file-that-was-tracked-but-is-now-in-gitignore)
Remove a file
``` bash
git rm --cached <file>
```
Remove a folder recursively
``` bash
git rm -r --cached <folder>
```

## [Recover a dropped stash entry](https://stackoverflow.com/questions/89332/how-to-recover-a-dropped-stash-in-git)
If you run the following by mistake
``` bash
git stash pop
git checkout -- .
```
First, use `gitk` to find the corresponding hash value
``` bash
gitk --all $( git fsck --no-reflog | awk '/dangling commit/ {print $3}' )
```
Then, run `git stash` to apply the stash entry
``` bash
git stash apply <stash_hash>
```
