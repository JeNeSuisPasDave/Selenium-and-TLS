#!/usr/bin/env python

# Copyright 2017 David Hein
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os

from app import create_app
from flask_script import Manager, Shell, Server
import ssl

context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
context.load_cert_chain(
    '/mnt/experiment/tls/cert.pem', keyfile='/mnt/experiment/tls/certkey.pem')
app = create_app(os.getenv('HELLOWORLD_CONFIG') or 'default')
manager = Manager(app)

def make_shell_context():
    return dict(app=app)

manager.add_command("runserver", Server(ssl_context=context))
manager.add_command("shell", Shell(make_context=make_shell_context))

@manager.command
def test(coverage=False):
    import unittest
    tests = unittest.TestLoader().discover('tests')
    unittest.TextTestRunner(verbosity=2).run(tests)

if __name__ == '__main__':
    manager.run()
