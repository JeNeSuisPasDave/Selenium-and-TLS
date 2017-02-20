#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/selenium-standalonechrome-3.0.1-ferrium-tls:latest \
    --tag datihein/selenium-standalonechrome-3.0.1-ferrium-tls:1.0.0 \
    .
}

CA_CERT_TGT_DIR_="delme/CA-certs"
mkdir -p "${CA_CERT_TGT_DIR_}"
CA_CERT_SRC_="${HOME}/.CA/root_ca_2016/rootCAcert.pem"
CA_CERT_TGT_FILE_="root-ca-2016.crt"
openssl x509 -outform pem \
  -in "${CA_CERT_SRC_}" \
  -out "${CA_CERT_TGT_DIR_}/${CA_CERT_TGT_FILE_}"

do_it
rc_=$?

rm -r delme
exit $rc_
