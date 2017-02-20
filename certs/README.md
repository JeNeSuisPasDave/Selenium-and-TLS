# Certificate generation

To make the `helloworld-tls` example work you will need:

* a root CA certificate, in PEM format
* the private key of the root CA certificate
* a server certificate for the domain `tester.experiment.dev`

You'll also need OpenSSL installed. I used version 1.0.2k, circa Jan 2017, when testing the examples.

>Note: You can do all this in the `certs` directory of this project, but when doing this in a real workflow you would be storing all these scripts, files, and secrets somewhere else, probably on a different machine. In a real workflow you'd probably have a certificate server that would provide the certificates on demand, through an API or some similar automation mechanism.

The two major activities here are:

* [Generating the Root CA certificate](#generating-the-root-ca-certificate)
* [Generate the server's domain validation certificate](#generating-the-servers-domain-validation-certificate)

## Generating the Root CA certificate

The process of using OpenSSL to generate a _root CA_ certificate for use on internal, non-public, endpoints is described my [TIL][TIL] article, "[Create a CA cert on local machine][rootCATIL]". The sub-sections below are enough to get you through the example, but you can get a clearer understanding of the process from that TIL article.

[TIL]: https://github.com/JeNeSuisPasDave/til/blob/master/README.md
[rootCATIL]: https://github.com/JeNeSuisPasDave/til/blob/master/tls/create-local-ca-cert.md

### Update the config file

Edit the `ca_2017_openssl.cnf` file. If the current year isn't 2017, then change the file name as well. You'll probably want to change these lines (listed in order, but they are not continguous):

* dir = ./root_ca_2017        # Where everything is kept
* countryName_default = US
* stateOrProvinceName_default = TX
* 0.organizationName_default = World Greetings Company
* dir = ./root_ca_2017        # TSA root directory

### Update the CA passphrase file

`chmod 600` the `.ca_2017_passphrase` file, set the passphrase, and then make it read-only again with `chmod 400`.

### Update the ca_make script

Edt the `ca_make.sh` script. Change the lines in the initialization section as you desire, and to match the config file name and the current year.

```bash
SSLEAY_CONFIG="-config ./ca_2017_openssl.cnf"
ROOTCA_YEAR="2017"
ROOTCA_SUBJ="/C=US/ST=TX/L=Ocean\ City/O=World\ Greetings\ Company/OU=HQ"
ROOTCA_SUBJ="${ROOTCA_SUBJ}/CN=World\ Greetings\ CA\ ${ROOTCA_YEAR}"
```

### Run the ca_make script

`cd` to the `certs` directory and run the `ca_make.sh` script.

The important files resulting from this are:

* Private key: `./root_ca_2017/private/rootCAkey.pem`
* *CA Certificate: `./root_ca_2017/rootCAcert.pem`

Obviously the names of the subdirectory may be different if you change the files in the steps above.

## Generate the server's domain validation certificate

The process of using OpenSSL to generate a _domain validation_ certificate for use on internal, non-public, endpoints is described my [TIL][TIL] article, [Create server certificate (using local CA)][dvCertTIL]". The sub-sections below are enough to get you through the example, but you can get a clearer understanding of the process from that TIL article.

[dvCertTIL]: https://github.com/JeNeSuisPasDave/til/blob/master/tls/create-server-cert-using-local-ca-cert.md

Note: the test server's [FQDN][fqdn] is `tester.experiment.dev`.

[fqdn]: https://en.wikipedia.org/wiki/Fully_qualified_domain_name

### Update the cert_make script

Edit the `cert_make.sh` script. Change the lines in the initialization section as you desire, and to match the config file name and the current year.

```bash
SSLEAY_CONFIG="-config ./ca_2017_openssl.cnf"
ROOTCA_YEAR="2017"
CERT_SUBJ="/C=US/ST=TX/L=Ocean\ City/O=Testing\ Purposes/OU=HQ"
CERT_SUBJ="${CERT_SUBJ}/CN=${FQDN_}/emailAddress=none@none.org"
```
### Run the cert_make script

`cd` to the `certs` directory and run the `cert_make.sh` script, passing in the FQDN of the test server, as follows:

```bash
./cert_make.sh tester.experiment.dev
```

Answer `y` to both prompts.

The important files resulting from this are:

* Private key: `./certs/tester.experiment.dev/private/certkey.pem`
* Server certificate: `./certs/tester.experiment.dev/cert.pem`

--

_Copyright 2017 David Hein_

_Licensed under the MIT License. If the LICENSE file is missing, you can find the MIT license terms here: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)._
