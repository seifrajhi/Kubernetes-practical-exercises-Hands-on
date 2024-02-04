
```
$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
my-hostname-app                          1/1     Running   0          2m24s
```

```
$ kubectl describe pod my-hostname-app
Name:         my-hostname-app
Namespace:    default
Priority:     0
Node:         k3d-demo-worker-1/172.18.0.4
Start Time:   Sun, 29 Sep 2019 23:47:33 +0200
Labels:       env=staging
...
```

```
$ kubectl get pods -l env=staging
NAME              READY   STATUS    RESTARTS   AGE
my-hostname-app   1/1     Running   0          22s
```

```
$ kubectl get pods -l env=staging -L env
NAME              READY   STATUS    RESTARTS   AGE   ENV
my-hostname-app   1/1     Running   0          29s   staging
```
