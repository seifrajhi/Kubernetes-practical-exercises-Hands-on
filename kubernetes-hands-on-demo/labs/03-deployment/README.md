```
$ kubectl get deployments
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
my-hostname-deployment   3/3     3            3           3m38s
```

```
$ kubectl get pods -l app=hostname
NAME                                      READY   STATUS    RESTARTS   AGE
my-hostname-deployment-575594bff5-lz6n8   1/1     Running   0          4m5s
my-hostname-deployment-575594bff5-mf969   1/1     Running   0          4m5s
my-hostname-deployment-575594bff5-vzz2s   1/1     Running   0          4m5s
```

```
$ kubectl port-forward pod/my-hostname-deployment-575594bff5-lz6n8 8001:8000
```

```
$ curl http://localhost:8001
Handling connection for 8001
Hostname: my-hostname-deployment-575594bff5-lz6n8
```
