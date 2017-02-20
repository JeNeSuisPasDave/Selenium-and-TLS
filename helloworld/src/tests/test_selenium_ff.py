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

    def html2text(self, strText):
        str1 = strText
        int2 = str1.lower().find("<body")
        if int2>0:
           str1 = str1[int2:]
        int2 = str1.lower().find("</body>")
        if int2>0:
           str1 = str1[:int2]
        list1 = ['<br>',  '<tr',  '<td', '</p>', 'span>', 'li>', '</h', 'div>' ]
        list2 = [chr(13), chr(13), chr(9), chr(13), chr(13),  chr(13), chr(13), chr(13)]
        bolFlag1 = True
        bolFlag2 = True
        strReturn = ""
        for int1 in range(len(str1)):
          str2 = str1[int1]
          for int2 in range(len(list1)):
            if str1[int1:int1+len(list1[int2])].lower() == list1[int2]:
               strReturn = strReturn + list2[int2]
          if str1[int1:int1+7].lower() == '<script' or str1[int1:int1+9].lower() == '<noscript':
             bolFlag1 = False
          if str1[int1:int1+6].lower() == '<style':
             bolFlag1 = False
          if str1[int1:int1+7].lower() == '</style':
             bolFlag1 = True
          if str1[int1:int1+9].lower() == '</script>' or str1[int1:int1+11].lower() == '</noscript>':
             bolFlag1 = True
          if str2 == '<':
             bolFlag2 = False
          if bolFlag1 and bolFlag2 and (ord(str2) != 10) :
            strReturn = strReturn + str2
          if str2 == '>':
             bolFlag2 = True
          if bolFlag1 and bolFlag2:
            strReturn = strReturn.replace(chr(32)+chr(13), chr(13))
            strReturn = strReturn.replace(chr(9)+chr(13), chr(13))
            strReturn = strReturn.replace(chr(13)+chr(32), chr(13))
            strReturn = strReturn.replace(chr(13)+chr(9), chr(13))
            strReturn = strReturn.replace(chr(13)+chr(13), chr(13))
        strReturn = strReturn.replace(chr(13), '\n')
        return strReturn

    def test_admin_home_page(self):
        # navigate to home page
        # self.client.get('http://packages.ubuntu.com/yakkety/inetutils-ping')
        # import time
        # time.sleep(3600)
        self.client.get('http://tester.experiment.dev/')
        # print(
        #     "\nSOURCE<<<<<<<<<<<<<\n{0}\nSOURCE>>>>>>>>>>>>\n".format(
        #         self.html2text(self.client.page_source)))
        self.assertTrue(re.search(
            'Hello,\s+Stranger!', self.client.page_source))
