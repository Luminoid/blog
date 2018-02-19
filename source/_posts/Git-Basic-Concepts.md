---
title: 'Git: Basic Concepts'
date: 2018-01-25 00:27:11
updated:
categories:
  - Tool
  - Git
tags: Git
keywords: Git
---

<!-- TOC -->

Collecting from *Version Control with Git*

## Repository
A Git repository is simply a database containing all the information needed to retain and manage the revisions and history of a project. Within a repository, Git maintains two primary data structures, the object store and the index.
The **index** is a temporary and dynamic binary file that describes the directory structure of the entire repository. More specifically, the index captures a version of the project’s overall structure at some moment in time. The project’s state could be represented by a commit and a tree from any point in the project’s history.
The **Git object store** is organized and implemented as a content-addressable storage system(SHA1 hash value => object).

<!-- more -->

## Git Object Types
### Blob
Binary large object. Each version of a file is represented as a blob.
### Tree
A tree object represents one level of directory information. It records blob identifiers, path names, and a bit of metadata for all the files in one directory.
### Commit
A commit object holds metadata for each change introduced into the repository, including the author, committer, commit date, and log message. Each commit points to a tree object that captures, in one complete snapshot, the state of the repository at the time the commit was performed.
### Tag
A tag object assigns an arbitrary yet presumably human readable name to a specific object, usually a commit.

## Git File Classifications
### Tracked
A tracked file is any file already in the repository or any file that is staged in the index. To add a new file `somefile` to this group, run `git add somefile`.
### Ignored
An ignored file must be explicitly declared invisible or ignored in the repository.
### Untracked
Git considers the entire set of files in your working directory and subtracts both the tracked files and the ignored files to yield what is untracked.

## Database Comparison
 System | Index mechanism | Data store
--|--|--
 Traditional database | Indexed Sequential Access Method (ISAM) | Data records
 Unix file system | Directories (/path/to/file) | Blocks of data
 Git | .git/objects/hash, tree object contents | Blob objects, tree objects

## VCS Comparison
 System | Diff
--|--
 SVN | track revisions and store changes
 Git | each commit contains an independent tree

## Identifying Commit
Git implements the history of commits within a repository as a DAG(Directed Acyclic Graph).
- `HEAD`: a symref refers to the most recent commit on the current branch
- **Absolute Commit Name**: hash identifier
- **Relative Commit Name**:
    - `^`: Select a different parent within a single generation
    - `~`: Go back before an ancestral parent and select a preceding generation

    - <img src="/blog/Tool/Git/Git-Basic-Concepts/RelativeCommitName.png" height="200px" alt="Relative Commit Name">

## Merge Strategies
All branches are created equal.
### Degenerate Merges
- **Already up-to-date**: All the commits from the other branch (its HEAD) are already present in your target branch (eg. perform a merge and immediately follow it with the exact same merge request)
- **Fast-forward**: Your branch HEAD is already fully present and represented in the other branch. This is the inverse of the Already up-to-date case.

### Normal Merges
- **Resolve**: The resolve strategy operates on only two branches, locating the common ancestor as the merge basis and performing a direct three-way merge by applying the changes from the merge base to the tip of the other branch HEAD onto the current branch.
- **Recursive**(default): The recursive strategy also operates on two branches. However, it is designed to handle the scenario where there is more than one merge base between the two branches. In these cases, Git forms a temporary merge of all of the common merge bases and then uses that as the base from which to derive the resulting merge of the two given branches via a normal three-way merge algorithm.
- **Octopus**: The octopus strategy is specifically designed to merge together more than two branches simultaneously. It calls the recursive merge strategy multiple times, once for each branch you are merging.

## Command
### Common
Move or rename a file, directory or symlink.
``` bash
git mv <source> <destination>
```

### Commit
Print the log message associated with every commit in your history that is reachable from `<commit>`
``` bash
git log <commit> [<path>...]
```
Show the commits from `start` to `end` (`start` not included).
`start..end`: the set of commits reachable from `end` that are not reachable from `start`
``` bash
git log start..end [<path>...]
```
Look for differences that change the number of occurrences of the specified string (i.e. addition/deletion) in a file. (Pickaxe)
``` bash
git log -S<string> <commit> [<path>...]
```
Show what revision and author last modified each line of a file
``` bash
git blame [-L <range>] <file>
```

### Diff
`git diff` operates on two different end points; `git log` operates on a set of commits.

Differences between the working directory and the index
``` bash
git diff [<path>...]
```
Differences between the working directory and the given `<commit>`
``` bash
git diff <commit> [<path>...]
```
Differences between the index and the given `<commit>`
``` bash
git diff --cached <commit> [<path>...]
```
Differences between the two commits
``` bash
git diff <commit1> <commit2> [<path>...]
```

`--stat`: Generate a diffstat

### Branch
Create branches
``` bash
git branch <branchname> [<start-point>]
```
List branch names(`-r`: remote; `-a`: local & remote)
``` bash
git branch [-r | -a]
```
Show branches and their commits
``` bash
git show-branch [-r | -a]
```
Check out branches
``` bash
git checkout <branch>
```
Create and check out a new branch
``` bash
git checkout -b <new_branch> [<start-point>]
```
Figure out if you are on a detached `HEAD`
``` bash
$ git branch
* (no branch)
  master
```
Delete branches
``` bash
git branch -d <branchname>
```

### Merge
Merge the `<branch>` into the current branch
``` bash
git merge <branch>
```
Locate Conflicted Files
``` bash
$ git status
On branch master
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)

	both modified:   hello

no changes added to commit (use "git add" and/or "git commit -a")it status
```

Three-way merge marker lines
``` bash
Here are lines that are either unchanged from the common ancestor, or cleanly resolved because only one side changed.
<<<<<<< yours:sample.txt
Text A
=======
Text B
>>>>>>> theirs:sample.txt
And here is another line that is cleanly resolved or unmodified.
```

### Remove
Remove files from the index
``` bash
git rm --cached <file>
```
Remove files from both the index and the working directory
``` bash
git rm <file>
```
Remove committed files
``` bash
git rm [--cached] <file>
git commit
```
Removes files even if you have altered it since your last commit
``` bash
git rm -f <file>
```
Recover old versions of files
``` bash
git checkout HEAD -- <file>
```

## Git Concepts at Work
### Initialize Git repository
``` bash
$ mkdir ~/tmp
$ cd ~/tmp
$ git init
```
Git status
``` bash
$ git status
On branch master

Initial commit

nothing to commit (create/copy files and use "git add" to track)
```
Directory structure
``` bash
$ tree -a
.
└── .git
    ├── HEAD
    ├── config
    ├── description
    ├── hooks
    │   ├── applypatch-msg.sample
    │   ├── commit-msg.sample
    │   ├── post-update.sample
    │   ├── pre-applypatch.sample
    │   ├── pre-commit.sample
    │   ├── pre-push.sample
    │   ├── pre-rebase.sample
    │   ├── pre-receive.sample
    │   ├── prepare-commit-msg.sample
    │   └── update.sample
    ├── info
    │   └── exclude
    ├── objects
    │   ├── info
    │   └── pack
    └── refs
        ├── heads
        └── tags
```
`refs/`: refs
`refs/heads/ref`: local branches
`refs/remotes/ref`: remote tracking branches
`refs/tags/ref`: tags

### Create Initial Commit
``` bash
$ echo "This is file1" > file1.txt
$ mkdir dir1
$ echo "This is file2" > dir1/file2.txt
$ git add -A
$ git commit -m "initial commit"
[master (root-commit) 4ec4dac] initial commit
 2 files changed, 2 insertions(+)
 create mode 100644 dir1/file2.txt
 create mode 100644 file1.txt
```
Git status
``` bash
$ git status
On branch master
nothing to commit, working tree clean
```
Directory structure
``` bash
$ tree -a
.
├── .git
│   ├── COMMIT_EDITMSG
│   ├── HEAD
│   ├── config
│   ├── description
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   ├── prepare-commit-msg.sample
│   │   └── update.sample
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       └── heads
│   │           └── master
│   ├── objects
│   │   ├── 09
│   │   │   └── 5ee29baa1adc16134c723b6971f7cf68dfaf1e
│   │   ├── 11
│   │   │   └── 842f14c36f932dd0f7fce95d932be65bb15984
│   │   ├── 4e
│   │   │   └── c4dac8025a96681a712705e8cf5c78aebccfc7
│   │   ├── c2
│   │   │   └── 78a75b034f58b7a2e3c9a3bf463ada390c5aa7
│   │   ├── e3
│   │   │   └── aafd04f6be707d1f6fcb6c469315c9fef4b711
│   │   ├── info
│   │   └── pack
│   └── refs
│       ├── heads
│       │   └── master
│       └── tags
├── dir1
│   └── file2.txt
└── file1.txt
```
Git’s Object Model and Files
<img src="/blog/Tool/Git/Git-Basic-Concepts/InitialState.png" height="600px" alt="Initial State">

### Edit Files
``` bash
$ echo "Another line in file1" >> file1.txt
```
Git status
``` bash
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   file1.txt

no changes added to commit (use "git add" and/or "git commit -a")
```
Git’s Object Model and Files
<img src="/blog/Tool/Git/Git-Basic-Concepts/EditFiles.png" height="600px" alt="Edit Files">

### Stage Files
`git add`: Add file contents to the object store and let the index refer to it.
``` bash
$ git add file1.txt
```
Git status
``` bash
$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   file1.txt

```
Directory structure
``` bash
$ tree -a
.
├── .git
│   ├── COMMIT_EDITMSG
│   ├── HEAD
│   ├── config
│   ├── description
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   ├── prepare-commit-msg.sample
│   │   └── update.sample
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       └── heads
│   │           └── master
│   ├── objects
│   │   ├── 09
│   │   │   └── 5ee29baa1adc16134c723b6971f7cf68dfaf1e
│   │   ├── 11
│   │   │   └── 842f14c36f932dd0f7fce95d932be65bb15984
│   │   ├── 4e
│   │   │   └── c4dac8025a96681a712705e8cf5c78aebccfc7
│   │   ├── c2
│   │   │   └── 78a75b034f58b7a2e3c9a3bf463ada390c5aa7
│   │   ├── e2
│   │   │   └── e513bd3e053452ffe9b43d66d516e51e46755e
│   │   ├── e3
│   │   │   └── aafd04f6be707d1f6fcb6c469315c9fef4b711
│   │   ├── info
│   │   └── pack
│   └── refs
│       ├── heads
│       │   └── master
│       └── tags
├── dir1
│   └── file2.txt
└── file1.txt
```
Get the content of repository objects
``` bash
$ git cat-file -p e2e513
This is file1
Another line in file1
```
Get staged contents' object name, mode bits and stage number
``` bash
$ git ls-files --stage
100644 095ee29baa1adc16134c723b6971f7cf68dfaf1e 0	dir1/file2.txt
100644 e2e513bd3e053452ffe9b43d66d516e51e46755e 0	file1.txt
```
Git’s Object Model and Files
<img src="/blog/Tool/Git/Git-Basic-Concepts/StageFiles.png" height="600px" alt="Stage Files">

### Commit Files
`git-commit`: Record changes to the repository
``` bash
$ git commit -m "update file1"
[master a123b84] update file1
 1 file changed, 1 insertion(+)
```
Git status
``` bash
$ git status
On branch master
nothing to commit, working tree clean
```
Directory structure
``` bash
$ tree -a
.
├── .git
│   ├── COMMIT_EDITMSG
│   ├── HEAD
│   ├── config
│   ├── description
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   ├── prepare-commit-msg.sample
│   │   └── update.sample
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       └── heads
│   │           └── master
│   ├── objects
│   │   ├── 09
│   │   │   └── 5ee29baa1adc16134c723b6971f7cf68dfaf1e
│   │   ├── 11
│   │   │   └── 842f14c36f932dd0f7fce95d932be65bb15984
│   │   ├── 4e
│   │   │   └── c4dac8025a96681a712705e8cf5c78aebccfc7
│   │   ├── a1
│   │   │   └── 23b845d501777ec7c0161af7096b98c2ff3957
│   │   ├── c2
│   │   │   └── 78a75b034f58b7a2e3c9a3bf463ada390c5aa7
│   │   ├── e2
│   │   │   └── e513bd3e053452ffe9b43d66d516e51e46755e
│   │   ├── e3
│   │   │   └── aafd04f6be707d1f6fcb6c469315c9fef4b711
│   │   ├── eb
│   │   │   └── 6911337f9ab1b5fb477ba6eb08e4b8c99e7344
│   │   ├── info
│   │   └── pack
│   └── refs
│       ├── heads
│       │   └── master
│       └── tags
├── dir1
│   └── file2.txt
└── file1.txt
```
Git’s Object Model and Files
<img src="/blog/Tool/Git/Git-Basic-Concepts/CommitFiles.png" height="600px" alt="Commit Files">
