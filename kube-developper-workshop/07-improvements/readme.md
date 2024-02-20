# ✨ Improving The Deployment

We've cut more than a few corners so far in order to simplify things and introduce concepts one at a time, now is a good time to make some simple improvements.
We'll also pick up the pace a little with slightly less hand holding.

## 🌡️ Resource Requests & Limits

We have not given Kubernetes any information on the resources (CPU & memory) our applications require, but we can do this two ways:

- **Resource requests**: Used by the Kubernetes scheduler to help assign _Pods_ to a node with sufficient resources.
  This is only used when starting & scheduling pods, and not enforced after they start.
- **Resource limits**: _Pods_ will be prevented from using more resources than their assigned limits.
  These limits are enforced and can result in a _Pod_ being terminated. It's highly recommended to set limits to prevent one workload from monopolizing cluster resources and starving other workloads.

It's worth reading the [Kubernetes documentation on this topic](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/),
especially on the units & specifiers used for memory and CPU.

You can specify resources of these within the pod template inside the Deployment YAML. The `resources` section needs to go at the same level as `image`, `ports`, etc. in the spec.

```yaml
# Resources to set on frontend & data API deployment
resources:
  requests:
    cpu: 50m
    memory: 50Mi
  limits:
    cpu: 100m
    memory: 100Mi
```

```yaml
# Resources to set on MongoDB deployment
resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 500m
    memory: 300Mi
```

> 📝 NOTE: If you were using VS Code to edit your YAML and had the Kubernetes extension installed you might have noticed yellow warnings in the editor.
> The lack of resource limits was the cause of this.

Add these sections to your deployment YAML files, and reapply to the cluster with `kubectl` as before and check the status and that the pods start up.

## 💓 Readiness & Liveness Probes

Probes are Kubernetes' way of checking the health of your workloads. There are two main types of probe:

- **Liveness probe**: Checks if the _Pod_ is alive, _Pods_ that fail this probe will be **_terminated and restarted_**
- **Readiness probe**: Checks if the _Pod_ is ready to **_accept traffic_**, _Services_ only sends traffic to _Pods_ which are in a ready state.

You can read more about probes at the [kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).
Also [this blog post](https://srcco.de/posts/kubernetes-liveness-probes-are-dangerous.html) has some excellent advice around probes, and covers some of the pitfalls of using them, particularly liveness probes.

For this workshop we'll only set up a readiness probe, which is the most common type:

```yaml
# Probe to add to the data API deployment in the same level as above
# Note: this container exposes a specific health endpoint
readinessProbe:
  httpGet:
    port: 4000
    path: /api/health
  initialDelaySeconds: 0
  periodSeconds: 5
```

```yaml
# Probe to add to the frontend deployment
readinessProbe:
  httpGet:
    path: /
    port: 3000
  initialDelaySeconds: 0
  periodSeconds: 5
```

Add these sections to your deployment YAML files, at the same level in the YAML as the resources block.
Reapply to the cluster with `kubectl` as before, and check the status and that the pods start up.

If you run `kubectl get pods` immediately after the apply, you should see that the pods status will be "Running", but will show "0/1" in the ready column, until the probe runs & passes for the first time.

## 🔐 Secrets

Remember how we had the MongoDB password visible in plain text in two of our deployment YAML manifests?
Blergh! 🤢 Now is the time to address that, we can create a Kubernetes _Secret_, which is a configuration resource which can be used to store sensitive information.

_Secrets_ can be created using a YAML file just like every resource in Kubernetes, but instead we'll use the `kubectl create` command to imperatively create the resource from the command line, as follows:

```bash
kubectl create secret generic mongo-creds \
--from-literal admin-password=supersecret \
--from-literal connection-string=mongodb://admin:supersecret@database
```

_Secrets_ can contain multiple keys, here we add two keys one for the password called `admin-password`,
and one for the connection string called `connection-string`, both reside in the new _Secret_ called `mongo-creds`.

_Secrets_ can use used a number of ways, but the easiest way is to consume them, is as environmental variables passed into your containers.
Update the deployment YAML for your data API, and MongoDB, replace the references to `MONGO_INITDB_ROOT_PASSWORD` and `MONGO_CONNSTR` as shown below:

```yaml
# Place this in MongoDB deployment, replacing existing reference to MONGO_INITDB_ROOT_PASSWORD
- name: MONGO_INITDB_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: mongo-creds
      key: admin-password
```

```yaml
# Place this in data API deployment, replacing existing reference to MONGO_CONNSTR
- name: MONGO_CONNSTR
  valueFrom:
    secretKeyRef:
      name: mongo-creds
      key: connection-string
```

> 📝 NOTE: _Secrets_ are encrypted at rest by AKS however anyone with the relevant access to the cluster will be able to read the _Secrets_ (they are simply base-64 encoded) using kubectl or the Kubernetes API.
> If you want further encryption and isolation a number of options are available including Mozilla SOPS, Hashicorp Vault and Azure Key Vault.

## 🔍 Reference Manifests

If you get stuck and want working manifests you can refer to, they are available here:

- [data-api-deployment.yaml](data-api-deployment.yaml)
- [frontend-deployment.yaml](frontend-deployment.yaml)
- [mongo-deployment.yaml](mongo-deployment.yaml)
  - Bonus: This manifest shows how to add a probe using an executed command, rather than HTTP, use it if you wish, but it's optional.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../06-frontend/readme.md) ‖ [Next Section ⏩](../08-helm-ingress/readme.md)
