<div align=center>
  
# Understanding Kubernetes Namespaces 

![Jenkins (1)](https://user-images.githubusercontent.com/58173938/197653210-f386b305-888c-42bf-9536-4614b94a67d9.png)

</div>  
  
Kubernetes namespaces allow us to create a logical partition of a physical 
cluster based on an organization's needs. For example, you can choose to create 
namespaces such as Dev, UAT, Production, etc., or 

you can create namespaces based on the name of the teams working in the cluster. The possibilities are endless.

When a cluster is setup, Kubernetes creates a number of namespaces. To view the namespaces, type below.

``` yaml
kubectl Get namespaces
``` 

Default: This is the default namespace for objects when no other namespace is provided.

kube-system: This namespace is used for objects created by the Kubernetes system. 
It contains information related to cluster management and should generally be left alone.

kube-public: Public namespace available to everyone with access to the Kubernetes cluster 
(including unauthenticated ones).

kube-node-lease: This namespace for lease objects associated with each node improves the 
performance of node heartbeats as the cluster scales and isolates again.

All the operations we have done so far are taking place in the default namespace.

So, let's create our first namespace using the yaml file below.
``` yaml
apiVersion: v1
Type: namespace
Metadata:
  Name: Product
  Labels:
    Name: Product
``` 
To create a namespace, type the following command.

``` yaml
kubectl create -f namespace-definition.yaml
``` 

Kubernetes Namespaces

Next, let's create a new pod in the production namespace. 
We can reuse the pod-definition.yaml file we used in the Pods and Pod Lifecycle post.

```yaml
apiVersion: v1
Type: Pod
Metadata:
  Labels:
    App: First Product-Pod
  Name: First Product-Pod
  Namespace: product
Specification:
  Containers:
  - Image: nginx
    Name: nginx
```

Note that the only difference we have now is that we've 
added a Namespace field under the Metadata section.

Let's create this pod using the following command.
``` yaml
kubectl create -f pod-definition.yaml
``` 
Let's check if the pod exists now using the command.
``` yaml
Get kubectl pods
``` 
No it isn't. The kubectl get pods command looks for pods in the default namespace.

To get pods in prodnamespace we need to run below command.
``` yaml
kubectl pods -n gets the output
``` 
Kubernetes Namespaces

We can also run the command below to list all pods under all namespaces.
``` yaml
kubectl get pods --all-namespaces
``` 
Experiment with above config files, that will give what actually going on with this things,
its really fun checkout
