```
kubectl apply -f addons/openebs/local-hostpath-pvc.yaml
```

```
kubectl apply -f addons/openebs/ngix-deployment.yml
```

```
kubectl get pvc
```

```
##local-hostpath-pvc   Bound    pvc-55ed95ca-c957-4211-9722-d3b5942a2aca
```

```
k get pods -o wide
```

## nginx-deploy-765579fd89-8d8vv   1/1     Running   0          4m24s   10.42.1.17   node2
## nginx is running on node2
```
multipass shell node2
```

```
cd /var/openebs/local/pvc-55ed95ca-c957-4211-9722-d3b5942a2aca/
```

```
vi index.html
```

## paste the following in the index.html file and save:

```
<h1>Hello OpenEBS World on Bonsai Kube</h1>
```

```
exit
```

```
kubectl expose deployment nginx-deploy --port=80 --type=LoadBalancer
```

```
kubectl get svc
```

## get the external ip of the service
```
curl http://192.168.64.25
```

## you should get
## <h1>Hello OpenEBS World on Bonsai Kube</h1>
## or

```
open http://192.168.64.25
```

