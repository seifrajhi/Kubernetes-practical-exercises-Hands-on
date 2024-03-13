# [Kubectl jsonpath](https://kubernetes.io/docs/reference/kubectl/jsonpath/)

<br />

### Get node details as custom fields with NODE_NAME for nodename, CPU_COUNT for cpu.

<details><summary>show</summary><p>

```bash
$ kubectl get nodes -o=custom-columns=NODE_NAME:.metadata.name,CPU_COUNT:.status.capacity.cpu
# NODE_NAME      CPU_COUNT
# controlplane   2
# node01         2
```

</p></details>

<br />

### Setup few containers and deployments

```bash
kubectl run nginx-dev --image nginx:1.21.4-alpine
kubectl run nginx-qa --image nginx:1.21
kubectl run nginx-prod --image nginx:1.21
```

### List all Container images in all namespaces

<details><summary>show</summary><p>

```bash
kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}}' | tr " " "\n" 
# nginx:1.21.4-alpine
# nginx:1.21
# nginx:1.21
# k8s.gcr.io/coredns:1.6.7
# k8s.gcr.io/coredns:1.6.7
# k8s.gcr.io/etcd:3.4.3-0
# katacoda/katacoda-cloud-provider:0.0.1
# k8s.gcr.io/kube-apiserver:v1.18.0
# k8s.gcr.io/kube-controller-manager:v1.18.0
# quay.io/coreos/flannel:v0.12.0-amd64
# quay.io/coreos/flannel:v0.12.0-amd64
# gcr.io/google_containers/kube-keepalived-vip:0.9
# k8s.gcr.io/kube-proxy:v1.18.0
# k8s.gcr.io/kube-proxy:v1.18.0
# k8s.gcr.io/kube-scheduler:v1.18.0}
```

</p></details>

<br />

### List all the pods sorted by name

<details><summary>show</summary><p>

```bash
kubectl get pods --sort-by=.metadata.name
# NAME         READY   STATUS    RESTARTS   AGE
# nginx-dev    1/1     Running   0          91s
# nginx-prod   1/1     Running   0          91s
# nginx-qa     1/1     Running   0          91s
```

</p></details>

<br />

### Check the Image version of nginx-dev pod using jsonpath

<details><summary>show</summary><p>

```bash
kubectl get pod nginx-dev -o jsonpath='{.spec.containers[0].image}'
# nginx:1.21.4-alpine
```

</p></details>

<br />

### List the nginx pod with custom columns POD_NAME and POD_STATUS

<details><summary>show</summary><p>

```bash
kubectl get po -o=custom-columns="POD_NAME:.metadata.name, POD_STATUS:.status.containerStatuses[].state" | tr " " "\n" 
```

</p></details>

<br />