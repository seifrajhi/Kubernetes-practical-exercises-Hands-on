## Exercise 1

We have to list all the pods in all namespaces (`--A`) and as we are getting only the container name (not the pod name) we have to display the container name, the pod name and the namespace in custom columns:

```
kubectl get pods -A --output=custom-columns='CONTAINER:.spec.containers[0].name,NAME:.metadata.name,NAMESPACE:.metadata.namespace'

```

We cannot edit the pod and change the namespace, so we have to extract the pod yaml to modify it locally:
```
kubectl get pod banana-boat -n pineapple -o yaml > banana-boat.yaml
```
We have to modify the field `metadata.namespace` to `banana`.
Then delete the old pod:
```
kubectl delete pod banana-boat -n pineapple
```
And apply the new file:
```
kubectl create -f banana-boat.yaml
```









