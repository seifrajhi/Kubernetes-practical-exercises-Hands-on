## Exercise 2

We can create the pod yaml using the `--dry-run=client` option:
```
kubectl run alphapod --image=nginx:1.7.9 --dry-run=client -o yaml > alphapod.yaml
```

We edit the local yaml to modify the container name (spec.containers.name):
```
vi alphapod.yaml
```

Apply the new yaml file:
```
kubectl create -f alphapod.yaml
```



