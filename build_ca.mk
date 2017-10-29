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

SUBJECT_CA := "/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=PKI Network Services/CN=ca.pki.example.com"
SUBJECT_INTERMEDIATE_CA := "/C=US/ST=CA/L=Santa Clara/O=Example Inc/OU=PKI Network Services/CN=intermediate.ca.pki.example.com"

.PHONY: all build_pki clean_pki

all: build_pki

build_pki: build_ca build_intermediate_ca

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

clean_pki: clean_ca clean_intermediate_ca

clean_ca:
	$(RM) -rf $(CA_DIR)

clean_intermediate_ca:
	$(RM) -rf $(INTERMEDIATE_CA_DIR)
