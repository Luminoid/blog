---
title: 'Git: Amateur Guide'
date: 2018-01-25 00:27:11
updated:
categories:
- Tool
- Git
tags: Git
keywords: Git
---

Collecting from *Version Control with Git* & *Git Manual*

## Concept
### Git
Git is a distributed version control system (DVCS).

### Repository
A Git repository is simply a database containing all the information needed to retain and manage the revisions and history of a project. Within a repository, Git maintains two primary data structures, the object store and the index.
The **index** is a temporary and dynamic binary file that describes the directory structure of the entire repository. More specifically, the index captures a version of the project’s overall structure at some moment in time. The project’s state could be represented by a commit and a tree from any point in the project’s history.
The **Git object store** is organized and implemented as a content-addressable storage system(SHA1 hash value => object).

<!-- more -->

#### Remote Repository
##### origin
The default upstream repository.

##### refspec
The mapping between remote ref and local ref.
Syntax: `[+]source:destination`

 Operation | Source | Destination | eg.
 --------- | ------ | ----------- | ---
 push | Local ref being pushed | Remote ref being updated | `+refs/heads/*:refs/heads/*`
 fetch | Remote ref being fetched | Local ref being updated | `+refs/heads/*:refs/remotes/remote/*`

#### Bare Repository
A bare repository is normally an appropriately named directory with a `.git` suffix that does not have a locally checked-out copy of any of the files under revision control. A published repository should be bare.

### Git Object Types
#### Blob
Binary large object. Each version of a file is represented as a blob.
#### Tree
A tree object represents one level of directory information. It records blob identifiers, path names, and a bit of metadata for all the files in one directory.
#### Commit
A commit object holds metadata for each change introduced into the repository, including the author, committer, commit date, and log message. Each commit points to a tree object that captures, in one complete snapshot, the state of the repository at the time the commit was performed.
#### Tag
A tag object assigns an arbitrary yet presumably human readable name to a specific object, usually a commit.

### Git File Classifications
#### Tracked
A tracked file is any file already in the repository or any file that is staged in the index. To add a new file `<file>` to this group, run `git add <file>`.
#### Ignored
An ignored file must be explicitly declared invisible or ignored in the repository.
#### Untracked
Git considers the entire set of files in your working directory and subtracts both the tracked files and the ignored files to yield what is untracked.

### Database Comparison
 System | Index mechanism | Data store
--|--|--
 Traditional database | Indexed Sequential Access Method (ISAM) | Data records
 Unix file system | Directories (/path/to/file) | Blocks of data
 Git | .git/objects/hash, tree object contents | Blob objects, tree objects

### VCS Comparison
 System | Diff
--|--
 SVN | track revisions and store changes
 Git | each commit contains an independent tree

### Working tree
The tree of actual checked out files. The working tree normally contains the contents of the HEAD commit's tree, plus any local changes that you have made but not yet committed.
#### Clean
A working tree is clean, if it corresponds to the revision referenced by the current head.

### Identifying Commit
Git implements the history of commits within a repository as a DAG(Directed Acyclic Graph).
- **Absolute Commit Name**: hash identifier
- **Relative Commit Name**:
    - symref: Symbolic reference in the format like `refs/some/thing`
    - `^`: Select a different parent within a single generation
    - `~`: Go back before an ancestral parent and select a preceding generation

    - <img src="/blog/Git-Amateur-Guide/RelativeCommitName.png" alt="Relative Commit Name" style="width:600px;">
- `HEAD`: a symref refers to the most recent commit on the current branch
- `detached HEAD`: a ref to an arbitrary commit that isn't the tip of any particular branch

### Branch
A branch is an active line of development.

#### master
The default development branch.

#### Remote-tracking branch
A ref that is used to follow changes from another repository.
During a clone operation, Git creates a remote-tracking branch in the clone for each topic branch in the upstream repository. The local repository uses its remote-tracking branches to follow or track changes made in the remote repository.

#### Upstream Branch
The default branch that is merged into the branch in question.

### Merge Strategies
All branches are created equal.
#### Degenerate Merges
- **Already up-to-date**: All the commits from the other branch (its HEAD) are already present in your target branch (eg. perform a merge and immediately follow it with the exact same merge request)
- **Fast-forward**: Your branch HEAD is already fully present and represented in the other branch. This is the inverse of the Already up-to-date case.

#### Normal Merges
- **Resolve**: The resolve strategy operates on only two branches, locating the common ancestor as the merge basis and performing a direct three-way merge by applying the changes from the merge base to the tip of the other branch HEAD onto the current branch.
- **Recursive**(default): The recursive strategy also operates on two branches. However, it is designed to handle the scenario where there is more than one merge base between the two branches. In these cases, Git forms a temporary merge of all of the common merge bases and then uses that as the base from which to derive the resulting merge of the two given branches via a normal three-way merge algorithm.
- **Octopus**: The octopus strategy is specifically designed to merge together more than two branches simultaneously. It calls the recursive merge strategy multiple times, once for each branch you are merging.

### Action
#### Checkout
Updating all or part of the working tree with a tree object or blob from the object database, and updating the index and HEAD if the whole working tree has been pointed at a new branch.
#### Fetch
Fetching a branch means to get the branch's head ref from a remote repository, to find out which objects are missing from the local object database, and to get them, too.
#### Merge
Bringing the contents of another branch into the current branch.

### Garbage Collection
`git gc`:
1. perform periodic garbage collection (cleaning up dangling objects)
2. optimize the size of the repository by locating unpacked objects (loose objects) and creating pack files for them

#### Automatic Garbage Collection Situation
- too many loose objects in the repository
- pushing to a remote repository
- using some commands that might introduce many loose objects
- requesting explicitly using commands such as `git reflog expire`

#### Manual Garbage Collection Situation
- running `git filter-branch`
- using some commands that might introduce many loose objects, like a large rebase effort

### Hooks
Hooks are programs you can place in a hooks directory to trigger actions at certain points in git's execution.
``` bash
git help hooks
```

## Command
<img src="/blog/Git-Amateur-Guide/CommonCommands.png" alt="Common Commands" style="width:800px;">

### Basic
`--`: Double dash can be used to contrast the control portion of the command line from a list of operands, such as filenames.
You may need to use the double dash to separate and explicitly identify filenames if they might otherwise be mistaken for another part of the command. For example, if you happened to have both a file and a tag named `main.c`, then you will get different behavior:
``` bash
# Checkout the tag named "main.c"
$ git checkout main.c

# Checkout the file named "main.c"
$ git checkout -- main.c
```

`git <command> --dry-run`: Don't actually execute the command, just show what the command would do

### Init
#### git clone
Clone a repository into a new directory
``` bash
git clone <repository>
```
#### git init
Create an empty Git repository or reinitialize an existing one
``` bash
git init
```
Run as if git was started in `<path>` instead of the current working directory
``` bash
git --git-dir <path> init
```

### State
#### git show
Show various types of objects
``` bash
git show <object>
```
Get old version of a file
``` bash
git show <commit>:<path> [> <output>]
```
Reconnect a lost file
``` bash
git show <blob_SHA1> > <file>
```

#### git rev-parse
Pick out and massage parameters
``` bash
git rev-parse <args>
```

#### git blame
Show what revision and author last modified each line of a file
``` bash
git blame [-L <range>] <file>
```

#### git status
Show the working tree status
``` bash
git status
```

#### git reflog
Manage reflog information (including cloning, pushing, making new commits, changing or creating branches, rebase operations, reset operations)
eg. `HEAD@{1}` references the previous commit for the branch
``` bash
git reflog [<ref>]
```

#### git log
Print the log message associated with every commit in your history that is reachable from `<commit>`
``` bash
git log <commit> [<path>...]
```
`--follow`: Continue listing the history of a file beyond renames

Show the commits from `start` to `end` (`start` not included).
`start..end`: the set of commits reachable from `end` that are not reachable from `start`
``` bash
git log start..end [<path>...]
```
Look for differences that change the number of occurrences of the specified string (i.e. addition/deletion) in a file. (Pickaxe)
``` bash
git log -S<string> <commit> [<path>...]
```

`pickaxe` can be used to search a series of commit differences; whereas `git grep` can be used to search the repository tree at a specific point in that history

### File
#### git add
Add file contents to the index
``` bash
git add <file>...
```
Add, modify, and remove index entries to match the working tree
``` bash
git add -A
```
Stage hunks of patch interactively
``` bash
git add -p
```

#### git mv
Move or rename a file, directory or symlink.
``` bash
git mv <source> <destination>
```

#### git rm
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

### Commit
#### Altering Commits
##### git reset
Reset current HEAD to the specified state
``` bash
git reset [<option>] <commit>
```
 Option | HEAD | Index | Working directory
--|---|---|--
 `--soft` | Yes | No | No
 `--mixed` | Yes | Yes | No
 `--hard` | Yes | Yes | Yes

Unstage files
``` bash
git reset HEAD <file>...
```
Eliminate the topmost commit
``` bash
git reset HEAD^
```
Adjust the commit message
``` bash
git reset --soft HEAD^
git commit
```

##### git cherry-pick
Apply the changes introduced by some existing commits
``` bash
git cherry-pick <commit>...
```

##### git revert
Revert some existing commits: record some new commits to reverse the effect of some earlier commits (often only a faulty one)
``` bash
git revert <commit>...
```

##### Changing the Top Commit
``` bash
git commit --amend
```

##### Comparison
 Command | Usage Scenario |
--|--
 `git checkout` | Switch branches; Check out files from a particular commit
 `git reset` | Reset the current branch’s HEAD reference
 `git revert` | Work on commits (without altering history)

#### Diff
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

#### Stash
Stash the changes in a dirty working directory away
``` bash
git stash [save [<message>]]
```
The ignored files and the untracked files are also stashed and cleaned
``` bash
git stash save -a [<message>]
```
List the stashes that you currently have
``` bash
git stash list
```
Show the changes recorded in the stash as a diff between the stashed state and its original parent
``` bash
git stash show [<stash>]
```
Remove a single stashed state from the stash list and apply it on top of the current working tree state
``` bash
git stash pop [<stash>]  # pop = apply + drop
```

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
git show-branch [-r | -a] [--more=<n>]
```
Delete branches
``` bash
git branch -d <branchname>
```
Figure out if you are on a detached `HEAD`
``` bash
$ git branch
* (no branch)
  master
```

#### Checkout
Check out branches
``` bash
git checkout <branch>
```
Create and check out a new branch
``` bash
git checkout -b <new_branch> [<start-point>]
```
Check out remote branch
``` bash
git fetch origin
git checkout -b <local_branch> origin/<remote_branch>
```
Check out remote branch (With Git versions ≥ 1.6.6)
``` bash
git fetch
git checkout <branch>
```
Push a new local branch to a remote repository
``` bash
git checkout -b <branch>
git push -u origin <branch>
```

#### Merge
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

#### Rebase
Reapply commits on top of another base tip
``` bash
git rebase <branch>
```
Edit the list of the commits before rebasing (pick, reword, edit, squash, etc.)
``` bash
git rebase -i <branch>
```
eg.
``` bash
git rebase -i master~3
```

### Remote Repository
Mechanisms for exchanging commits and keeping distributed repositories synchronized:
- Git-native protocol
    - the Git-native protocol can be tunneled over Secure Shell(SSH) for secure, authenticated connections
- HTTP protocol
- Git patch
    - `git format-patch`: Prepare patches for e-mail submission
    - `git send-email`: Send a collection of patches as emails
    - `git am`: Apply a series of patches from a mailbox

#### git remote
Manage set of tracked repositories
``` bash
git remote
```
Adds a remote named `<name>` for the repository at `<url>`.
``` bash
git remote add <name> <url>
```
Gives some information about the remote `<name>`.
``` bash
git remote show <name>...
```
Fetch updates for a named set of remotes in the repository as defined by remotes.
``` bash
git remote update
```
Deletes all stale remote-tracking branches under `<name>`.
``` bash
git remote prune <name>...
```
#### git fetch
Download objects and refs from another repository
``` bash
git fetch
```
#### git pull
Fetch from and integrate with another repository or a local branch
``` bash
git pull  # pull = fetch + merge
```
#### git push
Update remote refs along with associated objects
``` bash
git push
```
Find a ref that matches master in the source repository (most likely, it would find `refs/heads/master`), and update the same ref(e.g. `refs/heads/master`) in origin repository with it.
``` bash
git push origin master
```
Push the current branch and set the remote as upstream
``` bash
git push --set-upstream <repository> <refspec>
```

### Advanced
#### git filter-branch
`git filter-branch`: Rewrite Git revision history by rewriting the branches, applying custom filters on each revision.

Remove a file from all commits
``` bash
git filter-branch --tree-filter 'rm -f <file>' master
```
Rewrite the commit messages
``` bash
git filter-branch --msg-filter 'sed <command>' master
```
Remove one line in file from all commits
``` bash
git filter-branch --tree-filter "test -f <file> && sed -i '' \"/<content>/ d\" <file> || echo skip" -- --all
```
Faster version of removing a file, translating any tag refs from a prefiltered state into the new postfiltered repository, operating on all branches
``` bash
git filter-branch --index-filter 'git rm --cached --ignore-unmatch <file>' \
--tag-name-filter cat \
-- --all
```
Turn a subdirectory into a repository of its own
``` bash
git filter-branch --subdirectory-filter <directory> -- --all
```

#### git fsck
Verify the connectivity and validity of the objects in the database (File System ChecK)
``` bash
git fsck
```
`--no-reflogs`: Do not consider commits that are referenced only by an entry in a reflog to be reachable

#### git rerere
`git rerere`: Reuse recorded resolution of conflicted merges

### Config
`git config`: Get and set repository or global options

Set `ignoreCase` to `false`
``` bash
git config core.ignorecase false
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
`config`: repository-specific configuration settings
`index`: index
`logs`: reflogs
`objects/`: Git’s objects
`refs/`: refs
`refs/heads/ref`: local branches
`refs/remotes/ref`: remote tracking branches
`refs/tags/ref`: tags
`refs/stash`: stash

Git’s Object Model and Files
<img src="/blog/Git-Amateur-Guide/InitialState.png" alt="Initial State" style="width:300px;">

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
<img src="/blog/Git-Amateur-Guide/EditFiles.png"  alt="Edit Files" style="width:300px;">

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
<img src="/blog/Git-Amateur-Guide/StageFiles.png" alt="Stage Files" style="width:400px;">

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
<img src="/blog/Git-Amateur-Guide/CommitFiles.png" alt="Commit Files" style="width:400px;">
