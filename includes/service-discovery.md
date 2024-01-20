```
cd whereami
```

```
k create ns ns1
```

```
k create ns ns2
```

```
kn ns1
```

```
cat kubia-deployment.yaml   
```

```
k create -f kubia-deployment.yaml
```

```
k create -f kubia-deployment.yaml -n ns2
```

```
k expose deployment kubia
```

```
k get svc
```

```
k expose deployment kubia -n ns2
```

```
k get svc -n ns2
```

```
k exec -it kubia-<press tab> -- curl kubia.ns2.svc.cluster.local:8080
```

```
k scale deployment kubia -n ns2 --replicas 3
```

## repeat the service call many times and see how loadbalancing works

```
k exec -it kubia-<press tab> -- curl kubia.ns2.svc.cluster.local:8080
```

```
k exec -n ns2 -it kubia-<press tab> -- curl kubia.ns1.svc.cluster.local:8080
```

```
k exec -it kubia-<press tab> -- ping kubia.ns2.svc.cluster.local
```

```
--> PING kubia.ns2.svc.cluster.local (10.43.109.89) 56(84) bytes of data.
```

## you don't get any pong, why?

## ssh into a node and examine the IPtable rules

```
sudo iptables-save | grep kubia
```

