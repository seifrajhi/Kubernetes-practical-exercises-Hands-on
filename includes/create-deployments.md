```
k create <object> <name> <options> --dry-run -o yaml > <objectname.yaml>
```

```
k create deployment nginx-deployment --image=nginx --dry-run -o yaml > nginx-deployment.yaml
```

```
cat nginx-deployment.yaml
```

```
k create -f nginx-pod.yaml
```

# create a service via exposing the pod

```
k expose pod nginx-pod --port=80
```

```
k get svc
```

```
k port-forward service/nginx-pod 8080:80
```

or

```
k proxy
```

```
open http://127.0.0.1:8001/api/v1/namespaces/default/pods/nginx-pod/proxy/
```

# open a new terminal session

```
curl http://127.0.0.1:8080/
```

```
k delete all --all # with caution!!!
```

```
k create -f nginx-deployment.yaml
```

```
k get all
```

```
k get all -A
```

```
k expose deployment nginx-deployment --port=80
```

```
k port-forward service/nginx-deployment 8080:80
```

```
k scale --replicas 3 deployment nginx-deployment
```

```
k edit deployment nginx-deployment
```

```
vi nginx-deployment.yaml # adapt the number of replicas, e.g. to 2
```

```
k apply -f nginx-deployment.yaml
```

