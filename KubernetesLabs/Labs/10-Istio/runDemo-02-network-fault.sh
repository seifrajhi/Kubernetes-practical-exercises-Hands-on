#!/bin/bash

set +x

# Verify that we have the pre-requirments from demo01
./runDemo-01-demo-services.sh

# Add the fault VirtulaService to the cluster
kubectl apply -f web-server1-network-faults.yaml