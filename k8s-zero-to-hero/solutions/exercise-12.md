## Exercise 12

Create the secret
```
kubectl create secret generic juicysecret --from-literal=user=kiwis --from-literal=pass=aredelicious -n kiwi
```
Add the environment variables to the pod

```
...
  containers:
  - image: nginx
    name: kiwi-secret-pod
    env:
      - name: USERKIWI
        valueFrom:
          secretKeyRef:
            name: juicysecret
            key: user
      - name: PASSKIWI
        valueFrom:
          secretKeyRef:
            name: juicysecret
            key: pass
...
```

Check that the pod is running
```
kubectl get pods -n kiwi

NAME              READY   STATUS    RESTARTS   AGE
kiwi-secret-pod   1/1     Running   0          8s


```

