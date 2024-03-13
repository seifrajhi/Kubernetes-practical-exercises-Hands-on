#!/bin/bash

# create pod definition with non-existent image or incorrect image name
cat <<EOF > pod-definition.yaml
apiVersion: v1
kind: Pod
metadata:
    name: my-pod
spec:
    containers:
    - name: my-container
      image: nginx:2.0
EOF

# apply the configuration to your Kubernetes cluster
kubectl apply -f pod-definition.yaml

echo "setup completed"
