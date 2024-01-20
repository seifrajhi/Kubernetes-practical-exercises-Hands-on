Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [Affinity and anti-affinity](#affinity-and-anti-affinity)
- [Node affinity](#node-affinity)
- [Example: Assign Pods to Nodes using Node Affinity](#example-assign-pods-to-nodes-using-node-affinity)
  - [Add a label to a node](#add-a-label-to-a-node)
  - [Schedule a Pod using required node affinity](#schedule-a-pod-using-required-node-affinity)
  - [Schedule a Pod using preferred node affinity](#schedule-a-pod-using-preferred-node-affinity)
  - [Pod Affinity and Anti-Affinity Demo](#pod-affinity-and-anti-affinity-demo)
  - [Conclusion](#conclusion)
  - [nodeName](#nodename)
  - [nodeSelector](#nodeselector)
  - [Add a label to a node demo](#add-a-label-to-a-node-demo)
  - [Create a pod that gets scheduled to your chosen node](#create-a-pod-that-gets-scheduled-to-your-chosen-node)
  - [Create a pod that gets scheduled to specific node](#create-a-pod-that-gets-scheduled-to-specific-node)


# Affinity and anti-affinity

Affinity and anti-affinity expands the types of constraints you can define.Some of the benefits of affinity and anti-affinity include:

- The affinity/anti-affinity language is more expressive. Affinity/anti-affinity gives you more control over the selection logic.

- You can indicate that a rule is soft or preferred, so that the scheduler still schedules the Pod even if it can't find a matching node.

- You can constrain a Pod using labels on other Pods running on the node (or other topological domain), instead of just node labels, which allows you to define rules for which Pods can be co-located on a node.


The affinity feature consists of two types of affinity:

- Node _affinity_ functions like the `nodeSelector` field but is more expressive and allows you to specify soft rules.
Inter-pod _affinity/anti-affinity_ allows you to constrain Pods against labels on other Pods.

# Node affinity

Node affinity is conceptually similar to `nodeSelector`, allowing you to constrain which nodes your Pod can be scheduled on based on node labels. There are two types of node affinity:

- `requiredDuringSchedulingIgnoredDuringExecution`: The scheduler can't schedule the Pod unless the rule is met. This functions like nodeSelector, but with a more expressive syntax.

- `preferredDuringSchedulingIgnoredDuringExecution`: The scheduler tries to find a node that meets the rule. If a matching node is not available, the scheduler still schedules the Pod.

![pod-with-node-affinity.png](/images/pod-with-node-affinity.png)

In this example, the following rules apply:

- The node must have a label with the key `topology.kubernetes.io/zone` and the value of that label must be either `antarctica-east1` or `antarctica-west1`.

- The node preferably has a label with the key `another-node-label-key` and the value `another-node-label-value`.
  
- You can use the `operator` field to specify a logical operator for Kubernetes to use when interpreting the rules. You can use following:

    - In
    - NotIn
    - Exists
    - DoesNotExist
    - Gt
    - Lt

- `NotIn` and `DoesNotExist` allow you to define node anti-affinity behavior.

# Example: Assign Pods to Nodes using Node Affinity

## Add a label to a node

1.  List the nodes in your cluster, along with their labels:
    
    ```
    kubectl get nodes --show-labels
    ```
    
    The output is similar to this:
    
    ```
    NAME      STATUS    ROLES    AGE     VERSION        LABELS
    worker0   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker0
    worker1   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker1
    worker2   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker2
    ```
    
2.  Choose one of your nodes, and add a label to it:
    
    ```
    kubectl label nodes <your-node-name> disktype=ssd
    ```
    
    where `<your-node-name>` is the name of your chosen node.
    
3.  Verify that your chosen node has a `disktype=ssd` label:
    
    ```
    kubectl get nodes --show-labels
    ```
    
    The output is similar to this:
    
    ```
    NAME      STATUS    ROLES    AGE     VERSION        LABELS
    worker0   Ready     <none>   1d      v1.13.0        ...,disktype=ssd,kubernetes.io/hostname=worker0
    worker1   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker1
    worker2   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker2
    ```
    
    In the preceding output, you can see that the `worker0` node has a `disktype=ssd` label.
    

## Schedule a Pod using required node affinity

This manifest describes a Pod that has a `requiredDuringSchedulingIgnoredDuringExecution` node affinity,`disktype: ssd`. This means that the pod will get scheduled only on a node that has a `disktype=ssd` label.

Please refer below `pod-nginx-required-affinity.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd            
  containers:
  - name: nginx
    image: nginx
```

1.  Apply the manifest to create a Pod that is scheduled onto your chosen node:
    
    ```
    kubectl apply -f pod-nginx-required-affinity.yaml
    ```
    
2.  Verify that the pod is running on your chosen node:
    
    ```
    kubectl get pods --output=wide
    ```
    
    The output is similar to this:
    
    ```
    NAME     READY     STATUS    RESTARTS   AGE    IP           NODE
    nginx    1/1       Running   0          13s    10.200.0.4   worker0
    ```
    

## Schedule a Pod using preferred node affinity

This manifest describes a Pod that has a `preferredDuringSchedulingIgnoredDuringExecution` node affinity,`disktype: ssd`. This means that the pod will prefer a node that has a `disktype=ssd` label.

Please refer below `pod-nginx-preferred-affinity.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd          
  containers:
  - name: nginx
    image: nginx
```

1.  Apply the manifest to create a Pod that is scheduled onto your chosen node:
    
    ```
    kubectl apply -f pod-nginx-preferred-affinity.yaml
    ```
    
2.  Verify that the pod is running on your chosen node:
    
    ```shll
    kubectl get pods --output=wide
    ```
    
    The output is similar to this:
    
    ```
    NAME     READY     STATUS    RESTARTS   AGE    IP           NODE
    nginx    1/1       Running   0          13s    10.200.0.4   worker0
    ```


## Pod Affinity and Anti-Affinity Demo

Let's assume we have a Redis cache for web applications and we need to run three replicas of Redis but we need to make sure that each replica runs on a different node, we make use of pod anti-affinity here.

Redis deployment with pod anti-affinity rule, so that each replica lands on a different node:

Please refer below `redis.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
spec:
  selector:
    matchLabels:
      app: store
  replicas: 3
  template:
    metadata:
      labels:
        app: store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis-server
        image: redis:3.2-alpine
```


Create the deployment using the yaml file above:

```
kubectl create -f redis.yaml 
```

Check the deployment status:

```
kubectl get deploy
```

Check if each pod is running on different node:

```
kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name                    
```

We noticed that each pod is running on a different node.

Next, let’s assume we have a web server running and we need to make sure that each web server pod co-locates with each Redis cache pod, but at the same time, we need to make sure two web server pods don’t run on the same node, for this to happen we make use of pod affinity and pod anti-affinity both as below.

Create the deployment file with affinity and anti-affinity rules:

Please refer below `web-server.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
spec:
  selector:
    matchLabels:
      app: web-store
  replicas: 3
  template:
    metadata:
      labels:
        app: web-store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        image: nginx:1.16-alpine
                 
```

Create the deployment:

```
kubectl create -f web-server.yaml 
```

List the pods along with nodes and check that they are placed as required by rules:

```
kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name  
```

We noticed that each web pod is co-located with a redis pod, and no two web pods are running on the same node; this was done by using pod affinity and anti-affinity rules.

## Conclusion

Affinity and anti-affinity provide flexible ways to schedule pods on nodes or place pods relative to other pods. You can use affinity rules to optimize the pod placement on worker nodes for performance, fault tolerance, or other complex scheduling requirements.

## nodeName

`nodeName` is a more direct form of node selection than affinity or `nodeSelector`. 

`nodeName` is a field in the Pod spec. If the `nodeName` field is not empty, the scheduler ignores the Pod and the kubelet on the named node tries to place the Pod on that node. 

Using `nodeName` overrules using `nodeSelector` or affinity and anti-affinity rules.

Some of the limitations of using `nodeName` to select nodes are:

-   If the named node does not exist, the Pod will not run, and in some cases may be automatically deleted.

-   If the named node does not have the resources to accommodate the Pod, the Pod will fail and its reason will indicate why, for example OutOfmemory or OutOfcpu.

-   Node names in cloud environments are not always predictable or stable.

Here is an example of a Pod spec using the `nodeName` field:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
  nodeName: kube-01
```

The above Pod will only run on the node `kube-01`.

## nodeSelector

`nodeSelector` is the simplest recommended form of node selection constraint. 

You can add the `nodeSelector` field to your Pod specification and specify the node labels you want the target node to have. Kubernetes only schedules the Pod onto nodes that have each of the labels you specify.

## Add a label to a node demo

1.  List the nodes in your cluster, along with their labels:

```
kubectl get nodes --show-labels
```

   
2.  Choose one of your nodes, and add a label to it:
    
    ```shell
    kubectl label nodes <your-node-name> disktype=ssd
    ```
    
    where `<your-node-name>` is the name of your chosen node.
    
3.  Verify that your chosen node has a `disktype=ssd` label:
    
    ```shell
    kubectl get nodes --show-labels
    ```
    
    The output is similar to this:
    
    ```shell
    NAME      STATUS    ROLES    AGE     VERSION        LABELS
    worker0   Ready     <none>   1d      v1.13.0        ...,disktype=ssd,kubernetes.io/hostname=worker0
    worker1   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker1
    worker2   Ready     <none>   1d      v1.13.0        ...,kubernetes.io/hostname=worker2
    ```
    
    In the preceding output, you can see that the `worker0` node has a `disktype=ssd` label.
    

## Create a pod that gets scheduled to your chosen node[](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-your-chosen-node)

This pod configuration file describes a pod that has a node selector, `disktype: ssd`. This means that the pod will get scheduled on a node that has a `disktype=ssd` label.

Please refer below `pod-nginx.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```

1.  Use the configuration file to create a pod that will get scheduled on your chosen node:

```
kubectl apply -f pod-nginx.yaml
```

2.  Verify that the pod is running on your chosen node:

```
kubectl get pods --output=wide
```

## Create a pod that gets scheduled to specific node

You can also schedule a pod to one specific node via setting `nodeName`.

Please refer below `pod-nginx-specific-node.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  nodeName: foo-node # schedule pod to specific node
  containers:
  - name: nginx
    image: nginx
```

Use the configuration file to create a pod that will get scheduled on `foo-node` only.