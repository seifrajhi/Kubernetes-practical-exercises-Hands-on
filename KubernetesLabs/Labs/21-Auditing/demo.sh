#!/bin/sh

# Debug mode
set -x

# Stop minikube if its running and delet prevoiud data
minikube stop

# Set the minikube home directory
export MINIKUBE_HOME=~/.minikube

# The AuditPolicy file
AUDIT_POLICY_FILE=$MINIKUBE_HOME/files/etc/ssl/certs/Audit-Policy.yaml

# Create the desired folder(s)
mkdir -p resources
mkdir -p logs

# Check to see if we have a pre defined Audit Policy file
if [[ ! -f $AUDIT_POLICY_FILE ]];
then
# Create the Policy file if its not exist
cat <<EOF > $AUDIT_POLICY_FILE
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF
fi;

# Start minikube with the AuditPolicy
minikube start \
     --extra-config=apiserver.audit-policy-file=$AUDIT_POLICY_FILE \
     --extra-config=apiserver.audit-log-path=${PWD}/logs/audit.log \
     --extra-config=kubelet.cgroup-driver=systemd \
     --alsologtostderr \
     -v=8 
    
# Test the audit policy
kubectl create ns TestAudit

# Print out the Audit log
kubectl logs kube-apiserver-minikube -n kube-system | grep audit.k8s.io/v1