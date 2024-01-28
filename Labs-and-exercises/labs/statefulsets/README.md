# Modelling Stability with StatefulSets

Kubernetes is a dynamic platform where objects are usually created in parallel and with random names. That's what happens with Pods when you create a Deployment, and it's a pattern which scales well.

But some apps need a stable environment, where objects are created in a known order with fixed names. Think of a replicated system like a message queue or a database - there's often a primary node and multiple secondaries. The secondaries depend on the primary starting first and they need to know how to find it so they can sync data. That's where you use a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/).

StatefulSets are Pod controllers which can create multiple replicas in a stable environment. Replicas have known names, start consecutively and are individually addressable within the cluster.

## API specs

- [StatefulSet (apps/v1)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#statefulset-v1-apps)

<details>
  <summary>YAML overview</summary>

The spec is similar to Deployments - metadata, a selector and a template for the Pod spec - but with one important addition:

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: simple-statefulset
spec:
  selector:
    matchLabels:
      app: simple-statefulset
  serviceName: simple-statefulset
  replicas: 3
  template:
    # Pod spec
```

* `selector` - labels to identify Pods owned by the StatefulSet
* `replicas` - number of Pods, which will be managed in-order
* `serviceName` - name of a Service which provides network access to Pods

Services are decoupled from other Pod controllers, but a Service is **required** for each StatefulSet. The Service uses a special setup with no ClusterIP:

```
apiVersion: v1
kind: Service
metadata:
  name: simple-statefulset
spec:
  ports:
    - port: 8010
      targetPort: 80
  selector:
    app: simple-statefulset
  clusterIP: None
```

* `selector` - matches the Pod labels
* `clusterIP` - using `None` is required for StatefulSets

The StatefulSet has a link to the Service because it manages the Service endpoints. Each Pod has its IP address added to the Service **and** a separate DNS name is created for each Pod.

</details><br/>

## Deploy a simple StatefulSet

We'll start with a simple(ish) example that runs multiple Nginx Pods. This app doesn't need to use a StatefulSet, but it shows the pattern without getting too complex:

- [simple/services.yaml](specs/simple/services.yaml) - the headless Service and external Services to access the app
- [simple/configmap-scripts.yaml](specs/simple/configmap-scripts.yaml) - ConfigMap with shell scripts the app uses for initialization
- [simple/statefulset.yaml](specs/simple/statefulset.yaml) - StatefulSet which uses the headless Service and the scripts; init containers ensure the secondaries don't start until the primary is ready, and then create the HTML to serve

<details>
  <summary>ℹ We're modelling a stable startup workflow.</summary>

* Pod 0 starts, the first script runs confirming this Pod is the primary, then the second script runs and creates the HTML; then the app container runs, ready to serve the page
* Pod 1 starts, the first script runs and checks the DNS entry for Pod 0 - if it doesn't exist, then the primary isn't ready so the script waits. When the primary comes online, the next script writes HTML and the app starts.
* Pod 2 starts - same process as Pod 1.

</details><br/>

Let's see it in action:

```
kubectl apply -f labs/statefulsets/specs/simple

kubectl get po -l app=simple-statefulset --watch
```

> You'll see two differences from a Deployment - the Pods don't have random names, and each Pod is only created when the previous Pod has started

📋 Check the logs for the `wait-service` container in each of the Pods.

<details>
  <summary>Not sure how?</summary>

In Pods with multiple containers, you can view the logs for specific containers with the `-c` flag. These logs will show the startup workflow:

```
kubectl logs simple-statefulset-0 -c wait-service

kubectl logs simple-statefulset-1 -c wait-service
```

> Pod-0 knows it is the primary, because its has the expected `-0` hostname; Pod 1 knows it is a secondary because it doesn't have that hostname

</details><br/>

When they're running these are normal Pods, the StatefulSet just manages creating them differently than a Deployment.

## Communication with StatefulSet Pods

StatefulSets add their Pod IP addresses to the Service.

📋 Check all the Pods are registered with the Service.

<details>
  <summary>Not sure how?</summary>

```
kubectl get endpoints simple-statefulset
```

</details><br/>

There's one Service with 3 Pod IP addresses, but those Pods can also be  reached using individual domain names.

📋 Run a sleep Pod from `labs/statefulsets/specs/sleep-pod.yaml` and do a DNS lookup for `simple-statefulset` and `simple-statefulset-2.simple-statefulset.default.svc.cluster.local`.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/statefulsets/specs/sleep-pod.yaml

kubectl exec sleep -- nslookup simple-statefulset

kubectl exec sleep -- nslookup simple-statefulset-2.simple-statefulset.default.svc.cluster.local
```

</details><br/>

> The internal Service returns all Pod IPs, but each Pod also has its own DNS entry using the name of the Pod `-0`, `-1` etc.

This app has LoadBalancer and NodePort Services with the same Pod selector. These make the app available externally and they load-balance requests in the usual way.

> Browse to http://localhost:8010 / http://localhost:30010 and then Ctrl-refresh, you'll see responses from different Pods

StatefulSet Pods have their name set in a label, so if you want to avoid load-balancing (e.g. to send all traffic to a secondary) you can pin the external Service to a specific Pod:

- [update/services.yaml](specs/simple/update/services.yaml) adds to the selector for the external Services, so they'll only send requests to Pod-1

Deploy the Service change:

```
kubectl apply -f labs/statefulsets/specs/simple/update
```

> Now browse to the app and responses will always come from the same Pod

## Deploy a replicated SQL database

We've got the idea of StatefulSets so now we can deploy an app which really does need them - a Postgres database with primary and secondary nodes, each of which needs a PersistentVolumeClaim (PVC) to store data.

We'll use a Postgres Docker image which has all the initialization scripts, so we don't need to worry about that (if you're interested you'll find it in the [sixeyed/widgetario](https://github.com/sixeyed/widgetario/tree/main/src/db/postgres-replicated) repo).

StatefulSets have a special relationship with PersistentVolumeClaims, so you can request a PVC for each Pod which stays linked to the Pod. Pod-1 will have its own PVC and when you deploy an update the new Pod-1 will attach to the same PVC as the previous Pod-1:

- [products-db/service.yaml](specs/products-db/service.yaml) - headless Service, no external Services needed for these Pods
- [products-db/secret.yaml](specs/products-db/secret.yaml) - Secret containing the password for the Postgres user
- [statefulset-with-pvc.yaml](specs/products-db/statefulset-with-pvc.yaml) - StatefulSet which runs two replicas, Pod-0 will be the primary and Pod-1 the secondary; each will have its own PVC created from the volume claim template

Deploy the database and watch the PVCs being created:

```
kubectl apply -f labs/statefulsets/specs/products-db

kubectl get pvc -l app=products-db --watch
```

> You'll see a PVC for Pod-0 gets created, then when Pod-0 is running another PVC gets created for Pod-1

📋 Check the logs of Pod-0 and you'll see it sets itself up as the primary.

<details>
  <summary>Not sure how?</summary>

```
kubectl logs products-db-0
```

</details><br/>

📋 Check Pod-1 and it sets itself as the secondary, once the Postgres database is up and running on the primary:

<details>
  <summary>Not sure how?</summary>

```
kubectl logs products-db-1
```

</details><br/>

Both Pods should end with a log saying the database is ready to accept connections:

```
kubectl logs -l app=products-db --tail 3
```

## Lab

StatefulSets are complex and not as common as other controllers, but they have one big advantage over Deployments - they can dynamically provision a PVC for each Pod.

Deployments don't let you do this ([yet](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/#generic-ephemeral-volumes)), so you can use a StatefulSet instead to benefit from volume claim templates.

The [simple-proxy/deployment.yaml](specs/simple-proxy/deployment.yaml) is a spec to run an Nginx proxy over the StatefulSet website we have running.

Deploy the proxy:

```
kubectl apply -f labs/statefulsets/specs/simple-proxy
```

Test it works at http://localhost:8040 / http://localhost:30040.

Your task is to replace the Deployment which uses an emptyDir volume for cache files with a StatefulSet that uses a PVC for the cache for each Pod. 

The proxy doesn't need Pods to be managed consecutively, so the spec should be set to create them in parallel.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___


## **EXTRA** Testing the replicated database

<details>
  <summary>Deploying a SQL client in the cluster</summary>

You may run a SQL database in your test clusters. You don't want it to be publicly available but you do want to be able to connect and run queries. [Running a SQL Client in Kubernetes](statefulsets-sql-client.md) walks you through that.

</details><br/>

___

## Cleanup

```
kubectl delete svc,cm,secret,statefulset,deployment,pod -l kubernetes.courselabs.co=statefulsets
```