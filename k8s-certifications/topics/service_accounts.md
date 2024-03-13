# Service Account

A service account provides an identity for processes that run in a Pod.
**NOTE**: From k8s 1.24, when a ServiceAccount is created, token and secrets would not be create automatically. You can create the token and secrets manually.

<br />

### Create Service Account `sample-sa`

<details><summary>show</summary><p>

```bash
kubectl create serviceaccount sample-sa
# OR
kubectl create sa sample-sa
```

OR

```yaml
cat << EOF > sample-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sample-sa
EOF

kubectl apply -f sample-sa.yaml
```

```bash
kubectl describe serviceaccount sample-sa # Verify, no secret and token are created automatically
Name:                sample-sa
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>

```

</p></details> 

<br />

### Create Service Account `sample-sa-no-auto-mount` with auto mounting disabled 

<br />

<details><summary>show</summary><p>

```yaml
cat << EOF > sample-sa-no-auto-mount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sample-sa-no-auto-mount
automountServiceAccountToken: false
EOF

kubectl apply -f sample-sa-no-auto-mount.yaml
```

</p></details> 

<br />

### Create a pod with name `nginx-sa` and with image `nginx` and service account `sample-sa`

<br />

<details><summary>show</summary><p>

```bash
kubectl run nginx-sa --image=nginx --serviceaccount=sample-sa
```

OR 

```yaml
cat << EOF > nginx-sa.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-sa
spec:
  containers:
  - image: nginx
    name: nginx-sa
  serviceAccountName: sample-sa
EOF

kubectl apply -f nginx-sa.yaml
```

</p></details> 

<br />

### Clean up

```bash
rm nginx-sa.yaml sample-sa-no-auto-mount.yaml sample-sa.yaml
kubectl delete pod nginx-sa --force --grace-period=0
kubectl delete serviceaccount sample-sa-no-auto-mount sample-sa
```