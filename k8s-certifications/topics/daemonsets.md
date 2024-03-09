# [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

A DaemonSet ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

<br />

### Get the daemonset in all namespaces

<details><summary>show</summary><p>

```bash
kubectl get daemonsets --all-namespaces
# OR 
kubectl get ds -A
```

</p></details>

<br />

### Ensure a single instance of pod nginx is running on each node of the Kubernetes cluster where nginx also represents the image name which has to be used. Do not override anytaints currently in place.

<details><summary>show</summary><p>

```bash
kubectl create deploy nginx --image=nginx --dry-run=client -o yaml > nginx-ds.yaml
```

#### Edit the deployment to daemonset

```yaml
cat << EOF > nginx-ds.yaml
apiVersion: apps/v1
kind: DaemonSet # Update from Deployment to DaemonSet
metadata:
  labels:
    app: nginx
  name: nginx
spec:
#  replicas: 1 - remove replicas
  selector:
    matchLabels:
      app: nginx
#  strategy: {} - remove strategy
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
EOF

kubectl apply -f nginx-ds.yaml

kk get pods -o wide
# NAME          READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
# nginx-5k7dk   1/1     Running   0          6m10s   10.244.1.3   node01   <none>           <none>

kk get daemonset
# NAME    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
# nginx   1         1         1       1            1           <none>          6m24s

kk get ds
# NAME    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
# nginx   1         1         1       1            1           <none>          6m30s

```

</p></details>

<br />