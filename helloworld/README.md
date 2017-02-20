# Hello World example, sans TLS

This experiment demonstrates using Selenium client containers to test browser interaction with a Flask website. It's all HTTP; no TLS. The main point is to demonstrate a working site and working automated unit tests, so you can see how the example works before hardening the endpoints to use HTTPS.

The application and test source code is provided by means of a data volume container.

## Quick start

**Precondition:** you have built up all the images (except those needed only for `helloworld-tls` example) as described in the [../images/README.md](../images/README.md) file.

1. Edit `/etc/hosts` and add an entry mapping the IP address of the Docker host machine to the name `tester.experiment.dev`.
2. `cd` to the `helloworld` directory.
3. Establish the source code data volume container by executing `./push-src.sh`
4. Run the example by executing `./test-up-follow-down.sh`.

You should see the successful execution of two tests cases (one using Chrome and one using Firefox). The output will be something like this:

```nohighlight
[master]~/Documents/xmp/Selenium-and-TLS/helloworld$
./test-up-follow-down.sh
Creating network "helloworld_app-test-net" with driver "bridge"
Creating helloworld_crdriver_1
Creating helloworld_ffdriver_1
Creating helloworld_tester_1
test_admin_home_page (test_selenium_cr.ChromiumSeleniumTestCase) ... ok
test_admin_home_page (test_selenium_ff.FirefoxSeleniumTestCase) ... ok

----------------------------------------------------------------------
Ran 2 tests in 5.479s

OK
Stopping helloworld_ffdriver_1 ... done
Stopping helloworld_crdriver_1 ... done
Removing helloworld_tester_1 ... done
Removing helloworld_ffdriver_1 ... done
Removing helloworld_crdriver_1 ... done
Removing network helloworld_app-test-net
```

**Note:** If you want to see what the website looks like, you can execute `run-server.sh` and then point your browser to [http://tester.experiment.dev](http://tester.experiment.dev).

## Scripts

* `push-src.sh`: Create or recreate the source data volume container.
* `run-server.sh`: Just runs the website in a container with port 80 exposed. You can point a browser at this and see that the site is operating. This does not run any automated tests.
* `test-down.sh`: Tears down the containers and networks created by `test-up.sh`. You need to run this; `test-up.sh` does not automatically clean up after itself.
* `test-up.sh`: Uses Docker Compose to launch Chrome and Firefox Selenium client nodes and the website test node. The test node executes tests that use the Selenium clients to interact with a web endpoint stood up by the test harness. _Use `docker logs` to see the test log and test results from the test container._ Run `push-src.sh` or `update-src.sh` before launching `test-up.sh` to be sure you test the latest source code.
* `test-up-follow-down.sh`: Uses Docker Compose to launch Chrome and Firefox Selenium client nodes and the website test node, displays the test execution log to the console, and then teards down the containers and networks instantiated by Docker Compose. The test node executes tests that use the Selenium clients to interact with a web endpoint stood up by the test harness. Run `push-src.sh` or `update-src.sh` before launching `test-up.sh` to be sure you test the latest source code.
* `update-src.sh`: Update the source data volume container to match what is in the `src` directory. Do this if you change the code.

## Image naming

All the image names are prefixed with `datihein/`. That's what I use for namespacing all my private experimental images, those I use for experiments or testing and never intend to push into a repositoriy. If you want to use a different prefix, go ahead ... but you'll need to do a global replace because there are many scripts and Dockerfiles that specify image names with that prefix.

## Credit

The way I've used Flask in this example is very much influenced by my recent experience working through the [O'Reilly book "Flask Web Development" (circa 2014), by Miguel Grinberg](http://shop.oreilly.com/product/0636920031116.do).

--

_Copyright 2017 David Hein_

_Licensed under the MIT License. If the LICENSE file is missing, you can find the MIT license terms here: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)._
