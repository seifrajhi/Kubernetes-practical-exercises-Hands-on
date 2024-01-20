Table of Contents
=================

   * [Labels and Selectors](#labels-and-selectors)
   * [Label selectors](#label-selectors)
      * [Equality-based requirement](#equality-based-requirement)
      * [Set-based requirement](#set-based-requirement)
   * [Deployments](#deployments)
      * [Strategy](#strategy)
         * [Recreate Deployment](#recreate-deployment)
         * [Rolling Update Deployment](#rolling-update-deployment)
   * [Updating a Deployment](#updating-a-deployment)
         * [Checking Rollout History of a Deployment](#checking-rollout-history-of-a-deployment)
         * [Rolling Back to a Previous Revision](#rolling-back-to-a-previous-revision)
   * [Replicasets](#replicasets)
   * [Service](#service)
   * [Namespace](#namespace)

## Labels and Selectors

Labels are key/value pairs that are attached to objects, such as pods.

Each object can have a set of key/value labels defined. Each Key must be unique for a given object.

```
"metadata": {
  "labels": {
    "key1" : "value1",
    "key2" : "value2"
  }
}

```
Example labels:

- "`release" : "stable"`, `"release" : "canary"`
- `"environment" : "dev"`, `"environment" : "qa"`, `"environment" : "production"`
- `"tier" : "frontend"`, `"tier" : "backend"`, `"tier" : "cache"`
- `"partition" : "customerA"`, `"partition" : "customerB"`
- `"track" : "daily"`, `"track" : "weekly"`

## Label selectors

- The API currently supports two types of selectors: **equality-based** and **set-based**.
- A label selector can be made of multiple **requirements** which are comma-separated. 
- In the case of multiple requirements, all must be satisfied so the comma separator acts as a logical AND (`&&`) operator.

### Equality-based requirement

_Equality_- or _inequality-based_ requirements allow filtering by label keys and values. 

Matching objects must satisfy all of the specified label constraints, though they may have additional labels as well.

Three kinds of operators are admitted `=`,`==`,`!=`. 

The first two represent _equality_ (and are synonyms), while the latter represents _inequality_.

For example:

```
environment = production
tier != frontend
```
The former selects all resources with key equal to `environment` and value equal to `production`. The latter selects all resources with key equal to `tier` and value distinct from `frontend`, and all resources with no labels with the `tier` key. One could filter for resources in production excluding `frontend` using the comma operator: `environment=production,tier!=frontend`


### Set-based requirement

_Set-based_ label requirements allow filtering keys according to a set of values. 

Three kinds of operators are supported: `in`,`notin` and `exists` (only the key identifier). 

For example:
```
environment in (production, qa)
tier notin (frontend, backend)
partition
!partition
```

- The first example selects all resources with key equal to `environment` and value equal to `production` or `qa`.


- The second example selects all resources with key equal to `tier` and values other than `frontend` and `backend`, and all resources with no labels with the tier key.


- The third example selects all resources including a label with key partition; no values are checked.


- The fourth example selects all resources without a label with key partition; no values are checked.


Similarly the comma separator acts as an _AND_ operator. 

So filtering resources with a `partition` key (no matter the value) and with `environment` different than  `qa` can be achieved using `partition,environment notin (qa)`.

The _set-based_ label selector is a general form of equality since `environment=production` is equivalent to `environment in (production)`; similarly for `!=` and `notin`.

Set-based requirements can be mixed with _equality-based_ requirements. For example:

`partition in (customerA, customerB),environment!=qa`.


Both label selector styles can be used to list or watch resources via a REST client. For example, targeting `apiserver` with kubectl and using `equality-based` one may write:

```
kubectl get pods -l environment=production,tier=frontend
```
or using set-based requirements:

```
kubectl get pods -l 'environment in (production),tier in (frontend)'
```

As already mentioned **set-based** requirements are more expressive.  For instance, they can implement the **OR** operator on values:

```
kubectl get pods -l 'environment in (production, qa)'
```

or restricting negative matching via exists operator:

```
kubectl get pods -l 'environment,environment notin (frontend)'
```

## Deployments

### Strategy

`.spec.strategy` specifies the strategy used to replace old Pods by new ones. `.spec.strategy.type` can be "Recreate" or "RollingUpdate". "RollingUpdate" is the default value.

#### Recreate Deployment

All existing Pods are killed before new ones are created when `.spec.strategy.type==Recreate`.

#### Rolling Update Deployment

Replaces pods running the old version of the application with the new version, one by one, without downtime to the cluster.

The Deployment updates Pods in a rolling update fashion when `.spec.strategy.type==RollingUpdate`.

## Updating a Deployment

Follow the steps given below to update your Deployment:

Let's update the nginx Pods to use the `nginx:1.16.1` image instead of the `nginx:1.14.2` image.

```
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1
```

or use the following command:

```
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
```

The output is similar to:

```
deployment.apps/nginx-deployment image updated
```

Alternatively, you can `edit` the Deployment and change `.spec.template.spec.containers[0].image` from `nginx:1.14.2` to `nginx:1.16.1`:

```
kubectl edit deployment/nginx-deployment
```

The output is similar to:

```
deployment.apps/nginx-deployment edited
```

To see the rollout status, run:

```
kubectl rollout status deployment/nginx-deployment
```

The output is similar to this:

```
Waiting for rollout to finish: 2 out of 3 new replicas have been updated...
```

or

```
deployment "nginx-deployment" successfully rolled out
```

Get more details on your updated Deployment:

After the rollout succeeds, you can view the Deployment by running 

```
kubectl get deployments
```

The output is similar to this:
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           36s
```

Run `kubectl get rs` to see that the Deployment updated the Pods by creating a new ReplicaSet and scaling it up to 3 replicas, as well as scaling down the old ReplicaSet to 0 replicas.

kubectl get rs
The output is similar to this:

```
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-1564180365   3         3         3       6s
nginx-deployment-2035384211   0         0         0       36s
```

Running get pods should now show only the new Pods:

```
kubectl get pods
```

The output is similar to this:

```
NAME                                READY     STATUS    RESTARTS   AGE
nginx-deployment-1564180365-khku8   1/1       Running   0          14s
nginx-deployment-1564180365-nacti   1/1       Running   0          14s
nginx-deployment-1564180365-z9gth   1/1       Running   0          14s
```

Next time you want to update these Pods, you only need to update the Deployment's Pod template again.


Get details of your Deployment:

```
kubectl describe deployments
```

#### Checking Rollout History of a Deployment

Sometimes, you may want to rollback a Deployment; for example, when the Deployment is not stable, such as crash looping.

By default, all of the Deployment's rollout history is kept in the system so that you can rollback anytime you want (you can change that by modifying revision history limit).

First, check the revisions of this Deployment:

```
kubectl rollout history deployment/nginx-deployment
```

To see the details of each revision, run:

```
kubectl rollout history deployment/nginx-deployment --revision=2
```

#### Rolling Back to a Previous Revision

Now you've decided to undo the current rollout and rollback to the previous revision:

```
kubectl rollout undo deployment/nginx-deployment
```

Alternatively, you can rollback to a specific revision by specifying it with `--to-revision`:

```
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

## Replicasets

A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. 

As such, it is often used to guarantee the availability of a specified number of identical Pods.

Directly update the replicas field in the live configuration by using kubectl scale. This does not use kubectl apply:

```
kubectl scale deployment/nginx-deployment --replicas=2
```

Print the live configuration using kubectl get:

```
kubectl get deployment nginx-deployment -o yaml
```

The output shows that the replicas field has been set to 2.

It is recommended using Deployments instead of directly using ReplicaSets, unless you require custom update orchestration or don't require updates at all.

This actually means that you may never need to manipulate ReplicaSet objects: use a Deployment instead, and define your application in the spec section.

```
kubectl apply -f frontend.yaml
```

You can then get the current ReplicaSets deployed:
```
kubectl get rs
```

To check on the state of the ReplicaSet:

```
kubectl describe rs/frontend
```

To check for the Pods brought up:

```
kubectl get pods
```

## Service

An abstract way to expose an application running on a set of Pods as a network service.

Kubernetes ServiceTypes allow you to specify what kind of Service you want. The default is ClusterIP.

Type values and their behaviors are:

- `ClusterIP`: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default `ServiceType`.
  
- `NodePort`: Exposes the Service on each Node's IP at a static port (the `NodePort`). A `ClusterIP` Service, to which the `NodePort` Service routes, is automatically created. You'll be able to contact the `NodePort` Service, from outside the cluster, by requesting <NodeIP>:<NodePort>.

- `LoadBalancer`: Exposes the Service externally using a cloud provider's load balancer. `NodePort` and `ClusterIP` Services, to which the external load balancer routes, are automatically created.

- `ExternalName`: Maps the Service to the contents of the `externalName` field (e.g. `foo.bar.example.com`), by returning a `CNAME` record with its value. No proxying of any kind is set up.


## Namespace

In Kubernetes, _namespaces_ provides a mechanism for isolating groups of resources within a single cluster.

Names of resources need to be unique within a namespace, but not across namespaces. 

Namespace-based scoping is applicable only for namespaced objects _(e.g. Deployments, Services, etc)_ and not for cluster-wide objects _(e.g. StorageClass, Nodes, PersistentVolumes, etc)_.

```
kubectl create namespace yellow
```
```
kubectl create namespace blue
```

```
kubectl create namespace red
```

```
kubectl create namespace white
```

To count the namespaces use below command:

```
kubectl get namespaces --no-headers | wc -l
```

To find the nginx pod from all the namespaces:

```
kubectl get pods --all-namespaces | grep nginx
``` 

Below command will show you the yellow namespace service:

```
kubectl --namespaces yellow get svc
```

Reference link: [Namespace Concepts](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)