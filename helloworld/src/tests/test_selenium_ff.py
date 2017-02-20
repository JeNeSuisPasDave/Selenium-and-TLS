# Copyright 2017 David Hein
#
# Licensed under the MIT License. If the LICENSE file is missing, you
# can find the MIT license terms here: https://opensource.org/licenses/MIT

import re
import threading
import time
import unittest
from selenium import webdriver
from app import create_app
import sys, traceback

class FirefoxSeleniumTestCase(unittest.TestCase):
    client = None

    @classmethod
    def setUpClass(cls):
        # start Firefox Selenium node
        try:
            url = 'http://ffdriver:4444/wd/hub'
            capabilities = webdriver.DesiredCapabilities.FIREFOX.copy()
            cls.client = webdriver.Remote(
                command_executor=url,
                desired_capabilities=capabilities)
        except:
            etype, evalue, etraceback = sys.exc_info()
            print("webdriver.Remote() threw {0}".format(etype))
            print("{0}".format(evalue))
            traceback.print_tb(etraceback)
            pass

        # skip these tests if the browser could not be started
        if cls.client:
            # create the application
            cls.app = create_app('testing')
            cls.app_context = cls.app.app_context()
            cls.app_context.push()

            # suppress logging to keep unittest output clean
            import logging
            logger = logging.getLogger('werkzeug')
            logger.setLevel("ERROR")

            # start the Flask server in a thread
            # print("\n*** STARTING SERVER ***\n")
            threading.Thread(
                target=cls.app.run,
                kwargs={'host':'0.0.0.0', 'port':'80'}).start()

            # give the server a second to ensure it is up
            time.sleep(1)

    @classmethod
    def tearDownClass(cls):
        if cls.client:
            # stop the flask server and the browser
            cls.client.get('http://tester.experiment.dev/shutdown')
            cls.client.close()

            # remove application context
            cls.app_context.pop()

    def setUp(self):
        if not self.client:
            self.skipTest('Web browser not available')

    def tearDown(self):
        pass

    def test_admin_home_page(self):
        # navigate to home page
        #
        self.client.get('http://tester.experiment.dev/')

        # Does the page contain the text we expect?
        #
        self.assertTrue(re.search(
            'Hello,\s+Stranger!', self.client.page_source))
