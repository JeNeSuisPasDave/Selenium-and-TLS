# Utility scripts

These are scripts that provide functions and utilities common to both examples. They are called from scripts found in the example directories.

* `capture-dv-container.sh`: If you change code in the tester container, you can copy those changes back to your Docker Machine desktop using this script.
* `create-dv-container.sh`: Creates or updates a data volume container.
* `dv-sync.src`: Bash functions shared by many of these scripts.
* `update-cert-dv.sh`: Update the server certificate data volume container with the server certificate.
* `update-root-ca-dv.sh:` Update a root CA data volume container with a root CA certificate. Not actually used by either `helloworld` or `helloworld-tls` examples&mdash;I think :-).

--

_Copyright 2017 David Hein_

_Licensed under the MIT License. If the LICENSE file is missing, you can find the MIT license terms here: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)._
