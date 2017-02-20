# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

from datetime import datetime
from flask import abort, current_app, flash, make_response
from flask import render_template, request, url_for
from . import main

@main.route('/', methods=['GET'])
def index():
    return render_template(
        'index.html')

@main.route('/shutdown')
def server_shutdown():
    if not current_app.testing:
        abort(404)
    shutdown = request.environ.get('werkzeug.server.shutdown')
    if not shutdown:
        abort(500)
    shutdown()
    return 'Shutting down...'
