# [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels)

<br/>

## Nodes

<br/>

### Show all labels for the node `node01`

<br/>

<details><summary>show</summary><p>

```bash
kubectl get nodes node01 --show-labels
# NAME     STATUS   ROLES    AGE   VERSION   LABELS
# node01   Ready    <none>   61m   v1.18.0   accelerator=nvidia-tesla-p100,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node01,kubernetes.io/os=linux
```

</p></details>

<br />

### Label worker node `node01` with label `type=critical`

<br />

<details><summary>show</summary><p>

```bash
kubectl label node node01 type=critical
# node/node01 labeled
```

</p></details>

<br />

### Remove label `type=critical` from worker node `node01` 

<br />

<details><summary>show</summary><p>

```bash
kubectl label node node01 type-
# node/node01 labeled
```

</p></details>

<br />

## Namespaces

<br/>

### Create and label Label namespace `alpha` with label `type:critical`

<br />

<details><summary>show</summary><p>

```bash
kubectl create namespace alpha
kubectl label namespace alpha type=critical

kubectl get namespace alpha --show-labels
# NAME    STATUS   AGE   LABELS
# alpha   Active   70s   type=critical
```

</p></details>

<br />

## Pods

<br />

### Create a new pod with name `nginx-labels` and using the nginx image and labels `tier=frontend`

<br />

<details><summary>show</summary><p>

```bash
kubectl run nginx-labels --image=nginx --labels=tier=frontend
```

```bash
# verification
kubectl get pod nginx-labels --show-labels
# NAME           READY   STATUS    RESTARTS   AGE   LABELS
# nginx-labels   1/1     Running   0          16s   tier=frontend
```

</p></details>

<br />

### Create pod `nginx-labels` with `nginx` image and label `name=nginx`, `tier=frontend`, `env=dev`

<br />

<details><summary>show</summary><p>

```bash
kubectl run nginx-labels --image=nginx --labels=name=nginx,tier=frontend,env=dev,version=v1
```

OR

```yaml
cat << EOF > nginx-labels.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    env: dev
    name: nginx
    tier: frontend
    version: v1
  name: nginx-labels
spec:
  containers:
  - image: nginx
    name: nginx
EOF

kubectl apply -f nginx-labels.yaml
```

</p></details>

<br />

### Show all labels of the pod `nginx-labels`

<br/>

<details><summary>show</summary><p>

```bash
kubectl get pod nginx-labels --show-labels
# NAME           READY   STATUS    RESTARTS   AGE   LABELS
# nginx-labels   1/1     Running   0          26s   env=dev,name=nginx,tier=frontend,version=v1
```

</p></details> 

<br />

### Change the labels of pod 'nginx-labels' to be `version=v2`

<details><summary>show</summary><p>

```bash
kubectl label pod nginx-labels version=v2 --overwrite

kubectl get pod nginx-labels --show-labels
# NAME           READY   STATUS    RESTARTS   AGE    LABELS
# nginx-labels   1/1     Running   0          110s   env=dev,name=nginx,tier=frontend,version=v2
```

</p></details> 

<br />

### Get the label `env` for the pods (show a column with env labels)

<details><summary>show</summary><p>

```bash
kubectl get pod -L env
# OR  
kubectl get pod --label-columns=env
# NAME           READY   STATUS    RESTARTS   AGE   ENV
# nginx-labels   1/1     Running   0          25s   dev
```

</p></details> 

<br />

### Get only the `version=v2` pods

<details><summary>show</summary><p>

```bash
kubectl get pod -l version=v2
# OR  
kubectl get pod -l 'version in (v2)'
OR  
kubectl get pod --selector=version=v2
```

</p></details> 

<br />

### Remove the `name` label from the `nginx-labels` pod

<details><summary>show</summary><p>

```bash
kubectl label pod nginx-labels name-

kubectl get pod nginx-labels --show-labels
NAME           READY   STATUS    RESTARTS   AGE     LABELS
nginx-labels   1/1     Running   0          4m49s   env=dev,tier=frontend,version=v2
```

</p></details> 


### Clean up 

```bash
kubectl delete namespace alpha
kubectl delete pod nginx-labels --force --grace-period=0
```