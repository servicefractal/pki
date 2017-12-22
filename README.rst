:version: 1.0
:Authors
  Shivaram Mysore (shivaram.mysore at gmail dot com)

.. meta::
   :keywords: PKI, PKCS11, PKCS12, Openflow, OVS, Switch, Certificates, gNMI


============
PKI Services
============

#. ``# git clone https://github.com/servicefractal/pki``
#. ``# cd pki``
#. Edit ``*openssl.cnf`` file - and change the location of pki directory (Hint: search for smysore)
#. Edit ``*openssl.cnf`` and `build_ca.mk <build_ca.mk>`_ - change example.com to your domain name
#. Edit ``create_*_cert.sh`` - change values of CN_SERVER and CN_CLIENT as appropriate.

To build CA and Intermediate CA Certificates,

.. code:: console

   $ make -f build_ca build_pki

To build only Client Keys, Certificates and PKCS12

.. code:: console

   $ ./create_client_cert.sh

To build only Server Keys, Certificates and PKCS12

.. code:: console

    $ ./create_server_cert.sh

There are ``clean`` targets available too.  Please review `build_ca.mk
<build_ca.mk>`_ Makefile.

For embedded systems such as a Network Switch, key pair is generated on the
machine and a PEM encoded Certificate Signing Request (CSR) is generated for
a subsequent signture by a Certificate Authority (CA).  The script ``sign_csr.sh``
enables one to sign such a PEM encoded CSR file with the Intermediate CA.

.. note::
    filename argument provided to ``sign_csr.sh`` script should *not* include file extension (.pem)

.. code:: console

    $ ./sign_csr.sh provided_csr


=========================
PKI Key Store for Clients
=========================

Clients need a way to store all the Private Keys and Certificates and
Certificate chains in a single location.  We use `Network Security Services's
<https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS>`_ ``certutil`` and
``pk12util`` utilities provided as a part of ``libnss3-tools`` package on Linux platforms.

Once all certificates and ``P12`` files are created, run the script, `nss_certdb.sh
<nss_certdb.sh>`_ - NSS Cert/Key database is created in ``nss_cert_db`` directory.
Clients need only this script and a list of ``p12`` files with corresponding
passwords so that they can import the same into their key database.
Applications will be able to open the same key/cert database to resolve
credentials.

=======================================
PKCS 11 based External Security Modules
=======================================

Public Key Cryptography Standard - PKCS #11 is a standard that defines modules
that can store keys and certificates used for encryption and decryption.

The use of NSS's ``certutil`` enables one to use PKCS #11 based hardware security
modules (HSM) to store keys and certificates.  This means if one were to be
running for example Open vSwitch (OVS) directly on hardware, and if OVS needs to
be FIPS 140-2 certified, then they can just a load a Hardware Security Module to
store keys.

Installing PKCS#11 modules requires the NSS ``modutil`` tool.  Refer to the HSM
manufacturer instructions for installing the module.  Normally, this would be as
simple as running the below to install a nCipher HSM:

.. code:: bash

  $ modutil -dbdir . -nocertdb -add nethsm -libfile /opt/nfast/toolkits/pkcs11/libcknfast.so


To list loaded PKCS11 modules:

.. code:: bash

  $ modutil -list -dbdir .
