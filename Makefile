fileinfo := TLS SNI Certificates & PKCS 12 Keystore Makefile
author   := Shivaram Mysore (shivaram.mysore@gmail.com)
copyright := 2017 Shivaram Mysore.  All Rights Reserved. Use is subject to Apache2 LICENSE terms.

## Dependent programs
CAT := cat
CD := cd
CP := cp
CHMOD := chmod
ECHO := echo
GIT := git
MKDIR := mkdir -p
MV := mv
OPENSSL := openssl
RM := rm
TAR := tar
TOUCH := touch
UNZIP := unzip
WGET := wget
ZIP := zip

CA_DIR := ca
INTERMEDIATE_CA_DIR := intermediate_ca
CLIENT_CERTS_DIR := certificates/client
SERVER_CERTS_DIR := certificates/server

SUBJECT_CA := "/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=PKI Network Services/CN=ca.pki.example.com"
SUBJECT_INTERMEDIATE_CA := "/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=PKI Network Services/CN=intermediate.ca.pki.example.com"

#### Change the CN and values of the below 2 lines and run target build_server_cert build_client_cert to get new certs
CN_SERVER := controller.example.com
CN_CLIENT := switch.example.com
#CN_SERVER := target.gnmi.example.com
#CN_CLIENT := client.gnmi.example.com

SUBJECT_SERVER_CERT := "/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=Example SaaS Services/CN=$(CN_SERVER)"
SUBJECT_CLIENT_CERT := "/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=Example Network Infrastructure Services/CN=$(CN_CLIENT)"
SERVER_CERT_CN := $(CN_SERVER)
CLIENT_CERT_CN := $(CN_CLIENT)


.PHONY: all build_pki clean_pki

all: build_pki

build_pki: build_ca build_intermediate_ca build_server_cert build_client_cert

build_ca:
	$(MKDIR) $(CA_DIR)/certs $(CA_DIR)/crl $(CA_DIR)/newcerts $(CA_DIR)/private
	$(CD) $(CA_DIR); $(CHMOD) 0700 private; $(TOUCH) index.txt; $(ECHO) 1000 > serial;
	$(ECHO) ">> Creating CA root key ..."
	$(OPENSSL) genrsa -aes256 -passout file:ca_passphrase.txt -out $(CA_DIR)/private/ca.key.pem 4096
	$(CHMOD) 0400 $(CA_DIR)/private/ca.key.pem
	$(ECHO) ">> Creating CA root Certificate ..."
	$(OPENSSL) req -config ca_openssl.cnf \
      -passin file:ca_passphrase.txt \
      -key $(CA_DIR)/private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
			-subj $(SUBJECT_CA) \
      -out $(CA_DIR)/certs/ca.cert.pem
	$(CHMOD) 0444 $(CA_DIR)/certs/ca.cert.pem
	$(ECHO) ">> Verify CA root Certificate ..."
	$(OPENSSL) x509 -noout -text -in $(CA_DIR)/certs/ca.cert.pem

build_intermediate_ca:
	$(MKDIR) $(INTERMEDIATE_CA_DIR)
	$(MKDIR) $(INTERMEDIATE_CA_DIR)/certs $(INTERMEDIATE_CA_DIR)/crl $(INTERMEDIATE_CA_DIR)/csr $(INTERMEDIATE_CA_DIR)/newcerts $(INTERMEDIATE_CA_DIR)/private
	$(CD) $(INTERMEDIATE_CA_DIR); $(CHMOD) 0700 private; $(TOUCH) index.txt; $(ECHO) 1000 > serial; $(ECHO) 1000 > crlnumber;
	$(ECHO) ">> Creating Intermediate CA key ..."
	$(OPENSSL) genrsa -aes256 -passout file:intermediate_ca_passphrase.txt -out $(INTERMEDIATE_CA_DIR)/private/intermediate_ca.key.pem 4096
	$(CHMOD) 0400 $(INTERMEDIATE_CA_DIR)/private/intermediate_ca.key.pem
	$(ECHO) ">> Creating Intermediate CA CSR ..."
	$(OPENSSL) req -config intermediate_ca_openssl.cnf \
			-passin file:intermediate_ca_passphrase.txt \
			-key $(INTERMEDIATE_CA_DIR)/private/intermediate_ca.key.pem \
			-new -sha256 \
			-subj $(SUBJECT_INTERMEDIATE_CA) \
			-out $(INTERMEDIATE_CA_DIR)/csr/intermediate_ca.csr.pem
	$(ECHO) ">> Verify Intermediate CSR ..."
	$(OPENSSL) req -in $(INTERMEDIATE_CA_DIR)/csr/intermediate_ca.csr.pem -noout -text
	$(ECHO) ">> Creating Intermediate CA Certificate ..."
	$(OPENSSL) ca -batch -config ca_openssl.cnf -extensions v3_intermediate_ca \
			      -passin file:ca_passphrase.txt \
			      -days 3650 -notext -md sha256 \
			      -in $(INTERMEDIATE_CA_DIR)/csr/intermediate_ca.csr.pem \
			      -out $(INTERMEDIATE_CA_DIR)/certs/intermediate_ca.cert.pem
	$(CHMOD) 0444 $(INTERMEDIATE_CA_DIR)/certs/intermediate_ca.cert.pem
	$(ECHO) ">> Verify Intermediate Certificate ..."
	$(OPENSSL) x509 -noout -text -in $(INTERMEDIATE_CA_DIR)/certs/intermediate_ca.cert.pem
	$(ECHO) ">> Verify Intermediate Certificate against Root CA Certificate ..."
	$(OPENSSL) verify -CAfile $(CA_DIR)/certs/ca.cert.pem $(INTERMEDIATE_CA_DIR)/certs/intermediate_ca.cert.pem
	$(ECHO) ">> Creating Certificate Chain ..."
	$(CAT) $(INTERMEDIATE_CA_DIR)/certs/intermediate_ca.cert.pem $(CA_DIR)/certs/ca.cert.pem > $(INTERMEDIATE_CA_DIR)/certs/ca-chain.cert.pem


build_server_cert:
	$(ECHO) "For server certificates, Common Name (CN) must be a fully qualified domain name (eg, www.example.com)"
	$(MKDIR) $(SERVER_CERTS_DIR)
	$(MKDIR) $(SERVER_CERTS_DIR)/certs $(SERVER_CERTS_DIR)/crl $(SERVER_CERTS_DIR)/csr $(SERVER_CERTS_DIR)/newcerts $(SERVER_CERTS_DIR)/private $(SERVER_CERTS_DIR)/pkcs12
	$(ECHO) ">> Creating Private key ..."
	$(OPENSSL) genrsa -aes256 -passout file:server_cert_passphrase.txt -out $(SERVER_CERTS_DIR)/private/$(SERVER_CERT_CN).key.pem 4096
	$(CHMOD) 0400 $(SERVER_CERTS_DIR)/private/$(SERVER_CERT_CN).key.pem
	$(ECHO) ">> Creating Server CSR ..."
	$(OPENSSL) req -config intermediate_ca_openssl.cnf \
			-passin file:server_cert_passphrase.txt \
			-key $(SERVER_CERTS_DIR)/private/$(SERVER_CERT_CN).key.pem \
			-new -sha256 \
			-subj $(SUBJECT_SERVER_CERT) \
			-out $(SERVER_CERTS_DIR)/csr/$(SERVER_CERT_CN).csr.pem
	$(ECHO) ">> Verify Server CSR ..."
	$(OPENSSL) req -in $(SERVER_CERTS_DIR)/csr/$(SERVER_CERT_CN).csr.pem -noout -text
	$(ECHO) ">> Creating Server Certificate ..."
	$(OPENSSL) ca -batch -config intermediate_ca_openssl.cnf -extensions server_cert \
			      -passin file:intermediate_ca_passphrase.txt \
			      -days 375 -notext -md sha256 \
			      -in $(SERVER_CERTS_DIR)/csr/$(SERVER_CERT_CN).csr.pem \
			      -out $(SERVER_CERTS_DIR)/certs/$(SERVER_CERT_CN).cert.pem
	$(CHMOD) 0444 $(SERVER_CERTS_DIR)/certs/$(SERVER_CERT_CN).cert.pem
	$(ECHO) ">> Verify Server Certificate against Certificate Chain ..."
	$(OPENSSL) verify -CAfile $(INTERMEDIATE_CA_DIR)/certs/ca-chain.cert.pem $(SERVER_CERTS_DIR)/certs/$(SERVER_CERT_CN).cert.pem
	$(ECHO) ">> Create PKCS12 (.p12 - same as .pfx) for $(SERVER_CERT_CN) ..."
	$(OPENSSL) pkcs12 -export \
			-passin file:server_cert_passphrase.txt \
			-passout file:server_p12_passphrase.txt \
			-name "$(SERVER_CERT_CN) Server Certificate" \
			-out $(SERVER_CERTS_DIR)/pkcs12/$(SERVER_CERT_CN).p12 \
			-inkey $(SERVER_CERTS_DIR)/private/$(SERVER_CERT_CN).key.pem \
			-in $(SERVER_CERTS_DIR)/certs/$(SERVER_CERT_CN).cert.pem \
			-certfile $(INTERMEDIATE_CA_DIR)/certs/ca-chain.cert.pem
	$(ECHO) ">> Verifiy PKCS12 (.p12 - same as .pfx) for $(SERVER_CERT_CN) ..."
	$(OPENSSL) pkcs12 -info \
			-passin file:server_p12_passphrase.txt \
			-passout file:server_cert_passphrase.txt \
			-in $(SERVER_CERTS_DIR)/pkcs12/$(SERVER_CERT_CN).p12

build_client_cert:
	$(ECHO) "For client certificates, Common Name (CN) can be any unique identifier (eg, an e-mail address)"
	$(MKDIR) $(CLIENT_CERTS_DIR)
	$(MKDIR) $(CLIENT_CERTS_DIR)/certs $(CLIENT_CERTS_DIR)/crl $(CLIENT_CERTS_DIR)/csr $(CLIENT_CERTS_DIR)/newcerts $(CLIENT_CERTS_DIR)/private $(CLIENT_CERTS_DIR)/pkcs12
	$(ECHO) ">> Creating Private key ..."
	$(OPENSSL) genrsa -aes256 -passout file:client_cert_passphrase.txt -out $(CLIENT_CERTS_DIR)/private/$(CLIENT_CERT_CN).key.pem 4096
	$(CHMOD) 0400 $(CLIENT_CERTS_DIR)/private/$(CLIENT_CERT_CN).key.pem
	$(ECHO) ">> Creating Client CSR ..."
	$(OPENSSL) req -config intermediate_ca_openssl.cnf \
			-passin file:client_cert_passphrase.txt \
			-key $(CLIENT_CERTS_DIR)/private/$(CLIENT_CERT_CN).key.pem \
			-new -sha256 \
			-subj $(SUBJECT_CLIENT_CERT) \
			-out $(CLIENT_CERTS_DIR)/csr/$(CLIENT_CERT_CN).csr.pem
	$(ECHO) ">> Verify Client CSR ..."
	$(OPENSSL) req -in $(CLIENT_CERTS_DIR)/csr/$(CLIENT_CERT_CN).csr.pem -noout -text
	$(ECHO) ">> Creating Client Certificate ..."
	$(OPENSSL) ca -batch -config intermediate_ca_openssl.cnf -extensions usr_cert \
			      -passin file:intermediate_ca_passphrase.txt \
			      -days 375 -notext -md sha256 \
			      -in $(CLIENT_CERTS_DIR)/csr/$(CLIENT_CERT_CN).csr.pem \
			      -out $(CLIENT_CERTS_DIR)/certs/$(CLIENT_CERT_CN).cert.pem
	$(CHMOD) 0444 $(CLIENT_CERTS_DIR)/certs/$(CLIENT_CERT_CN).cert.pem
	$(ECHO) ">> Verify Server Certificate against Certificate Chain ..."
	$(OPENSSL) verify -CAfile $(INTERMEDIATE_CA_DIR)/certs/ca-chain.cert.pem $(CLIENT_CERTS_DIR)/certs/$(CLIENT_CERT_CN).cert.pem
	$(ECHO) ">> Create PKCS12 (.p12 - same as .pfx) for $(CLIENT_CERT_CN) ..."
	$(OPENSSL) pkcs12 -export \
			-passin file:client_cert_passphrase.txt \
			-passout file:client_p12_passphrase.txt \
			-name "$(CLIENT_CERT_CN) Client Certificate" \
			-out $(CLIENT_CERTS_DIR)/pkcs12/$(CLIENT_CERT_CN).p12 \
			-inkey $(CLIENT_CERTS_DIR)/private/$(CLIENT_CERT_CN).key.pem \
			-in $(CLIENT_CERTS_DIR)/certs/$(CLIENT_CERT_CN).cert.pem \
			-certfile $(INTERMEDIATE_CA_DIR)/certs/ca-chain.cert.pem
	$(ECHO) ">> Verifiy PKCS12 (.p12 - same as .pfx) for $(CLIENT_CERT_CN) ..."
	$(OPENSSL) pkcs12 -info \
			-passin file:client_p12_passphrase.txt \
			-passout file:client_cert_passphrase.txt \
			-in $(CLIENT_CERTS_DIR)/pkcs12/$(CLIENT_CERT_CN).p12

clean_pki: clean_ca clean_intermediate_ca clean_client clean_server

clean_ca:
	$(RM) -rf $(CA_DIR)

clean_intermediate_ca:
	$(RM) -rf $(INTERMEDIATE_CA_DIR)

clean_client:
	$(RM) -rf $(CLIENT_CERTS_DIR)

clean_server:
	$(RM) -rf $(SERVER_CERTS_DIR)
