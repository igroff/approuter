#! /usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/environment
PIDS=
for pidfile in ${RUN_DIR}/*;
do
    if [ -f $pidfile ]; then
        PIDS="${PIDS} `cat $pidfile`"
    fi
done
if [ "${PIDS}x" != "x" ]; then
    ps $PIDS
fi
