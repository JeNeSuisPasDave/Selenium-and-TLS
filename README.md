# Selenium and TLS

This repository demonstrates the use of Selenium nodes to test a web site (or web app) using the Chrome and Firefox browsers. The main purpose is to demonstrate a good way of testing a website that presents HTTPS endpoints.

As of this writing, the Selenium documentation and most examples assume an insecure HTTP connection will be made. There is very little guidance on testing connections made using TLS (that is, HTTPS connections). The bulk of the guidance, and the bulk of online Q &amp; A on the topic, suggests configuring the browsers to ignore certificate errors.

Given that a production implementation of a web site should be using TLS, and that the use of an HTTP/2 server and the use of CSP and HSTS headers are emerging best practices, it seems important that the automated tests of the web site use TLS connections. Issues related to HTTPS could be uncovered by automated testing, issues that might go undiscovered if HTTP was used in the test environment or certificate errors were routinely ignored in the test environment.

Although these examples use the internal Flask web server (which is OK for development but not appropriate for a robust production environment), the demonstrated method for using valid certificates in Selenium driven testing can be transferred easily to a test environment that uses a robust web server (like Apache or Nginx).

## Examples

These examples have been tested on an OS X 10.11.6 system. The Docker host system is a VirtualBox VM created with Docker Machine 0.8.2; the Docker host is running Docker 1.12.3.

The examples will probably work just fine on a Linux system running Docker 1.12.3 or later, and using a Bash command shell. Windows users can also use Docker Machine, but may have to port scripts to PowerShell or use Bash for Windows. The examples have not been tested with Docker for Mac or Docker for Windows.

The `helloworld` example demonstrates how to use Docker Compose and Selenium to perform automated unit testing of a single-page website with the Chrome and Safari browsers.

The `helloworld-tls` example uses the same mechanism, but this time using HTTPS connections. This example shows how the Chrome client node can be configured to validate the server certificate, and how the Firefox client node can be configured to validate the server certificate. Demonstrating tests from both browsers is important; Chrome uses the system's trusted certificate store and Firefox uses a private trusted certificate store.

The web site application uses Flask 0.11.1, Python 3.5, and Alpine 3.4.

Docker Compose is used to start three containers and execute the tests; those containers and their roles are:

* `tester`: the Flask application and tests
* `crdriver`: the standalone Selenium Chrome node used by the tests
* `ffdriver`: the standalone Selenium Firefox node used by the tests

**Important:** Before running the examples you will need to build up some container images.

## Container images

The `images` directory contains all the Dockerfiles, scripts, and supporting files need to build the container images used for the Selenium nodes and the web site application and test node.

For details on building the necessary container images, see [images/README.md](images/README.md).

## Certificates

To exercise the `helloworld-tls` example, you'll need to create a root CA cert and a domain validation cerficate (a server certificate) signed by that CA cert.

## Credit

The way I've used Flask in these examples is very much influenced by my recent experience working through the [O'Reilly book "Flask Web Development" (circa 2014), by Miguel Grinberg](http://shop.oreilly.com/product/0636920031116.do).

--

_Copyright 2017 David Hein_

_Licensed under the MIT License. If the LICENSE file is missing, you can find the MIT license terms here: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)._
