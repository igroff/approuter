#! /usr/bin/env python
import os
from os import path
import shutil
import json
import tempfile
import logging
from uuid import uuid4
import requests

from flask import Flask, request, redirect, url_for
from flask import render_template, send_from_directory
from flask import Response
from werkzeug import secure_filename
from argparse import ArgumentParser


logging.basicConfig(level=logging.DEBUG)
app = Flask(__name__, static_url_path="/app_static")
################################################################################
# routes

@app.route("/auth", methods=["GET"])
def auth():
    protocol = request.headers['Auth-Protocol']
    headers = {}
    headers['Auth-Status'] = "OK"
    headers['Auth-Port'] = "110"
    headers['Auth-Server'] = "smtp.google.com"
    headers['Auth-User'] = request.headers['Auth-User']
    headers['Auth-Pass'] = request.headers['Auth-Pass']
    app.logger.debug("response headers: %s" % (headers))
    return "", 200, headers
    

# end routes
################################################################################

if __name__ == "__main__":
    arg_parser = ArgumentParser(description="Apptive resource bundle configuration builder.")
    arg_parser.add_argument("action", choices=('start', 'test'), help="action to be performed")
    args = arg_parser.parse_args()

    if args.action == "start":
        logging.basicConfig(level=logging.DEBUG)
        app.run(debug=True)
    elif args.action == "test":
        import sys
        import unittest
        import uuid
        from StringIO import StringIO
        uid = lambda: str(uuid.uuid4())
        # unit test uses args too.... so remove ours
        sys.argv.pop()
        class TestFixture(unittest.TestCase):
            def setUp(self):
                app.config['TESTING'] = True
                self.app = app.test_client()

        
        unittest.main()
        print("running tests")
