#! /usr/bin/env bash

REMOTE_REPO=$1
LOCAL_WORKSPACE=$2


if [ -z $REMOTE_REPO -o -z $LOCAL_WORKSPACE ]; then
    echo "invalid call pull-repo.sh '$REMOTE_REPO' '$LOCAL_WORKSPACE'"
elif [ ! -d $LOCAL_WORKSPACE ]; then
    git clone $REMOTE_REPO $LOCAL_WORKSPACE
else
    mkdir -p "$LOCAL_WORKSPACE"
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
