## Exercise 15

Create a template for the pod:
```
kubectl run grapes --image=busybox:1.31.0 --dry-run=client -o yaml --command -- /bin/sh -c 'echo I am ape for grapes; sleep 3600' > grapes.yaml
```

Apply the file:
```
kubectl create -f grapes.yaml
```

Get the pod logs and redirect the output to the file:
```
kubectl logs grapes >> grape-logs.txt
```

Check that the file contains the requested logs:
```
cat grape-logs.txt

I am ape for grapes

```
