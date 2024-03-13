# [Pod](https://kubernetes.io/docs/concepts/workloads/pods/)

 - A Kubernetes pod is a group of containers, and is the smallest unit that Kubernetes administers. 
 - Pods have a single IP address that is applied to every container within the pod.
 - Pods can have single or multiple containers.
 - Containers in a pod share the same resources such as memory and storage.
 - Remember, you CANNOT edit specifications of an existing POD other than the below.
   - spec.containers[*].image
   - spec.initContainers[*].image
   - spec.activeDeadlineSeconds
   - spec.tolerations
 -  Edit the pod for changes and a tmp file is created. Delete and Recreate the pod using the tmp file.

<br />

 - [Basics](#basics)
 - [Multi-container Pods](#multi-container-pods)
 - [Node Selector](#node-selector)
 - [Resources - Requests and limits](#resources)
 - [Static Pods](#static-pods)
 - [Init Containers](#init-containers)

## Basics

<br />

### Check number of pods in the default namespace

<br />

<details><summary>show</summary><p>

```bash
kubectl get pods
# OR
kubectl get po
```
</p></details>

<br />

### Create a new pod with name `nginx` and using the `nginx` image

<details><summary>show</summary><p>

```bash
kubectl run nginx --image=nginx
```

</p></details>

<br />


### Create a pod named `mongo` using image `mongo` in a new Kubernetes namespace `my-website`

<details><summary>show</summary><p>

```bash
kubectl create namespace my-website
kubectl run mongo --image=mongo --namespace=my-website
```

</p></details>

<br />


### Create a new pod with name nginx and using the nginx image in the `alpha` namespace

<details><summary>show</summary><p>

```bash
kubectl create namespace alpha
kubectl run nginx --image=nginx --namespace=alpha
```

</p></details>

<br />

### Create a new pod `custom-nginx` using the `nginx` image and expose it on container port 8080.

<details><summary>show</summary><p>

```bash
kubectl run custom-nginx --image=nginx --port=8080
```

</p></details>

<br />

### Check which node the pod is hosted on 

<details><summary>show</summary><p>

```bash
kubectl get pods -o wide
``` 

</p></details>

<br />

### Get only the pods name

<details><summary>show</summary><p>

```bash
kubectl get pods -o name
```

</p></details>

<br />

### Delete the pod with the name nginx

<details><summary>show</summary><p>

```bash
kubectl delete pod nginx
```

</p></details>

<br />

### Delete the pod with the name nginx in the `alpha` namespace

<details><summary>show</summary><p>

```bash
kubectl delete pod nginx --namespace=alpha
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

### Delete the pod with name `nginx-labels` with force and no grace period

<details><summary>show</summary><p>

```bash
kubectl delete pod nginx-labels --force --grace-period=0
```

</p></details>

<br />

### Create a pod with name `nginx-file` and image nginx using pod defination file

<details><summary>show</summary><p>

```bash
kubectl run nginx-file --image=nginx --dry-run=client -o yaml > nginx-file.yaml
kubectl apply -f nginx-file.yaml
```
</p></details>

<br />

### Create a nginx pod with name nginx and copy the pod definition file to a nginx_definition.yaml file

<details><summary>show</summary><p>

```bash
kubectl run nginx --image=nginx
kubectl get nginx -o yaml > nginx_definition.yaml
```

</p></details>

<br />

### Create a `ubuntu-1` pod with image `ubuntu` with command `sleep 4800`

<details><summary>show</summary><p>

```bash
kubectl run ubuntu-1 --image=ubuntu --command sleep 4800
```

</p></details>

<br />

### A web application requires a specific version of redis to be used as a cache. Create a pod with the following characteristics, and leave it running when complete:
- The pod must run in the web namespace.
- The name of the pod should be cache
- Use the redis image with the 3.2 tag
- Expose port 6379

<br />

<details><summary>show</summary><p>

```bash
kubectl create namespace web
kubectl run cache --image redis:3.2 --port 6379 --namespace web
```

</p></details>

<br />

## Multi-container Pods

<br />

Refer [Multi-container Pods](multi_container_pods.md)

<br />

## [Node Selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

<br />

### Create a pod `nginx-node-selector` that will be deployed to a Node that has the label `accelerator=nvidia-tesla-p100`

<details><summary>show</summary><p>

Add the label to a node:

```bash
kubectl label nodes node01 accelerator=nvidia-tesla-p100
```

We can use the 'nodeSelector' property on the Pod YAML:

```yaml
cat << EOF > nginx-node-selector.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-node-selector
spec:
  containers:
    - name: nginx-node-selector
      image: nginx
  nodeSelector: # add this
    accelerator: nvidia-tesla-p100 # the selection label
EOF

kubectl apply -f nginx-node-selector.yaml
```

OR

Use node affinity (https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/#schedule-a-pod-using-required-node-affinity)

```yaml
cat << EOF > nginx-node-selector.yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: accelerator
            operator: In
            values:
            - nvidia-tesla-p100
  containers:
    - name: nginx-node-selector
      image: nginx
EOF

kubectl apply -f nginx-node-selector.yaml

```

</p></details> 

<br />

### Remove the `description` annotations for pod `nginx-annotations` 

<details><summary>show</summary><p>

```bash
kubectl annotate pod nginx-annotations description-
```

</p></details> 

<br /> 

### Remove these `nginx-annotations` pod to have a clean state in your cluster

<details><summary>show</summary><p>

```bash
kubectl delete pod nginx-annotations --force
```

</p></details> 

<br />

## [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

<br />

### Create an nginx pod name `nginx-resources` with `requests` `cpu=100m,memory=256Mi` and `limits` `cpu=200m,memory=512Mi`

<br />

<details><summary>show</summary><p>

```bash
kubectl run nginx-resources --image=nginx --restart=Never --requests='cpu=100m,memory=256Mi' --limits='cpu=200m,memory=512Mi'
```

OR 

```yaml
cat << EOF > nginx-resources.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-resources
  name: nginx-resources
spec:
  containers:
  - image: nginx
    name: nginx-resources
    resources:
      limits:
        cpu: 200m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 256Mi
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
EOF

kubectl apply -f nginx-resources.yaml
```

</p></details>

<br />

## [Static Pods](https://kubernetes.io/docs/concepts/workloads/pods/#static-pods)

<br />

### Configure the kubelet systemd-managed service, on the node labelled with name=node01, to launch a pod containing a single container of Image httpd named webtool automatically. Any spec files required should be placed in the /etc/kubernetes/manifests directory on the node.

<br />

<details><summary>show</summary><p>

#### Check the static pod path in the kubelet config file

```bash
ps -ef | grep kubelet
# root      2794     1  3 07:43 ?        00:01:05 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf

# Check the config file @ /var/lib/kubelet/config.yaml for the staticPodPath property
staticPodPath: /etc/kubernetes/manifests
```

#### Execute the below on node01

```yaml
mkdir /etc/kubernetes/manifests # create the static pod path, if it does not exist.

cat << EOF > webtool.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: webtool
  name: webtool
spec:
  containers:
  - image: httpd
    name: webtool
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
EOF

systemctl restart kubelet # if required
```

#### Check on controlpanel node 

```bash
kubectl get pods
# NAME             READY   STATUS    RESTARTS   AGE
# webtool-node01   1/1     Running   0          11s
```

</p></details>

<br />

## Init Containers

Refer [Init Containers](./init)

### Clean up 

<br />

```bash
rm nginx-labels.yaml nginx-file.yaml nginx_definition.yaml nginx-resources.yaml
kubectl delete pod mongo -n my-website --force --grace-period=0
kubectl delete pod cache -n web --force --grace-period=0
kubectl delete pod nginx -n alpha --force --grace-period=0
kubectl delete namespace alpha web my-website
```