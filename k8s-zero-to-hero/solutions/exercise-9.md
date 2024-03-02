## Exercise 9

```
 kubectl create configmap configmap-kiwi --from-file=web-kiwi.html
```

Check that container is now running:
```
kubectl get pods

NAME                           READY   STATUS    RESTARTS   AGE
kiwi-deploy-7b9bcf5445-xdf6f   1/1     Running   0          2m14s
```
