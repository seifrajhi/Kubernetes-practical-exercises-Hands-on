Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [Resource Management for Pods and Containers](#resource-management-for-pods-and-containers)
  - [Units of measures](#units-of-measures)
  - [Requests and limits](#requests-and-limits)
  - [Resource requests and limits of Pod and container](#resource-requests-and-limits-of-pod-and-container)
  - [Container resources example](#container-resources-example)
  - [Specify a memory request and a memory limit](#specify-a-memory-request-and-a-memory-limit)


# Resource Management for Pods and Containers

When you specify a Pod, you can optionally specify how much of each resource a container needs. 

The most common resources to specify are CPU and memory (RAM).

When you specify the resource _request_ for containers in a Pod, the kube-scheduler uses this information to decide which node to place the Pod on. 

When you specify a resource _limit_ for a container, the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit you set. 

The kubelet also reserves at least the _request_ amount of that system resource specifically for that container to use.

## Units of measures

![units of measures](/images/unitsofmeasures.png)

## Requests and limits

If the node where a Pod is running has enough of a resource available, it's possible (and allowed) for a container to use more resource than its `request` for that resource specifies. 

However, a container is not allowed to use more than its resource `limit`.

For example, if you set a `memory` request of 256 MiB for a container, and that container is in a Pod scheduled to a Node with 8GiB of memory and no other Pods, then the container can try to use more RAM.

If you set a `memory` limit of 4GiB for that container, the kubelet (and container runtime enforce the limit. The runtime prevents the container from using more than the configured resource limit.

For example: when a process in the container tries to consume more than the allowed amount of memory, the system kernel terminates the process that attempted the allocation, with an out of memory (OOM) error.

Limits can be implemented either reactively (the system intervenes once it sees a violation) or by enforcement (the system prevents the container from ever exceeding the limit). Different runtime can have different ways to implement the same restrictions.


## Resource requests and limits of Pod and container

For each container, you can specify resource limits and requests, including the following:

-   `spec.containers[].resources.limits.cpu`
-   `spec.containers[].resources.limits.memory`
-   `spec.containers[].resources.requests.cpu`
-   `spec.containers[].resources.requests.memory`

Although you can only specify requests and limits for individual containers, it is also useful to think about the overall resource requests and limits for a Pod. 

For a particular resource, a _Pod resource request/limit_ is the sum of the resource requests/limits of that type for each container in the Pod.


## Container resources example

The following Pod has two containers. Both containers are defined with a request for 0.25 CPU and 64MiB (226 bytes) of memory. 

Each container has a limit of 0.5 CPU and 128MiB of memory. You can say the Pod has a request of 0.5 CPU and 128 MiB of memory, and a limit of 1 CPU and 256MiB of memory.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: log-aggregator
    image: images.my-company.example/log-aggregator:v6
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```


## Specify a memory request and a memory limit

To specify a memory request for a Container, include the `resources:requests` field in the Container's resource manifest. To specify a memory limit, include `resources:limits`.

In this exercise, you create a Pod that has one Container. The Container has a memory request of 100 MiB and a memory limit of 200 MiB. Here's the configuration file for the Pod:


```yaml
#memory-request-limit.yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo
  namespace: test-ns
spec:
  containers:
  - name: memory-demo-ctr
    image: polinux/stress
    resources:
      requests:
        memory: "100Mi"
      limits:
        memory: "200Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
```

he `args` section in the configuration file provides arguments for the Container when it starts. The `"--vm-bytes", "150M"` arguments tell the Container to attempt to allocate 150 MiB of memory.

Create the Pod:

```shell
kubectl apply -f memory-request-limit.yaml --namespace=test-ns
```

Verify that the Pod Container is running:

```shell
kubectl get pod memory-demo --namespace=test-ns
```

View detailed information about the Pod:

```shell
kubectl get pod memory-demo --output=yaml --namespace=test-ns
```

The output shows that the one Container in the Pod has a memory request of 100 MiB and a memory limit of 200 MiB.

```yaml
...
resources:
  requests:
    memory: 100Mi
  limits:
    memory: 200Mi
...
```

Run `kubectl top` to fetch the metrics for the pod:

```shell
kubectl top pod memory-demo --namespace=test-ns
```

The output shows that the Pod is using about 162,900,000 bytes of memory, which is about 150 MiB. This is greater than the Pod's 100 MiB request, but within the Pod's 200 MiB limit.

```
NAME                        CPU(cores)   MEMORY(bytes)
memory-demo                 <something>  162856960
```

Delete your Pod:

```shell
kubectl delete pod memory-demo --namespace=test-ns
```

Reference link for further examples: https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/