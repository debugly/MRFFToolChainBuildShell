#! /usr/bin/env bash

REMOTE_REPO=$1
LOCAL_WORKSPACE=$2
REF_REPO=$3

if [ -z $1 -o -z $2 -o -z $3 ]; then
    echo "invalid call pull-repo.sh '$1' '$2' '$3'"
elif [ ! -d $LOCAL_WORKSPACE ]; then
    git clone --reference $REF_REPO $REMOTE_REPO $LOCAL_WORKSPACE
    cd $LOCAL_WORKSPACE
    git repack -a
else
    cd $LOCAL_WORKSPACE
    origin=$(git remote get-url origin)
    if [[ "$origin" != "$REMOTE_REPO" ]]; then
        git remote remove origin
        git remote add origin "$REMOTE_REPO"
        echo "force update origin to: $REMOTE_REPO"
    fi
    git fetch --all --tags
    cd - > /dev/null
fi
