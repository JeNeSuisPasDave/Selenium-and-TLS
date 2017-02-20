# Hello World TLS example

This experiment demonstrates using Selenium client containers to test browser interaction with a Flask website. It's all HTTPS (TLS, that is).

The application and test source code is provided by means of a data volume container.

## Create the certificates

Follow the guideance in [../certs/README.md](../certs/README.md) to create the root CA certificate and server certificate that will be used in this example.

## Add the root CA certificate to the system trusted store of Selenium images

Chrome, other browsers (except Firefox), and `curl` use the system trusted store as the source of root certificates used to validate the signed certificates presented by HTTPS endpoints. So you need to create Selenium node images that have the test root CAs in the system trusted store.

Create those images by running the `build.sh` script from these directories:

* `images/selenium-standalonechrome-tls`
* `images/selenium-standalonefirefox-tls`

## Create the Firefox certificate database

>Note: Tested with Firefox 50.1.0 on OS X El Capitan (10.11.6).

Firefox doesn't use the system store of trusted certifications, but instead uses a private database of trusted certificates that is part of a specific browser profile. You'll need to create that database file so that the test case can provide it as part of the browser profile used during testing.

Essentially the steps for doing this&mdash;from a desktop system with Firefox installed&mdash;are:

1. Close any instances of Firefox running on the system.
2. Launch Firefox's profile manager and create a clean new profile.
    * Execute `/Applications/Firefox.app/MacOS/firefox -P`, to launch the profile dialog.
    * Click "create profile".
    * Click "continue".
    * Set the profile name (I picked "selenium").
    * Note the directory path where the profile will be stored
    * Click "done"
3. Select the new profile and click "start firefox".
4. Add CA certificate to Firefox.
    * Go to _Preferences_ and select _Advanced_ in the nav bar on the left.
    * Then select _Certificates_ in the nav bar on the top.
    * Click the "View Certificates" button
    * In the resulting dialog, click the "Import" button.
    * Browse to the CA certificate file (e.g., `./certs/root_ca_2017/rootCAcert.pem`) and import it.
    * When prompted, check "Trust this CA to identify websites", and click OK to confirm the change.
    * Click OK again to close the View Certificates dialog.
    * Close Firefox.
4. Launch Firefox's profile manager and set the proper default profile.
    * Execute `/Applications/Firefox.app/MacOS/firefox -P`, to launch the profile dialog.
    * Select your normal profile.
    * Make sure the "Use selected profile without asking at startup" checkbox is checked.
    * Click "Start Firefox".
5. Copy the `cert8.db` file to `helloworld-tls\src\firefox_trusted_certs`
    * Create the directory `firefox_trusted_certs` in `helloworld-tls\src\firefox_trusted_certs`, if it doesn't already exist.
    * From the profile directory of the profile you created and to which you added the root CA certificate (in step 4 above), copy `cert8.db` into `helloworld-tls\src\firefox_trusted_certs`

## Prep for Firefox Selenium client

To get the Selenium Firefox client to accept the server's DV certificate, the trusted root certificate that signed the DV cert must be known to Firefox via the browser profile.

The only way I know to do that is to run Firefox on a desktop OS somewhere, add the trusted CA cert to that profile, and then copy the file `cert8.db` from the profile and into `src\firefox_trusted_certs`.

With a populated `cert8.db` in that location, push the source tree to the data volume container and then run the tests. The Firefox test fixture will create a new Firefox_Profile instance using that `cert8.db` file and use that profile to instantiate the remote Firefox Selenium client.

## Prep for Chrome Selenium client

Chrome uses the system's trusted root certificate store, so you'll need to have added the trusted root certifiate that signed the server's DV certificate in that store.

In this example, that was done when building the docker images used for the Selenium client nodes (specifically via `selenium-standalonechrome-tls`).

## Quick start

**Preconditions:**

* you have built up all the images (including the `*-tls` images) as described in the [../images/README.md](../images/README.md) file.
* you have populated the `helloworld-tls\src\firefox_trusted_certs` directory as described in the section "[Create the Firefox certificate database](#create-the-firefox-certificate-database)".

To run the example:

1. Edit `/etc/hosts` and add an entry mapping the IP address of the Docker host machine to the name `tester.experiment.dev`.
2. `cd` to the `helloworld-tls` directory.
3. Establish the source code data volume container by executing `./push-src.sh`
4. Establish the server certificate data volume container by executing `./update-cert-dv.sh`
5. Run the example by executing `./test-up-follow-down.sh`.

You should see the successful execution of two tests cases (one using Chrome and one using Firefox). The output will be something like this:

```nohighlight
[master]~/Documents/xmp/Selenium-and-TLS/helloworld-tls$
./test-up-follow-down.sh
Creating network "helloworldtls_app-test-net" with driver "bridge"
Creating helloworldtls_crdriver_1
Creating helloworldtls_ffdriver_1
Creating helloworldtls_tester_1
test_admin_home_page (test_selenium_cr.ChromiumSeleniumTestCase) ... ok
test_admin_home_page (test_selenium_ff.FirefoxSeleniumTestCase) ... ok

----------------------------------------------------------------------
Ran 2 tests in 5.617s

OK
Stopping helloworldtls_ffdriver_1 ... done
Stopping helloworldtls_crdriver_1 ... done
Removing helloworldtls_tester_1 ... done
Removing helloworldtls_ffdriver_1 ... done
Removing helloworldtls_crdriver_1 ... done
Removing network helloworldtls_app-test-net
```

**Note:** If you want to see what the website looks like, you can execute `run-server.sh` and then point your browser to [https://tester.experiment.dev](http://tester.experiment.dev). You'll need to launch Firefox using the profile you created above (so that the root CA cert can be used to validate the site certificate); for Chrome, you'll need to add the root CA cert to the system trusted store (e.g., see `selenium-standalonechrome-tls/Dockerfile` for how to update the Ubuntu system trusted store).

## Scripts

* `push-src.sh`: Create or recreate the source data volume container.
* `run-server.sh`: Just runs the website in a container with port 443 exposed. You can point a browser at this and see that the site is operating. This does not run any automated tests.
* `test-down.sh`: Tears down the containers and networks created by `test-up.sh`. You need to run this; `test-up.sh` does not automatically clean up after itself.
* `test-up.sh`: Uses Docker Compose to launch Chrome and Firefox Selenium client nodes and the website test node. The test node executes tests that use the Selenium clients to interact with a web endpoint stood up by the test harness. _Use `docker logs` to see the test log and test results from the test container._ Run `push-src.sh` or `update-src.sh` before launching `test-up.sh` to be sure you test the latest source code.
* `test-up-follow-down.sh`: Uses Docker Compose to launch Chrome and Firefox Selenium client nodes and the website test node, displays the test execution log to the console, and then teards down the containers and networks instantiated by Docker Compose. The test node executes tests that use the Selenium clients to interact with a web endpoint stood up by the test harness. Run `push-src.sh` or `update-src.sh` before launching `test-up.sh` to be sure you test the latest source code.
* `update-cert-dv.sh`: Create or update the server certificate data volume container.
* `update-src.sh`: Update the source data volume container to match what is in the `src` directory. Do this if you change the code.

## Image naming

All the image names are prefixed with `datihein/`. That's what I use for namespacing all my private experimental images, those I use for experiments or testing and never intend to push into a repositoriy. If you want to use a different prefix, go ahead ... but you'll need to do a global replace because there are many scripts and Dockerfiles that specify image names with that prefix.

## Credit

The way I've used Flask in this example is very much influenced by my recent experience working through the [O'Reilly book "Flask Web Development" (circa 2014), by Miguel Grinberg](http://shop.oreilly.com/product/0636920031116.do).

--

_Copyright 2017 David Hein_

_Licensed under the MIT License. If the LICENSE file is missing, you can find the MIT license terms here: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)._
