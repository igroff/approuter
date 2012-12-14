#! /usr/bin/env bash

MANAGED_ROOT=`pwd`/managed
ALTERNATE_ROOT=${MANAGED_ROOT}/alternates
LOG_DIR=${MANAGED_ROOT}/var/log
RUN_DIR=${MANAGED_ROOT}/var/run
START_CMD_TEMPLATE=`cat ${MANAGED_ROOT}/starter.conf`

mkdir -p ${LOG_DIR}
mkdir -p ${RUN_DIR}

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
    clone_repo_as_needed ${MANAGED_ROOT}/prod/instance1 `cat ./managed/repo.conf`
    clone_repo_as_needed ${MANAGED_ROOT}/prod/instance2 `cat ./managed/repo.conf`

    # alternates
    while read alternate 
    do
        echo "initializing alternate ${alternate}"
        ALTERNATE_DIR=${ALTERNATE_ROOT}/${alternate}
        clone_repo_as_needed ${ALTERNATE_DIR} `cat ./managed/repo.conf`
        spushd ${ALTERNATE_DIR}
        git checkout ${alternate}
        spopd
    done < ./managed/alternates.conf
}

start_instance(){
    # $1 path to instance
    # $2 port
    spushd $1
    DIR_NAME=`basename $1`
    START_CMD=`echo "${START_CMD_TEMPLATE}" | sed -e s/{{port}}/$2/g`
    START_CMD="${START_CMD}"
    echo "starting: ${START_CMD}"
    ${START_CMD} > ${LOG_DIR}/${DIR_NAME}_$2.log 2>&1 & 
    echo $! > "${RUN_DIR}/$2.pid"
}
setup_managed_repositories;
# start each of our application instances
# prod ports will be 9001, 9002
# alternates we'll start at 9050
start_instance ${MANAGED_ROOT}/prod/instance1 9001
start_instance ${MANAGED_ROOT}/prod/instance2 9002
