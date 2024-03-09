# [Namespaces](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

 - Namespaces provide a mechanism for isolating groups of resources within a single cluster.
 - Namespace-based scoping is applicable only for namespaced objects (e.g. Deployments, Services, etc) and not for cluster-wide objects (e.g. StorageClass, Nodes, PersistentVolumes, etc).
 - Names of resources need to be unique within a namespace, but not across namespaces.
 
<br />

### Check the namespaces on the cluster

<br />

<details><summary>show</summary><p>

```bash
kubectl get namespaces
```

</p></details>

<br />

### Create namespace named `alpha`

<br />

<details><summary>show</summary><p>

```bash
kubectl create namespace alpha
```

</p></details>

<br />

### Get pods from `alpha` namespace

<br />

<details><summary>show</summary><p>

```bash
kubectl get pods --namespace=alpha
# OR 
kubectl get pods -n=alpha
```

</p></details>

<br />

### Get pods from all namespaces

<br />

<details><summary>show</summary><p>

```bash
kubectl get pods --all-namespaces
#OR 
kubectl get pods -A
```

</p></details>

<br />

### Label namespace `alpha` with label `type:critical`

<br />

<details><summary>show</summary><p>

```bash
kubectl label namespace alpha type=critical

kubectl get namespace alpha --show-labels
# NAME    STATUS   AGE   LABELS
# alpha   Active   70s   type=critical
```

</p></details>

### Delete namespace `alpha`

<br />

<details><summary>show</summary><p>

```bash
kubectl delete namespace alpha
```

</p></details>