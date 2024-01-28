# Managing Apps with Operators

Some applications need a lot of operational knowledge - not just the complexity of modelling the app in Kubernetes, but ongoing maintenance tasks. Think of a stateful application where you want to create backups of data. The application deployment is modelled in Kubernetes resources, and it would be great to model the operations in Kubernetes too.

That's what the [operator pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) does. It's a loose definition for an approach where you install an application which extends Kubernetes. So in that stateful application your operator would deploy the app, and it would also create a custom _DataBackup_ resource in the cluster. Any time you want to take a backup, you deploy a backup object, the operator sees the object and performs all the backup tasks.

> One of the problems with public operators is that you take a dependency on a third-party to maintain and update their deployments. The operators we use in this lab are good examples - they don't support ARM64 processors, so if you're using Apple Silicon then you won't be able to run all the exercises.

## Reference

- [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) - extending Kubernetes with your own object type
- [NATS Operator](https://github.com/nats-io/nats-operator) - a sample operator for deploying message queues
- [Bitpoke MySql Operator](https://github.com/bitpoke/mysql-operator#readme) - operator for managing MySql databases

## Custom Resources

Operators typically work by adding CustomResourceDefinitions (CRDs) to the cluster.

CRDs are pretty simple in themselved, you deploy an object which describes the schema of your new resource type:

- [student-crd.yaml](./specs/crd/student-crd.yaml) - defines a v1 _Student_ resource, with _email_ and _company_ fields; the rest of the spec tells Kubernetes to store objects in its database, and print out specific fields when objects are shown in Kubectl

You deploy CRDs in the usual way:

```
kubectl apply -f labs/operators/specs/crd
```

📋 List all the custom resource in the cluster, and print the details of the new Student CRD.

<details>
  <summary>Not sure how?</summary>

```
kubectl get crd

kubectl describe crd students
```

</details><br/>

> The CRD is just the object schema. Kubernetes only stores objects if it understands the type, which is what the CRD describes.

Now your Kubernetes cluster understands _Student_ resources, you can define them with YAML:

- [edwin.yaml](./specs/students/edwin.yaml) - describes a student who works at Microsoft
- [priti.yaml](./specs/students/priti.yaml) - a student who works at Google

📋 Create all the Students in the `labs/operators/specs/students` folder, list them and print the details for Priti.

<details>
  <summary>Not sure how?</summary>

These objects are standard YAML:

```
kubectl apply -f labs/operators/specs/students
```

And the resources can be accesses using the CRD name:

```
kubectl get students

kubectl describe student priti
```

</details><br/>

> If you try to apply this YAML in a cluster which doesn't have the Student CRD installed, you'll get an error.

The standard Kubectl verbs (get, delete, describe) work for all objects, including custom resources.

## NATS Operator

A CRD itself doesn't do anything, it just lets you store resources in the cluster. Operators typically install CRDs and also run _controllers_ in the cluster. A controller is just an app running in a Pod which connects to the Kubernetes API and watches for CRDs being created or updated. 

When you create a new custom resource, the controller see that and takes action - which could mean creating Deployment, Services and ConfigMaps, or running any custom code you need.

[NATS](https://nats.io) is a high-performance message queue which is very popular for asynchronous messaging in distributed apps. The NATS operator runs as a Deployment:

- [nats/operator/10-deployment.yaml](./specs/nats/operator/10-deployment.yaml) - runs a single operator Pod which installs some CRDs and runs the controller

Install the operator and look carefully at the output:

```
kubectl apply -f labs/operators/specs/nats/operator
```

> The operator installs some RBAC objects and the Deployment

📋 List the custom resource types in your cluster now. You'll see some NATS types - how did these get created?

<details>
  <summary>Not sure how?</summary>

```
kubectl get crd
```

Shows your custom _Student_ resource, and also _NatsCluster_ and _NatsServiceRole_ resources.

There's no YAML for these CRDs, so the NATS controller running in the Pod must have created them by using the Kubernetes API in code. 

You can confirm the RBAC setup gives the controller ServiceAccount permission to do that:

```
kubectl auth can-i create crds --as system:serviceaccount:default:nats-operator
```

</details><br/>

We can use a _NatsCluster_ object to create a clustered, highly-available message queue for applications to use:

- [msgq.yaml](./specs/nats/cluster/msgq.yaml) - defines a cluster with 3 NATS servers, running version 2.5

Create the cluster resource:

```
kubectl apply -f labs/operators/specs/nats/cluster
```

A single object gets created. 

📋 Print the details of your new message queue, and look at the other objects running in the default namespace. The operator logs will show how the Pods were created.

<details>
  <summary>Not sure how?</summary>

The output from the CRD doesn't show much:

```
kubectl get natscluster -o wide
```

But the operator has created Pods and Services:

```
kubectl get all --show-labels
```

Check the logs and you'll see the operator is managing the Pods - there's no Deployment or ReplicaSet for the message queue Pods:

```
kubectl logs -l name=nats-operator
```

</details><br/>

The NATS operator is unusual because it acts as a Pod controller. Typically operators build on top of Kubernetes resources, so they would use Deployments to manage Pods.

Print the details of one of the NATS Pods and you'll see it's managed by the operator:

```
kubectl describe po msgq-1
```

> You'll see _Controlled By:  NatsCluster/msgq_

📋 The NATS operator still provides high availability. Delete one of the message queue Pods and confirm it gets recreated.

<details>
  <summary>Not sure how?</summary>

```
kubectl delete po msgq-2

kubectl get po -l app=nats

kubectl logs -l name=nats-operator
```

You'll see a new Pod called `msgq-2` gets created, and the operator logs show it coming online.

</details><br/>

There's not much more you can do with the NATS operator, so we'll try one which has some more features.

## MySql Operator

There's a Helm chart for the [Presslabs MySql operator](https://www.presslabs.com/code/kubernetes/mysql-operator/) in this repository:

- [values.yaml](./specs/mysql/operator/values.yaml) - defines the default values for the operator; there is a lot you can tweak here

Install the operator (you'll need the [Helm CLI](https://helm.sh/docs/intro/install/) installed):

```
helm install mysql-operator labs/operators/specs/mysql/operator/

# the operator pod might restart and take a few minutes to be ready:
kubectl get po -l app.kubernetes.io/name=mysql-operator -w
```

📋 What resources do you need to create to deploy a MySql database cluster using the operator?

<details>
  <summary>Not sure?</summary>

The Helm output gives you an example of what you need:

- a _MysqlCluster_ object - this is a CRD installed by the operator

- a _Secret_ containing the admin user password for the database

</details><br/>

You can create a replicated database cluster using these specs:

- [mysql/database/01-secret.yaml](./specs/mysql/database/01-secret.yaml) - the database password

- [mysql/database/db.yaml](./specs/mysql/database/db.yaml) - the cluster set to use two MySql servers

Create the database:

```
kubectl apply -f labs/operators/specs/mysql/database
```

📋 The database Pods take a while to start up. What controller does the operator use, and what's the container configuration in the Pods?

<details>
  <summary>Not sure?</summary>

List the Pods and you'll see `db-mysql-0`. That name should suggest that it's managed by a StatefulSet:

```
kubectl get statefulset
```

Print the Pod details and you'll see multiple containers:

```
kubectl describe po db-mysql-0
```

The container setup is pretty complext:

- two init containers which look like they set up the database environment and the MySql configuration
- the main database container which runs MySql
- three sidecar containers which export database metrics, and perform a heartbeat check between the database servers


</details><br/>

Check the logs of the primary database server in Pod 0:

```
kubectl logs db-mysql-0 -c mysql
```

> You'll see _mysqld: ready for connections_ showing the database server is running successfully

And the logs of the secondary database server in Pod 1:

```
kubectl logs db-mysql-1 -c mysql
```

> You'll see _'replication@db-mysql-0.mysql.default:3306',replication started_ showing the secondary is replicating data from the primary.

The operator provides a production-grade deployment of MySql, and it also sets up a CRD for creating database backups and sending them to cloud storage.

## Lab

We'll make use of the operators to install infrastructure components for a demo app.

Start by deleting the existing message queue and database clusters:

```
kubectl delete natscluster,mysqlcluster --all
```

> The operators are watching for resources to be deleted, and will remove all the objects they created

Now deploy a simple to-do list application:

```
kubectl apply -f labs/operators/specs/todo-list
```

The app has a website listening on http://localhost:30028 which posts messages to a queue when you create a new to-do item. A message handler listens on the same queue and creates items in the database.

> Browse to the app now and you'll see an error - the components it needs don't exist yet

You'll need to create NatsCluster and MysqlCluster objects matching the config in the app to make everything work correctly.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

## Cleanup

Delete the basic objects and CRDs:

```
kubectl delete crd natsclusters.nats.io natsserviceroles.nats.io

kubectl delete all,cm,secret,crd -l kubernetes.courselabs.co=operators
```

> The order is important, deleting CRDs deletes custom resources - make sure the controller still exists to tidy up

Delete the NATS operator:

```
kubectl delete -f labs/operators/specs/nats/operator
```

Delete the MySql CRD and operator:

```
kubectl delete crd -l app.kubernetes.io/name=mysql-operator

helm uninstall mysql-operator
```