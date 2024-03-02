## Exercise 5

First we need to check the status of the deployment and the pods:
```
kubectl rollout status deployment lemon -n banana

Waiting for deployment "lemon" rollout to finish: 1 old replicas are pending termination...
```
We can see that the new pods are not available due ImagePullBackOff
```
kubectl get pods -n banana

NAME                     READY   STATUS             RESTARTS   AGE
lemon-55c4b469b9-5jnld   1/1     Running            0          73s
lemon-d956f49f9-wkldc    0/1     ImagePullBackOff   0          57s
```
Check the deployment history
```
kubectl rollout history deployment lemon -n banana
```

And rollback to the previous version
```
kubectl rollout undo deployment lemon -n banana

deployment.apps/lemon rolled back
```

Check that the deployment is now running succesfully:
```
kubectl rollout status deployment lemon -n banana

deployment "lemon" successfully rolled out
```






