# About these container images

The `images` directory contains all the Dockerfiles, scripts, and supporting files need to build the container images used for the Selenium nodes and the web site application and test node.

## Testing image

The web site is a Flask application and the source tree for the website also contains the automated unit tests. The `images/flask-helloworld-test` directory contains the files used to build the container image for the application and tests. _It does not add the application and test source code to any image; the test scripts make the source code available to the web site container by mounting a data volume container that does contain that source code._

The sequence for building up the final application web site and testing image is:

1. alpine-3.4
2. python-3.5.2
3. flask-0.11.1
4. flask-helloworld
5. flask-helloworld-tls

The last image, built from `flask-helloworld-tls`, requires that you have created a root CA cert. The `build.sh` script expects to find that cert in a specific location with a specific name ... you'll need to adjust the script to reference the cert you've generated.

## Chrome browser image

The Selenium nodes are essentially duplicates of the Dockerfiles provided by the Selenium project, with a minor tweak for the nodes that support TLS connections.

The sequence for building up the final Chrome Selenium image is:

1. ubuntu-16.04
2. selenium-base
3. selenium-nodebase
4. selenium-nodechrome
5. selenium-standalonechrome
6. selenium-standalonechrome-tls _(only for the `helloworld-tls` example)_

## Firefox browser image

The sequence for building up the final Firefox Selenium image is:

1. ubuntu-16.04
2. selenium-base
3. selenium-nodebase
4. selenium-nodefirefox
5. selenium-standalonefirefox
6. selenium-standalonefirefox-tls _(only for the `helloworld-tls` example)_

The last image, built from `flask-helloworld-tls`, requires that you have created a root CA cert. The `build.sh` script expects to find that cert in a specific location with a specific name ... you'll need to adjust the script to reference the cert you've generated.

--

_Copyright 2017 David Hein_

_Licensed under the MIT License. If the LICENSE file is missing, you can find the MIT license terms here: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)._
