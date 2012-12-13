#! /usr/bin/env bash
./build_output/sbin/nginx -c `pwd`/templates/nginx.smtp.conf
./bin/auth_server.py start
