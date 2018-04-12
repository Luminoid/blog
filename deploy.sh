#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error! Usage: sh deploy.sh <commit_message>"
    exit 1
fi

commit_message=$1

echo "$ hexo clean"
hexo clean

echo "$ hexo algolia"
if ! hexo algolia; then
    echo "Error! Algolia failed"
    exit 2
fi

if [ ! -d "docs" ]; then
    echo "Error! No docs/ folder generated"
    exit 3
fi

echo "$ git add"
git add -A

echo "$ git commit"
git commit -m "$commit_message"

echo "$ git push"
git push
