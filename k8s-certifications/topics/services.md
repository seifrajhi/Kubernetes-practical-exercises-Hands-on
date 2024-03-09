# [Services](https://kubernetes.io/docs/concepts/workloads/controllers/services/)

<br />

### Create a pod `nginx-clusterip` with image `nginx`. Expose it as a ClusterIP service.

<details><summary>show</summary><p>

```bash
kubectl run nginx-clusterip --image=nginx --restart=Never --port=80 --expose

kubectl get service nginx-clusterip # verification
# NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
# nginx-clusterip   ClusterIP   10.104.163.30   <none>        80/TCP    6s
```

</p></details>

<br />

### Create a pod `nginx-nodeport` with image `nginx`. Expose it as a NodePort service `nginx-nodeport-svc`

<details><summary>show</summary><p>

```bash
kubectl run nginx-nodeport --image=nginx --restart=Never --port=80
kubectl expose pod nginx-nodeport --name nginx-nodeport-svc --type NodePort --port 80 --target-port 80
```

OR 

```yaml
cat << EOF > nginx-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    run: nginx-nodeport
  name: nginx-nodeport-svc
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx-nodeport
  type: NodePort
status:
  loadBalancer: {}
EOF

kubectl apply -f nginx-nodeport.yaml
```

```bash
# verification - port expose might change
kubectl get svc nginx-nodeport-svc
# NAME                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# nginx-nodeport-svc   NodePort   10.106.55.131   <none>        80:31287/TCP   12s 
```

</p></details>

<br />

### Create a deployment `nginx-deployment` with image `nginx` and 3 replicas. Expose it as a NodePort service `nginx-deployment-svc` on port 30080.

<details><summary>show</summary><p>

```bash
kubectl create deploy nginx-deployment --image nginx && kubectl scale deploy nginx-deployment --replicas 3
kubectl expose deployment nginx-deployment --type NodePort --port 80 --target-port 80 --dry-run=client -o yaml > nginx-deployment-svc.yaml
```

Edit `nginx-deployment-svc.yaml` to add `nodePort: 30080` and apply `kubectl apply -f nginx-deployment-svc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30080 # add node port
  selector:
    app: nginx-deployment
  type: NodePort
status:
  loadBalancer: {}
```

```bash
# verification
kubectl get service nginx-deployment 
# NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# nginx-deployment   NodePort   10.43.166.122   <none>        80:30080/TCP   38s
```
</p></details>

<br />

### Clean up 

```bash
# clean up 
kubectl delete service nginx-deployment nginx-nodeport-svc
kubectl delete deployment nginx-deployment nginx-nodeport
```