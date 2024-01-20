Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [Init Containers](#init-containers)
  - [Understanding init containers](#understanding-init-containers)
      - [Init containers in use](#init-containers-in-use)
    - [Pod restart reasons](#pod-restart-reasons)
- [Debug Init Containers](#debug-init-containers)
  - [Checking the status of Init Containers](#checking-the-status-of-init-containers)
  - [Getting details about Init Containers](#getting-details-about-init-containers)
  - [Accessing logs from Init Containers](#accessing-logs-from-init-containers)
  - [Understanding Pod status](#understanding-pod-status)


# Init Containers

An overview of init containers: specialized containers that run before app containers in a Pod. 

Init containers can contain utilities or setup scripts not present in an app image.

You can specify init containers in the Pod specification alongside the `containers` array (which describes app containers).

## Understanding init containers

A Pod can have multiple containers running apps within it, but it can also have one or more init containers, which are run before the app containers are started.

Init containers are exactly like regular containers, except:

-   Init containers always run to completion.

-   Each init container must complete successfully before the next one starts.

If a Pod's init container fails, the kubelet repeatedly restarts that init container until it succeeds. 

However, if the Pod has a `restartPolicy` of Never, and an init container fails during startup of that Pod, Kubernetes treats the overall Pod as failed.


#### Init containers in use

This example defines a simple Pod that has two init containers. 

The first waits for `myservice`, and the second waits for `mydb`. 

Once both init containers complete, the Pod runs the app container from its `spec` section.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app.kubernetes.io/name: MyApp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
```

You can start this Pod by running:

```shell
kubectl apply -f myapp.yaml
```

The output is similar to this:

```
pod/myapp-pod created
```

And check on its status with:

```shell
kubectl get -f myapp.yaml
```

The output is similar to this:

```
NAME        READY     STATUS     RESTARTS   AGE
myapp-pod   0/1       Init:0/2   0          6m
```

or for more details:

```shell
kubectl describe -f myapp.yaml
```

The output is similar to this:

```
Name:         myapp-pod
Namespace:    default
Priority:     0
Node:         rke2-training-node3/84.200.100.249
Start Time:   Tue, 04 Oct 2022 15:57:02 +0530
Labels:       app.kubernetes.io/name=MyApp
Annotations:  cni.projectcalico.org/containerID: 6a0f698417e23f6852018d132aa4a1678fa4831985724c2132d58ddb67169dab
              cni.projectcalico.org/podIP: 10.42.2.53/32
              cni.projectcalico.org/podIPs: 10.42.2.53/32
              kubernetes.io/psp: global-unrestricted-psp
Status:       Pending
IP:           10.42.2.53
IPs:
  IP:  10.42.2.53
Init Containers:
  init-myservice:
    Container ID:  containerd://a9ed26b3f20ab875b4b0a17e7865126e284203be06355b4cc35f5c6ec05627a4
    Image:         busybox:1.28
    Image ID:      docker.io/library/busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done
    State:          Running
      Started:      Tue, 04 Oct 2022 15:57:05 +0530
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9hxd6 (ro)
  init-mydb:
    Container ID:
    Image:         busybox:1.28
    Image ID:
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done
    State:          Waiting
      Reason:       PodInitializing
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9hxd6 (ro)
Containers:
  myapp-container:
    Container ID:
    Image:         busybox:1.28
    Image ID:
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      echo The app is running! && sleep 3600
    State:          Waiting
      Reason:       PodInitializing
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9hxd6 (ro)
Conditions:
  Type              Status
  Initialized       False
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  kube-api-access-9hxd6:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  7s    default-scheduler  Successfully assigned test-ns/myapp-pod to rke2-training-node3
  Normal  Pulling    6s    kubelet            Pulling image "busybox:1.28"
  Normal  Pulled     4s    kubelet            Successfully pulled image "busybox:1.28" in 2.713504721s
  Normal  Created    4s    kubelet            Created container init-myservice
  Normal  Started    4s    kubelet            Started container init-myservice
```

To see logs for the init containers in this Pod, run:

```shell
kubectl logs myapp-pod -c init-myservice # Inspect the first init container
kubectl logs myapp-pod -c init-mydb      # Inspect the second init container
```

At this point, those init containers will be waiting to discover Services named `mydb` and `myservice`.

Here's a configuration you can use to make those Services appear:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
---
apiVersion: v1
kind: Service
metadata:
  name: mydb
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9377
```

To create the `mydb` and `myservice` services:

```shell
kubectl apply -f services.yaml
```

The output is similar to this:

```
service/myservice created
service/mydb created
```

You'll then see that those init containers complete, and that the `myapp-pod` Pod moves into the Running state:

```shell
kubectl get -f myapp.yaml
```

The output is similar to this:

```
NAME        READY     STATUS    RESTARTS   AGE
myapp-pod   1/1       Running   0          9m
```

### Pod restart reasons

A Pod can restart, causing re-execution of init containers, for the following reasons:

-   The Pod infrastructure container is restarted. This is uncommon and would have to be done by someone with root access to nodes.
-   All containers in a Pod are terminated while `restartPolicy` is set to Always, forcing a restart, and the init container completion record has been lost due to garbage collection.

The Pod will not be restarted when the init container image is changed, or the init container completion record has been lost due to garbage collection. This applies for Kubernetes v1.20 and later.


# Debug Init Containers

How to investigate problems related to the execution of Init Containers. 

The example command lines below refer to the Pod as `<pod-name>` and the Init Containers as `<init-container-1>` and `<init-container-2>`.

## Checking the status of Init Containers

Display the status of your pod:

```shell
kubectl get pod <pod-name>
```

For example, a status of `Init:1/2` indicates that one of two Init Containers has completed successfully:

```
NAME         READY     STATUS     RESTARTS   AGE
<pod-name>   0/1       Init:1/2   0          7s
```


## Getting details about Init Containers

View more detailed information about Init Container execution:

```shell
kubectl describe pod <pod-name>
```

For example, a Pod with two Init Containers might show the following:

```
Init Containers:
  <init-container-1>:
    Container ID:    ...
    ...
    State:           Terminated
      Reason:        Completed
      Exit Code:     0
      Started:       ...
      Finished:      ...
    Ready:           True
    Restart Count:   0
    ...
  <init-container-2>:
    Container ID:    ...
    ...
    State:           Waiting
      Reason:        CrashLoopBackOff
    Last State:      Terminated
      Reason:        Error
      Exit Code:     1
      Started:       ...
      Finished:      ...
    Ready:           False
    Restart Count:   3
    ...
```

You can also access the Init Container statuses programmatically by reading the `status.initContainerStatuses` field on the Pod Spec:

```shell
kubectl get pod nginx --template '{{.status.initContainerStatuses}}'
```

Or

You can gather a list of pod names and their pod status condition for programmatic access, which has a type of Initialized with the following JSONPath expression.

```
kubectl get pods -o=jsonpath='{"Pod Name, Condition Initialized"}{"\n"}{range .items[*]}{.metadata.name},{@.status.conditions[?(@.type=="Initialized")].status}{"\n"}{end}'

```

This command will return the same information as above in raw JSON.

## Accessing logs from Init Containers

Pass the Init Container name along with the Pod name to access its logs.

```shell
kubectl logs <pod-name> -c <init-container-2>
```


## Understanding Pod status

A Pod status beginning with `Init:` summarizes the status of Init Container execution. The table below describes some example status values that you might see while debugging Init Containers.

|Status| Meaning|
|------|-----------|
|`Init:N/M`|The Pod has `M` Init Containers, and `N` have completed so far.|
|`Init:Error`|An Init Container has failed to execute.|
|`Init:CrashLoopBackOff`|An Init Container has failed repeatedly.|
|`Pending`|The Pod has not yet begun executing Init Containers.|
|`PodInitializing` or `Running`|The Pod has already finished executing Init Containers.|



Reference links:
-  [Kubernetes Documentation/Concepts - Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Kubernetes Documentation/ Debug Init containers](https://kubernetes.io/docs/tasks/debug/debug-application/debug-init-containers/)
- [Deep Dive Into Kubernetes Init Containers](https://loft.sh/blog/kubernetes-init-containers/)