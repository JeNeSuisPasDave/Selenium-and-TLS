#!/usr/bin/env python
#

# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

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
