#! /usr/bin/env bash
while read line
do
    START_CMD=`echo $line | sed -e s/{{port}}/9000/g`
    ./bin/restart_on_exit.sh "${START_CMD}" &
done < "./etc/services"
