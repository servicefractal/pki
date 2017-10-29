#!/bin/sh
# @author: shivaram.mysore@gmail.com

## Note: certutil and pk12util are provided by libnss3-tools package on Linux.

NSSCERT_DB_DIR=nss_cert_db
NSS_DB_PWD_FILE=nssdb_passphrase.txt
P12_PWD_FILE_CLIENT=client_p12_passphrase.txt
P12_PWD_FILE_SERVER=server_p12_passphrase.txt
P12_DIR=certificates

echo "======================= NOTE =============================="
echo "This script uses NSS tools only for storing keys and certs."
echo "It is not used for creating certificates or keys."
echo "==========================================================="

mkdir -p $NSSCERT_DB_DIR

echo "Create a new certificate database ..."
certutil -N -d $NSSCERT_DB_DIR -f $NSS_DB_PWD_FILE

echo "Add PKCS 12 with Cert and private key to the database"
pk12util -d $NSSCERT_DB_DIR -i $P12_DIR/client/pkcs12/switch.example.com.p12 -w $P12_PWD_FILE_CLIENT
pk12util -d $NSSCERT_DB_DIR -i $P12_DIR/client/pkcs12/client.gnmi.example.com.p12 -w $P12_PWD_FILE_CLIENT
pk12util -d $NSSCERT_DB_DIR -i $P12_DIR/server/pkcs12/controller.example.com.p12 -w $P12_PWD_FILE_SERVER
pk12util -d $NSSCERT_DB_DIR -i $P12_DIR/server/pkcs12/target.gnmi.example.com.p12 -w $P12_PWD_FILE_SERVER

echo "List all certificates in a database ..."
certutil -L -d $NSSCERT_DB_DIR
