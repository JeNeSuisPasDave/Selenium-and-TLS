# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

from flask import Blueprint

main = Blueprint('main', __name__)

from . import views, errors
