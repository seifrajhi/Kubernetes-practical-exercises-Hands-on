# [Runtime Class](https://kubernetes.io/docs/concepts/containers/runtime-class/)

<br />

### Create the following `gvisor` runtime class and create a nginx pod referring the `gvisor` runtime.

<br />

```yaml
cat << EOF > gvisor.yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
EOF

kubectl apply -f gvisor.yaml
```

<details><summary>show</summary><p>

```yaml
cat << EOF > nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  runtimeClassName: gvisor
  containers:
  - image: nginx
    name: nginx
  restartPolicy: Always
EOF

kubectl apply -f nginx.yaml

# NOTE : Pod may not come up as the runtime does not actually exist
```
</p></details>

