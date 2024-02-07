#!/bin/sh 

#################################
## Access the internal K8S API ##
#################################
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
# The service account is mapped by the K8S Api server in the pods
SERVICE_ACCOUNT_FOLDER=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace if required
# NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICE_ACCOUNT_FOLDER}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICE_ACCOUNT_FOLDER}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api