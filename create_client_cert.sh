#!/bin/sh
# author: Shivaram.Mysore@gmail.com
# (C) 2017 Shivaram Mysore.  All Rights Reserved

CN_CLIENT=switch.example.com
#CN_CLIENT=client.gnmi.example.com

SUBJECT_CLIENT_CERT="/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=Example Network Infrastructure Services/CN=$CN_CLIENT"

#### DO NOT MODIFY BELOW THIS ##########

CLIENT_CERT_CN=$CN_CLIENT

INTERMEDIATE_CA_DIR=intermediate_ca

CLIENT_CERTS_DIR=certificates/client

echo "For client certificates, Common Name (CN) can be any unique identifier (eg, an e-mail address)"
mkdir -p $CLIENT_CERTS_DIR
mkdir -p $CLIENT_CERTS_DIR/certs $CLIENT_CERTS_DIR/crl $CLIENT_CERTS_DIR/csr $CLIENT_CERTS_DIR/newcerts $CLIENT_CERTS_DIR/private $CLIENT_CERTS_DIR/pkcs12
echo ">> Creating Private key ..."
openssl genrsa -aes256 -passout file:client_cert_passphrase.txt -out $CLIENT_CERTS_DIR/private/$CLIENT_CERT_CN.key.pem 4096
chmod 0400 $CLIENT_CERTS_DIR/private/$CLIENT_CERT_CN.key.pem
echo ">> Creating Client CSR ..."
openssl req -config intermediate_ca_openssl.cnf \
 -passin file:client_cert_passphrase.txt \
 -key $CLIENT_CERTS_DIR/private/$CLIENT_CERT_CN.key.pem \
 -new -sha256 \
 -subj "$SUBJECT_CLIENT_CERT" \
 -out $CLIENT_CERTS_DIR/csr/$CLIENT_CERT_CN.csr.pem
echo ">> Verify Client CSR ..."
openssl req -in $CLIENT_CERTS_DIR/csr/$CLIENT_CERT_CN.csr.pem -noout -text
echo ">> Creating Client Certificate ..."
openssl ca -batch -config intermediate_ca_openssl.cnf -extensions usr_cert \
 -passin file:intermediate_ca_passphrase.txt \
 -days 375 -notext -md sha256 \
 -in $CLIENT_CERTS_DIR/csr/$CLIENT_CERT_CN.csr.pem \
 -out $CLIENT_CERTS_DIR/certs/$CLIENT_CERT_CN.cert.pem
chmod 0444 $CLIENT_CERTS_DIR/certs/$CLIENT_CERT_CN.cert.pem
echo ">> Verify Server Certificate against Certificate Chain ..."
openssl verify -CAfile $INTERMEDIATE_CA_DIR/certs/ca-chain.cert.pem $CLIENT_CERTS_DIR/certs/$CLIENT_CERT_CN.cert.pem
echo ">> Create PKCS12 (.p12 - same as .pfx) for $CLIENT_CERT_CN ..."
openssl pkcs12 -export \
 -passin file:client_cert_passphrase.txt \
 -passout file:client_p12_passphrase.txt \
 -name "$CLIENT_CERT_CN Client Certificate" \
 -out $CLIENT_CERTS_DIR/pkcs12/$CLIENT_CERT_CN.p12 \
 -inkey $CLIENT_CERTS_DIR/private/$CLIENT_CERT_CN.key.pem \
 -in $CLIENT_CERTS_DIR/certs/$CLIENT_CERT_CN.cert.pem \
 -certfile $INTERMEDIATE_CA_DIR/certs/ca-chain.cert.pem
echo ">> Verifiy PKCS12 (.p12 - same as .pfx) for $CLIENT_CERT_CN ..."
openssl pkcs12 -info \
 -passin file:client_p12_passphrase.txt \
 -passout file:client_cert_passphrase.txt \
 -in $CLIENT_CERTS_DIR/pkcs12/$CLIENT_CERT_CN.p12
