#!/bin/sh
# @author: smysore@servicefractal.com
## OVS requires that Private Keys not be password protected.  So, we have
## to store them as PEM files without password protection.
## P12 files are delivered to clients are always password protected.  Hence,
## we have to open the P12 keystore and extract the keys and certs to make it
## available to ovs so that we can use ovs-vsctl set-ssl command.

echo "Usage: $0 p12 file name with no file extension"

echo "Checking $1.p12 file ..."
openssl pkcs12 -passin file:client_p12_passphrase.txt -passout file:client_cert_passphrase.txt -info -in $1.p12

echo "Extracting Certificates from $1.p12 ..."
openssl pkcs12 -passin file:client_p12_passphrase.txt -nokeys -in $1.p12 -out $1-cert.pem -nodes
echo "Extracting private keys from $1.p12 ..."
openssl pkcs12 -passin file:client_p12_passphrase.txt -nocerts -in $1.p12 -out $1-key.pem -nodes
echo "Remove passphrase from Private key ..."
openssl rsa -passin file:client_p12_passphrase.txt -in $1-key.pem -out $1-key_nopass.pem
