#!/bin/bash

# Generate & deploy site
commit_message=""
check_commit_msg(){
    if   [ "$*" = "-post" ]; then
        commit_message="update posts"
    elif [ "$*" = "-package" ]; then
        commit_message="update packages"
    elif [ "$*" = "-theme" ]; then
        commit_message="update theme"
    else
        commit_message="$*"
    fi
}

if [ $# -eq 2 ] && ([ $1 = "deploy" ] || [ $1 = "d" ]); then
    check_commit_msg $2

    echo "$ hexo clean"
    hexo clean

    echo "$ hexo generate"
    if ! hexo generate; then
        echo "Error! hexo generate failed"
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
    exit 0
fi

# Compress images
if [ $# -eq 1 ] && ([ $1 = "compress" ] || [ $1 = "c" ]); then
    cd source/_posts
    pngquant --ext .png --force 256 */*.png
    echo "PNG images under source/_posts/*/ have been compressed."
    exit 0
fi

# Start hexo server
if [ $# -eq 1 ] && ([ $1 = "server" ] || [ $1 = "s" ]); then
    hexo server
    exit 0
fi

# Help
b=$(tput bold) # bold
e=$(tput sgr0) # end
if [ $# -eq 1 ] && ([ $1 = "help" ] || [ $1 = "h" ]); then
    echo "command.sh [compress|c]                   Compress PNG images under ${b}source/_posts/*/${e} using pngquant"
    echo "command.sh [deploy|d] <commit_message>    Generate & deploy site"
    echo "command.sh [deploy|d] -post               Alias for ${b}command.sh deploy \"update posts\"${e}"
    echo "command.sh [deploy|d] -package            Alias for ${b}command.sh deploy \"update packages\"${e}"
    echo "command.sh [deploy|d] -theme              Alias for ${b}command.sh deploy \"update theme\"${e}"
    echo "command.sh [help|h]                       Display help information"
    echo "command.sh [server|s]                     Start hexo server locally"
    exit 0
fi

# Error
echo "Error! Usage: command.sh [compress|deploy <commit_message>|help|server]"
exit 1