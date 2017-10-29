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

There are ``clean`` targets available too.  Please review `build_ca.mk <build_ca.mk>`_ Makefile.
