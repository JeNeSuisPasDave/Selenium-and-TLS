#! /bin/bash
#

# Acquire arguments
#
if [ -z "$1" ]; then
  echo "Please supply the FQDN"
  echo "No action taken."
  exit 2
fi
FQDN_=$1

# Initialization
#
SSLEAY_CONFIG="-config ./ca_2017_openssl.cnf"
ROOTCA_YEAR="2017"
CERT_SUBJ="/C=US/ST=TX/L=Ocean\ City/O=Testing\ Purposes/OU=HQ"
CERT_SUBJ="${CERT_SUBJ}/CN=${FQDN_}/emailAddress=none@none.org"

# Identify Root CA directories
#
ROOTCA_DIR="root_ca_${ROOTCA_YEAR}"
ROOTCA_CERTS_DIR="${ROOTCA_DIR}/certs"
ROOTCA_CRL_DIR="${ROOTCA_DIR}/crl"
ROOTCA_NEWCERTS_DIR="${ROOTCA_DIR}/newcerts"
ROOTCA_PRIVATE_DIR="${ROOTCA_DIR}/private"
ROOTCA_PASS="file:.ca_${ROOTCA_YEAR}_passphrase"

# Identify Cert directories
#
CERT_DIR="certs/${FQDN_}"
CERT_PRIVATE_DIR="${CERT_DIR}/private"

# Create the cert
#
mkdir -p "${CERT_DIR}"
mkdir "${CERT_PRIVATE_DIR}"
chmod 700 "${CERT_PRIVATE_DIR}"
CERT_SUBJ="/C=US/ST=TX/L=Houston/O=Testing\ Purposes/OU=HQ"
CERT_SUBJ="${CERT_SUBJ}/CN=${FQDN_}/emailAddress=none@none.org"

openssl req $SSLEAY_CONFIG -new \
  -nodes -keyout "${CERT_PRIVATE_DIR}/certkey.pem" \
  -out "${CERT_DIR}/certreq.pem" \
  -subj "${CERT_SUBJ}"
chmod 600 "${CERT_PRIVATE_DIR}/certkey.pem"

openssl ca $SSLEAY_CONFIG \
  -cert "${ROOTCA_DIR}/rootCAcert.pem" \
  -keyfile "${ROOTCA_PRIVATE_DIR}/rootCAkey.pem" \
  -passin "$ROOTCA_PASS" \
  -policy policy_anything \
  -days 90 \
  -out "${CERT_DIR}/cert.pem" \
  -extensions v3_usr \
  -infiles "${CERT_DIR}/certreq.pem"

# Validate the cert
#
openssl verify -CAfile "${ROOTCA_DIR}/rootCAcert.pem" "${CERT_DIR}/cert.pem"
