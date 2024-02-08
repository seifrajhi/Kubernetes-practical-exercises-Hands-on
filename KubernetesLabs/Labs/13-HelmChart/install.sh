# Remove old chart if its already esists
helm uninstall charts-demo

# Pack the Helm in the desired folder
helm package codewizard-nginx-helm

# install the helm and view the output
helm install --debug codewizard-helm-demo-0.1.0.tgz charts-demo 

# verify that the chart installed
kubectl get all -n codewizard

# Check the response from the chart
kubectl run --image=busybox b1 --rm -it --restart=Never -- /bin/sh -c "wget -qO- http://charts-demo-codewizard-helm-demo.codewizard.svc.cluster.local"