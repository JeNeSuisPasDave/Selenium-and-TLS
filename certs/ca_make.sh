#! /bin/bash
#

# Initialization
#
SSLEAY_CONFIG="-config ./ca_2017_openssl.cnf"
ROOTCA_YEAR="2017"
ROOTCA_SUBJ="/C=US/ST=TX/L=Ocean\ City/O=World\ Greetings\ Company/OU=HQ"
ROOTCA_SUBJ="${ROOTCA_SUBJ}/CN=World\ Greetings\ CA\ ${ROOTCA_YEAR}"

# Identify Root CA directories
#
ROOTCA_DIR="root_ca_${ROOTCA_YEAR}"
ROOTCA_CERTS_DIR="${ROOTCA_DIR}/certs"
ROOTCA_CRL_DIR="${ROOTCA_DIR}/crl"
ROOTCA_NEWCERTS_DIR="${ROOTCA_DIR}/newcerts"
ROOTCA_PRIVATE_DIR="${ROOTCA_DIR}/private"

# Create the Root CA
#
mkdir "${ROOTCA_DIR}"
mkdir "${ROOTCA_CERTS_DIR}"
mkdir "${ROOTCA_CRL_DIR}"
mkdir "${ROOTCA_NEWCERTS_DIR}"
mkdir "${ROOTCA_PRIVATE_DIR}"
chmod 700 "${ROOTCA_PRIVATE_DIR}"
touch "${ROOTCA_DIR}/index.txt"
ROOTCA_PASS="file:.ca_${ROOTCA_YEAR}_passphrase"
openssl req $SSLEAY_CONFIG -new \
  -keyout "${ROOTCA_PRIVATE_DIR}/rootCAkey.pem" \
  -out "${ROOTCA_DIR}/rootCAreq.pem" \
  -subj "${ROOTCA_SUBJ}" \
  -passout "${ROOTCA_PASS}"
chmod 600 "${ROOTCA_PRIVATE_DIR}/rootCAkey.pem"
openssl ca $SSLEAY_CONFIG -create_serial \
  -out "${ROOTCA_DIR}/rootCAcert.pem" \
  -outdir "${ROOTCA_DIR}" \
  -days 1095 -batch \
  -keyfile "${ROOTCA_PRIVATE_DIR}/rootCAkey.pem" \
  -passin "$ROOTCA_PASS" \
  -selfsign -extensions v3_ca \
  -infiles "${ROOTCA_DIR}/rootCAreq.pem"
