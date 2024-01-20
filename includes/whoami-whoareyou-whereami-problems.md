```
k apply -f 1-whoami-deployment.yaml
```

```
k get all
```

## we expose the deployment with a service of type ClusterIP

```
k create -f 1-whoami-service-ClusterIP.yaml
```

```
k get svc
```

```
k port-forward service/whoami-service 8080:80
```

## in a new terminal session call
```
curl 127.0.0.1:8080
```

```
k delete svc whoami-service
```

## create a service of type NodePort
```
k create -f 1-whoami-service-nodeport.yaml
```

```
k get svc
```

```
curl csky08:30056 # adapt the nodeport for your env. please !
```

```
curl csky09:30056
```

```
curl csky10:30056
```

```
k delete svc whoami-service-nodeport
```

```
k create -f 1-whoami-service-loadbalancer.yaml
```

```
k get svc
```

```
curl <EXTERNAL-IP> # the external-ip is given from the LB IP pool above
```

```
k create -f 2-whoareyou-all.yml
```

```
k get all
```

```
k get svc
```

```
k get ing
```

```
curl <HOSTS value from ingress>
```

## are you happy? 😊
