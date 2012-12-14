#! /usr/bin/env bash

CTRL_FILE=stop$$
echo "control file $CTRL_FILE"
while [ ! -f $CTRL_FILE ]
do
    echo "starting $1"
    #$($1)
    sleep 5
done
echo "no longer restarting $1"
