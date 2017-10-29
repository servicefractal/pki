:version: 1.0
:Authors
  Shivaram Mysore (shivaram.mysore at gmail dot com)

.. meta::
   :keywords: PKI, PKCS12, Openflow, OVS, Switch, Certificates, gNMI


============
PKI Services
============

#. ``# git clone https://github.com/servicefractal/pki``
#. ``# cd pki``
#. Edit ``*openssl.cnf`` file - and change the location of pki directory (Hint: search for smysore)
#. Edit ``*openssl.cnf`` and `build_ca.mk <build_ca.mk>`_ - change example.com to your domain name
#. Edit ``create_*_cert.sh`` - change values of CN_SERVER and CN_CLIENT as appropriate.

To build CA and Intermediate CA Certificates,

``# make -f build_ca build_pki``

To build only Client Keys, Certificates and PKCS12

``# ./create_client_cert.sh``

To build only Server Keys, Certificates and PKCS12

``# ./create_server_cert.sh``

There are ``clean`` targets available too.  Please review `build_ca.mk
<build_ca.mk>`_ Makefile.

=========================
PKI Key Store for Clients
=========================

Clients need a way to store all the Private Keys and Certificates and
Certificate chains in a single location.  We use `Network Security Services's
<https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS>`_ certutil and
pk12util utilities provided as a part of libnss3-tools package on Linux platforms.

Once all certificates and P12 files are created, run the script, `nss_certdb.sh
<nss_certdb.sh>`_ - NSS Cert/Key database is created in nss_cert_db directory.
Clients need only this script and a list of p12 files with corresponding
passwords so that they can import the same into their key database.
Applications will be able to open the same key/cert database to resolve
credentials.
