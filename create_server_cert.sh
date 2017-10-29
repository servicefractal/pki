#!/bin/sh
# author: Shivaram.Mysore@gmail.com
# (C) 2017 Shivaram Mysore.  All Rights Reserved

#CN_SERVER=controller.example.com
CN_SERVER=target.gnmi.example.com

SUBJECT_SERVER_CERT="/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=Example SaaS Services/CN=$CN_SERVER"

#### DO NOT MODIFY BELOW THIS ##########

SERVER_CERT_CN=$CN_SERVER

INTERMEDIATE_CA_DIR=intermediate_ca

SERVER_CERTS_DIR=certificates/server

echo "For server certificates, Common Name (CN) must be a fully qualified domain name (eg, www.example.com)"
echo $SUBJECT_SERVER_CERT
mkdir -p $SERVER_CERTS_DIR/certs $SERVER_CERTS_DIR/crl $SERVER_CERTS_DIR/csr $SERVER_CERTS_DIR/newcerts $SERVER_CERTS_DIR/private $SERVER_CERTS_DIR/pkcs12
echo ">> Creating Private key ..."
openssl genrsa -aes256 -passout file:server_cert_passphrase.txt -out $SERVER_CERTS_DIR/private/$SERVER_CERT_CN.key.pem 4096
chmod 0400 $SERVER_CERTS_DIR/private/$SERVER_CERT_CN.key.pem
echo ">> Creating Server CSR ..."
openssl req -config intermediate_ca_openssl.cnf \
 -passin file:server_cert_passphrase.txt \
 -key $SERVER_CERTS_DIR/private/$SERVER_CERT_CN.key.pem \
 -new -sha256 \
 -subj "$SUBJECT_SERVER_CERT" \
 -out $SERVER_CERTS_DIR/csr/$SERVER_CERT_CN.csr.pem
echo ">> Verify Server CSR ..."
openssl req -in $SERVER_CERTS_DIR/csr/$SERVER_CERT_CN.csr.pem -noout -text
echo ">> Creating Server Certificate ..."
openssl ca -batch -config intermediate_ca_openssl.cnf -extensions server_cert \
 -passin file:intermediate_ca_passphrase.txt \
 -days 375 -notext -md sha256 \
 -in $SERVER_CERTS_DIR/csr/$SERVER_CERT_CN.csr.pem \
 -out $SERVER_CERTS_DIR/certs/$SERVER_CERT_CN.cert.pem
chmod 0444 $SERVER_CERTS_DIR/certs/$SERVER_CERT_CN.cert.pem
echo ">> Verify Server Certificate against Certificate Chain ..."
openssl verify -CAfile $INTERMEDIATE_CA_DIR/certs/ca-chain.cert.pem $SERVER_CERTS_DIR/certs/$SERVER_CERT_CN.cert.pem
echo ">> Create PKCS12 (.p12 - same as .pfx) for $SERVER_CERT_CN ..."
openssl pkcs12 -export \
 -passin file:server_cert_passphrase.txt \
 -passout file:server_p12_passphrase.txt \
 -name "$SERVER_CERT_CN Server Certificate" \
 -out $SERVER_CERTS_DIR/pkcs12/$SERVER_CERT_CN.p12 \
 -inkey $SERVER_CERTS_DIR/private/$SERVER_CERT_CN.key.pem \
 -in $SERVER_CERTS_DIR/certs/$SERVER_CERT_CN.cert.pem \
 -certfile $INTERMEDIATE_CA_DIR/certs/ca-chain.cert.pem
echo ">> Verifiy PKCS12 (.p12 - same as .pfx) for $SERVER_CERT_CN ..."
openssl pkcs12 -info \
 -passin file:server_p12_passphrase.txt \
 -passout file:server_cert_passphrase.txt \
 -in $SERVER_CERTS_DIR/pkcs12/$SERVER_CERT_CN.p12
