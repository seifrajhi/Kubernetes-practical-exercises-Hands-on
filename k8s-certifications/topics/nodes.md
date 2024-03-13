# Nodes

<br />

### Get the nodes of the cluster

<details><summary>show</summary><p>

```bash
kubectl get nodes
# NAME           STATUS   ROLES    AGE   VERSION
# controlplane   Ready    master   62m   v1.18.0
# node01         Ready    <none>   61m   v1.18.0
```

</p></details>

<br />

### Show all labels for the node `node01`

<details><summary>show</summary><p>

```bash
kubectl get nodes node01 --show-labels
# NAME     STATUS   ROLES    AGE   VERSION   LABELS
# node01   Ready    <none>   61m   v1.18.0   accelerator=nvidia-tesla-p100,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node01,kubernetes.io/os=linux
```

</p></details>

<br />

### Label worker node `node01` with label `type=critical`

<details><summary>show</summary><p>

```bash
kubectl label node node01 type=critical
# node/node01 labeled
```

</p></details>

<br />

### Remove label `type=critical` from worker node `node01` 

<details><summary>show</summary><p>

```bash
kubectl label node node01 type-
# node/node01 labeled
```

</p></details>

<br />

### Get usage metrics such CPU and Memory of the cluster nodes

<details><summary>show</summary><p>

```bash
kubectl top nodes
```

</p></details>

<br />

### Set the node named node01 unavailable and reschedule all the pods running on it.

<details><summary>show</summary><p>

```bash
kubectl drain node01 --ignore-daemonsets --force # drain will cordon the node as well
# node/node01 cordoned
# Pods: kube-system/kube-flannel-ds-amd64-6mrm2, kube-system/kube-keepalived-vip-zchjw, kube-system/kube-proxy-ms2mf
# WARNING: deleting Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet: default/multi-container-nrm; ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-6mrm2, kube-system/kube-keepalived-vip-zchjw, kube-system/kube-proxy-ms2mf
# evicting pod default/multi-container-nrm
# evicting pod kube-system/katacoda-cloud-provider-6c46f89b5c-jvb7g
# pod/multi-container-nrm evicted
# pod/katacoda-cloud-provider-6c46f89b5c-jvb7g evicted
# node/node01 evicted
```

</p></details>

<br />