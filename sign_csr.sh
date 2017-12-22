#!/bin/sh
# author: Shivaram.Mysore@gmail.com
# (C) 2017 Shivaram Mysore.  All Rights Reserved

# For embedded systems such as a Network Switch, key pair is generated on the
# machine and a PEM encoded Certificate Signing Request (CSR) is generated for
# a subsequent sign by a Certificate Authority (CA).  This script enables one to
# sign such a PEM encoded CSR file with the Intermediate CA.

if [[ -z $1 ]]; then
  echo "Usage: $0 <filename for PEM encoded csr to be signed without file extension>"
  echo "example (full filename test.csr.pem): $0 test.csr"
  echo ""
  exit 1;
fi

CSR_TO_SIGN=$1
GENERATED_CERT_4CSR=$1.cert

INTERMEDIATE_CA_DIR=intermediate_ca
CLIENT_CERTS_DIR=certificates/client
mkdir -p $CLIENT_CERTS_DIR
mkdir -p $CLIENT_CERTS_DIR/certs

echo ">> Verify received CSR ..."
openssl req -in $CSR_TO_SIGN.pem -noout -text

echo ">> Creating Client Certificate for provided CSR ... $CSR_TO_SIGN.pem"
openssl ca -batch -config intermediate_ca_openssl.cnf -extensions usr_cert \
 -passin file:intermediate_ca_passphrase.txt \
 -days 375 -notext -md sha256 \
 -in $CSR_TO_SIGN.pem \
 -out $CLIENT_CERTS_DIR/certs/$GENERATED_CERT_4CSR.pem
chmod 0444 $CLIENT_CERTS_DIR/certs/$GENERATED_CERT_4CSR.pem

echo ">> Verify Server Certificate against Certificate Chain ..."
openssl verify -CAfile $INTERMEDIATE_CA_DIR/certs/ca-chain.cert.pem $CLIENT_CERTS_DIR/certs/$GENERATED_CERT_4CSR.pem

echo ""
echo "Certificate for provided CSR is @ $CLIENT_CERTS_DIR/certs/$GENERATED_CERT_4CSR.pem"
