#! /usr/bin/env bash

spushd(){ pushd $1 > /dev/null 2>&1; }
spopd(){ popd $1 > /dev/null 2>&1 ; }


clone_repo_as_needed() {
    # $1 - the directory to check
    # $2 - the repository url
    # if there is no git repo in the directory provided
    # we'll go ahead and clone it
    mkdir -p $1
    PARENT_PATH=`dirname $1`
    DIRNAME=`basename $1`
    if [ ! -d ${1}/.git ]; then
        # no git, clone
        spushd ${PARENT_PATH}
        git clone ${2} ${DIRNAME} 
        spopd
    else
        printf "repo found at $1, not cloning\n"
    fi
}

setup_managed_repositories(){
    clone_repo_as_needed ./managed/prod/instance1 `cat ./managed/repo.conf`
    clone_repo_as_needed ./managed/prod/instance2 `cat ./managed/repo.conf`

    # alternates
    while read alternate 
    do
        echo "initializing alternate ${alternate}"
        ALTERNATE_DIR=./managed/alternates/${alternate}
        clone_repo_as_needed ${ALTERNATE_DIR} `cat ./managed/repo.conf`
        spushd ${ALTERNATE_DIR}
        git checkout ${alternate}
        spopd
    done < ./managed/alternates.conf
}

setup_managed_repositories;
