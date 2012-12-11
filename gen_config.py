#! /usr/bin/env python
import yaml
import pystache

approuter_config = yaml.load(open('./etc/approuter.yaml'))
print(approuter_config)
print(pystache.render(open('./templates/nginx.conf').read(), approuter_config))
