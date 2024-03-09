# [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

 - ReplicaSet ensures that a specified number of pod replicas are running at any given time.
 - It is recommended to use Deployments instead of directly using ReplicaSets, as they help manage ReplicaSets and provide declarative updates to Pods.

<br />

### Check number of replica sets in the default namespace

<br />

<details><summary>show</summary><p>

```bash
kubectl get replicasets
# OR
kubectl get rs
```

</p></details> 

<br />

### Create a replica set named `replica-set-demo` using a pod named ngnix using a nginx image and labeled as `tier=frontend` with a single replica.

<br />

<details><summary>show</summary><p>

```yaml
cat << EOF > replica-set-demo.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica-set-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
EOF

kubectl apply -f replica-set-demo.yaml
```

</p></details>

<br />

### Scale up the `replica-set-demo` from 1 replica to 2 replicas

<br />

<details><summary>show</summary><p>

```bash
kubectl scale replicaset replica-set-demo --replicas=2
```

OR

Edit the replica set definition file `replica-set-demo.yaml` and apply `kubectl apply -f replica-set-demo.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica-set-demo
spec:
  replicas: 2 # update this
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
EOF
```

</p></details>

<br />

### Scale up the `replica-set-demo` from 2 replicas to 1 replica

<br />

<details><summary>show</summary><p>

```bash
kubectl scale replicaset replica-set-demo --replicas=1
```

OR

#### Edit the replica set definition file `replica-set-demo.yaml` and apply `kubectl apply -f replica-set-demo.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replica-set-demo
spec:
  replicas: 1 # update this
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
EOF
```

</p></details>

<br />

### Create a replica set using the below definition and fix any issues.

<br />

```yaml
apiVersion: v1
kind: ReplicaSet
metadata:
  name: replicaset-1
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx
```

<details><summary>show</summary><p>

#### Check the apiVersion using `kubectl explain replicasets` which is `apps/v1`.  
Update the version and apply again.

</p></details>

<br />

### Create a replica set using the below definition and fix any issues.

<br />

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: replicaset-2
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
```

<details><summary>show</summary><p>

The replica set selector field `tier: frontend` does not match the pod labels `tier: nginx`. Correct either of them and reapply.

</p></details>

<br />

### Clean up 

```bash
kubectl delete replicaset replica-set-demo replicaset-1 replicaset-2
rm replica-set-demo.yaml
```
