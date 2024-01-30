**Table of contents**
- What is a Replicaset?
- Which problem it solves?
- What is an object?
- What is a resource?
- The Anatomy of a ReplicaSet Manifest
- How to scale up/down?
  - Scaling down 
  - Scaling up 
- How to delete replicaset?
- How to delete replicaset without deleting pods

### What is a Replicaset?

A Replicaset simply means, it replicates pods, like you can have an n number of pods, 1 replica means it controls one pod, under the hood of a replica set the main important concept labels, let's see in detail what it is all about, and explore what exactly replicates means, use-cases and many more...

### which problem it solves?

It automatically replicates and it's making sure a certain number of pods run all the time as you mentioned in your manifest file.

Before we dive in we want to understand some terms

#### What is an object?

simply an object is a design model only we use for a specific purpose there are many objects in Kubernetes

#### What is a resource?

In simple terms, a resource is a collection of objects for that specific resource

- (pod) -> this is an object
- (pods) -> this is an endpoint, in this case, it stores the collection of pods

Let's see what are the different resources available, there is a command for this

`Note`: This resources are not constant there are maybe changed, remove,or added new resources for every new release

```s
kubectl api-resources 
``` 

```yaml
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
limitranges                       limits       v1                                     true         LimitRange
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1              false        APIService
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
tokenreviews                                   authentication.k8s.io/v1               false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
horizontalpodautoscalers          hpa          autoscaling/v2                         true         HorizontalPodAutoscaler
cronjobs                          cj           batch/v1                               true         CronJob
jobs                                           batch/v1                               true         Job
certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
leases                                         coordination.k8s.io/v1                 true         Lease
bgpconfigurations                              crd.projectcalico.org/v1               false        BGPConfiguration
bgppeers                                       crd.projectcalico.org/v1               false        BGPPeer
blockaffinities                                crd.projectcalico.org/v1               false        BlockAffinity
caliconodestatuses                             crd.projectcalico.org/v1               false        CalicoNodeStatus
clusterinformations                            crd.projectcalico.org/v1               false        ClusterInformation
felixconfigurations                            

```
These are some of the resources and types of objects you can see


- Now let's understand the replica set with an example 

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # modify replicas according to your case
  replicas: 4
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend  
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
```
  
#### The Anatomy of a ReplicaSet Manifest

Let's understand what is going inside (step by step)

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend

```
There are some resources you want to mention always in you're manifest file such as `apiVersion`, `kind`, `metadata`, `spec`, so you can ask what is a resource

`apiVersion`: this simply means which version of API version you're using to create the object

`kind`: This just means, what kind of object you're creating, in this case, it is Replicaset, plz note: what you're providing as an object because that is the desired state and that is what you're workload gonna be

`metadata`: this is a piece of additional information to identify you're workload, in this case, your workload is a replica set

- metadata.name(name: frontend) -> you object name in the cluster

- metadata.labels(labels app: guestbook tier: frontend) -> this is like a tag to the replicaset we can see details of the replicaset by using those labels

> labels are most important in Replicaset more info coming below


```yaml
spec:
  # modify replicas according to your case
  replicas: 4
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
```

` spec `: refers to specs of replicaset

` replicas `: how many pods want to be created by the replica set
 
` selector `: here selector is the thing, the replicaset takes it, and checks the same label to identify what are the pods it wants to control.

> you want to make sure (selector.matchLabels.tier: frontend)-> this tier: frontend taken as a reference by rs to check the pod == (template.metadata.labels.tier: frontend) -> this tag attached to each pod, this is must want to be same, then only rs knows what are the pods it wants to checkout.

` template `: above we mentioned 4 replicas which means the same number of pods are created by the replica set, when pods are created this is taken as reference by the replica set to create new pods 

> don't think replicaset means just creating replicas, that's not the main view, it replicates or re-create pods if anyone one of them dies, but how replicaset is identifying its designated pods

> just by matching the `selector.tier tag to the template.tier tag`

#### How to scale up/down?

There are 2 ways to scale up or scale down the pods, one is modifying the manifest another is just by giving a command:

#### Scaling down this is how you do it
 
```s
$ kubectl get rs
NAME       DESIRED   CURRENT   READY   AGE
frontend   4         4         4       19s
$ kubectl scale --replicas=2 rs frontend
replicaset.apps/frontend scaled
$ kubectl get rs
NAME       DESIRED   CURRENT   READY   AGE
frontend   2         2         2       23s

```
#### Scaling up this is how you do it
```s
$ kubectl get rs
NAME       DESIRED   CURRENT   READY   AGE
frontend   2         2         0       32s
$ kubectl scale --replicas=6 rs frontend
replicaset.apps/frontend scaled
$ kubectl get rs
NAME       DESIRED   CURRENT   READY   AGE
frontend   6         6         6       45s
```

#### How to delete replicaset?

```s
kubectl delete rs frontend
```


#### How to delete replicaset without deleting pods?

```s
kubectl delete rs frontend --cascade=orphan
```
