# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

from flask import Flask, render_template
from config import config

def create_app(config_name):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)

    # attach routes and custom error pages here
    #
    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app
