#!/bin/bash
# This script generates SSL certs (.crt and .key) to be used with nginx.
# The files are generated in .PEM format.

echo "Generating self signed certificate ..."
openssl req \
  -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout tls.key -out tls.crt -subj '/CN=*.example.com'

echo "...Done."

#echo "Creating a combined PEM file out of the two certificate files ... (in case you need it later)"
#cat tls.crt tls.key > tls-cert-plus-key.pem
#echo
echo "Here are the generated certificate files:"
ls -1 tls.*



