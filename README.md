# PKI Services
```
# git clone https://github.com/servicefractal/pki
# cd pki
```
Edit *openssl.cnf file - and change the location of pki directory (Hint: search for smysore)
Edit *openssl.cnf and Makefile - change example.com to your domain name
Edit Makefile - change values of CN_SERVER and CN_CLIENT as appropriate.

Run:
```
# make pki
```
The above builds CA, Intermediate CA, Server and Client Certificates.

To build only Client Keys, Certificates and PKCS12, edit ```Makefile``` - change values of ```CN_CLIENT``` as appropriate and run:

```
# make build_client_cert
```

To build only Server Keys, Certificates and PKCS12, edit ```Makefile``` - change values of ```CN_SERVER``` as appropriate and run:

```
# make build_server_cert
```

There are clean targets available too.  Please checkout the Makefile.

