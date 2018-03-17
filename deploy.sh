#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error! Usage: sh deploy.sh <commit_message>"
    exit 1
fi

commit_message=$1

hexo clean
hexo algolia
git add -A
git commit -m "$commit_message"
git push
