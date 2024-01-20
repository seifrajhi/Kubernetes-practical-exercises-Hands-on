# old school (going to get deprecated)

```
k run --generator=run-pod/v1 <pod name> --image=<image name> --dry-run -o yaml > <podname.yaml>
```

```
k run --generator=run-pod/v1 "nginx-pod" --image=nginx -o yaml --dry-run > nginx-pod.yaml
```

or

```
k run --restart=Never <pod name> --image=<image name> --dry-run -o yaml > <podname.yaml>
```

or 

```
(new school with --dry-run=client)
```

```
k run nginx-pod --image=nginx -o yaml --dry-run=client > nginx-pod.yaml
```

```
k create -f nginx-pod.yaml
```

```
k describe pod nginx-pod
```

```
k get events
```

or 

```
kgel
```

