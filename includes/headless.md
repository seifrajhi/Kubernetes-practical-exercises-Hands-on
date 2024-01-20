```
k delete svc kubia
```

```
k expose deployment kubia --name kubia-headless --cluster-ip None
```

```
k expose deployment kubia --name kubia-clusterip
```

```
k expose deployment kubia --name kubia-lb --type=LoadBalancer
```

```
k scale deployment kubia --replicas 3
```

```
k run --generator=run-pod/v1 utils -it --image kubernautslabs/utils -- bash
```


### inside the utils container

```
host kubia-headless
```

```
host kubia-clusterip
```


### what is the difference here?

```
for i in $(seq 1 10) ; do curl kubia-headless:8080; done
```

### hits kubia only on one node? 

```
for i in $(seq 1 10) ; do curl kubia-clusterip:8080; done
```

### does load balancing via the head ;-)

```
exit
```

```
mkcert '*.whereami.svc'
```
```
k create secret tls whereami-secret --cert=_wildcard.whereami.svc.pem --key=_wildcard.
whereami.svc-key.pem
```

```
cat kubia-ingress-tls.yaml
```

```
k create -f kubia-ingress-tls.yaml
```

### Please provide the host entry mapping in your /etc/hosts file like this:


### 192.168.64.23 my.whereami.svc

### the IP should be the IP of the traefik loadbalancer / ingress controller

```
curl https://my.whereami.svc
```

```
for i in $(seq 1 10) ; do curl https://my.whereami.svc; done
```

### the ingress controller does load balancing, although the kubia-headless is defined as the backend with serviceName: kubia-headless!
