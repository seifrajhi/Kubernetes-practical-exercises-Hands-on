```
$ kubectl apply -f service.yml
```

```
$ kubectl get service
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP                        PORT(S)          AGE
hostname-service   LoadBalancer   10.43.199.184   172.18.0.2,172.18.0.3,172.18.0.4   8000:31165/TCP   61s
```

```
$ curl http://localhost:8000
Hostname: my-hostname-deployment-575594bff5-mf969
```
