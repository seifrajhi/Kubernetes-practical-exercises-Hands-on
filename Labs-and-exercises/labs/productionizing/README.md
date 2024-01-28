# Preparing for Production

It's straightforward to model your apps in Kubernetes and get them running, but there's more work to do before you get to production.

Kubernetes can fix apps which have temporary failures, automatically scale up apps which are under load and add security controls around containers.

These are the things you'll add to your application models to get ready for production.

## API specs

- [ContainerProbe](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#probe-v1-core)
- [HorizontalPodAutoscaler (autoscaling/v1)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#horizontalpodautoscaler-v1-autoscaling)

<details>
  <summary>YAML overview</summary>

Container probes are part of the container spec inside the Pod spec:

```
spec:
  containers:
    - # normal container spec
      readinessProbe:
        httpGet:
          path: /health
          port: 80
        periodSeconds: 5
```

- `readinessProbe` - there are different types of probe, this one checks the app is ready to receive network requests
- `httpGet` - details for the HTTP call Kubernetes makes to test the app - non-OK response codes means the app is not ready
- `periodSeconds` - how often to run the probe

HorizontalPodAutoscalers (HPAs) are separate objects which interact with a Pod controller and trigger scale events based on CPU usage:

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: whoami-cpu
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: whoami
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 50
```

- `scaleTargetRef` - the Pod controller object to work with
- `minReplicas` - minimum number of replicas
- `maxReplicas` - maximum number of replicas
- `targetCPUUtilizationPercentage` - average CPU utilization target - below this the HPA will scale down, above it the HPA scales up

</details><br/>

## Self-healing apps with readiness probes

We know Kubernetes restarts Pods when the container exits, but the app inside the container could be running but not responding - like a web app returning `503` - and Kubernetes won't know.

The whoami app has a nice feature we can use to trigger a failure like that. 

📋 Start by deploying the app from `labs/productionizing/specs/whoami`.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/productionizing/specs/whoami
```

</details><br/>

You now have two whoami Pods - make a POST command and one of them will switch to a failed state:

```
# if you're on Windows, run this to use the correct curl:
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force; . ./scripts/windows-tools.ps1

curl http://localhost:8010

curl --data '503' http://localhost:8010/health

curl -i http://localhost:8010
```

> Repeat the last curl command and you'll get some OK responses and some 503s - the Pod with the broken app doesn't fix itself.

You can tell Kubernetes how to test your app is healthy with [container probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/). You define the action for the probe, and Kubernetes runs it repeatedly to make sure the app is healthy:

- [whoami/update/deployment-with-readiness.yaml](specs/whoami/update/deployment-with-readiness.yaml) - adds a readiness probe, which makes an HTTP call to the /health endpoint of the app every 5 seconds

📋 Deploy the update in `labs/productionizing/specs/whoami/update` and wait for the Pods with label `update=readiness` to be ready.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/productionizing/specs/whoami/update

kubectl wait --for=condition=Ready pod -l app=whoami,update=readiness
```

</details><br/>

> Describe a Pod and you'll see the readiness check listed in the output

These are new Pods so the app is healthy in both; trip one Pod into the unhealthy state and you'll see the status change:

```
curl --data '503' http://localhost:8010/health

kubectl get po -l app=whoami --watch
```

> One Pod changes in the Ready column - now 0/1 containers are ready.

If a readiness check fails, the Pod is removed from the Service and it won't receive any traffic.

📋 Confirm the Service has only one Pod IP and test the app.

<details>
  <summary>Not sure how?</summary>

```
# Ctrl-C to exit the watch

kubectl get endpoints whoami-np

curl http://localhost:8010
```

</details><br/>

> Only the healthy Pod is in enlisted in the Service, so you will always get an OK response.

If this was a real app the `503` could be happening if the app is overloaded. Removing it from the Service might give it time to recover.

## Self-repairing apps with liveness probes

Readiness probes isolate failed Pods from the Service load balancer, but they don't take action to repair the app. 

For that you can use a liveness probe which will restart the Pod with a new container if the probe fails:

- [deployment-with-liveness.yaml](specs/whoami/update2/deployment-with-liveness.yaml) - adds a liveness check; this one uses the same test as the readiness probe

You'll often have the same tests for readiness and liveness, but the liveness check has more significant consequences, so you may want it to run less frequently and have a higher failure threshold.

📋 Deploy the update in `labs/productionizing/specs/whoami/update2` and wait for the Pods with label `update=liveness` to be ready.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/productionizing/specs/whoami/update2

kubectl wait --for=condition=Ready pod -l app=whoami,update=liveness
```

</details><br/>

📋 Now trigger a failure in one Pod and watch to make sure it gets restarted.

<details>
  <summary>Not sure how?</summary>

```
curl --data '503' http://localhost:8010/health

kubectl get po -l app=whoami --watch
```

</details><br/>

> One Pod will become ready 0/1 -then it will restart, and then become ready 1/1 again.

Check the endpoint and you'll see both Pod IPs are in the Service list. When the restarted Pod passed the readiness check it was added back.

Other types of probe exist, so this isn't just for HTTP apps. This Postgres Pod spec uses a TCP probe and a command probe:

- [products-db.yaml](specs/products-db/products-db.yaml) - has a readiness probe to test Postgres is listening and a liveness probe to test the database is usable

## Autoscaling compute-intensive workloads

A Kubernetes cluster is a pool of CPU and memory resources. If you have workloads with different demand peaks, you can use a [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to automatically scale Pods up and down, as long as your cluster has capacity.

The basic autoscaler uses CPU metrics powered by the [metrics-server](https://github.com/kubernetes-sigs/metrics-server) project. Not all clusters have it installed, but it's easy to set up:

```
kubectl top nodes

# if you see "error: Metrics API not available" run this:
kubectl apply -f labs/productionizing/specs/metrics-server

kubectl top nodes
```

The Pi app is compute intensive so it's a good target for an HPA:

- [pi/deployment.yaml](specs/pi/deployment.yaml) - Deployment which includes CPU resources
- [pi/hpa-cpu.yaml](specs/pi/hpa-cpu.yaml) - HPA which will scale the Deployment, using 75% utilization of requested CPU as the threshold 

📋 Deploy the app from `labs/productionizing/specs/pi`, check the metrics for the Pod and print the details for the HPA.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/productionizing/specs/pi

kubectl top pod -l app=pi-web 

kubectl get hpa pi-cpu --watch
```

</details><br/>

> Initially the Pod is at 0% CPU. Open 2 browser tabs pointing to http://localhost:8020/pi?dp=100000 - that's enough work to max out the Pod and trigger the HPA

**If your cluster honours CPU limits** the HPA will start more Pods.  After the requests have been processed workload falls so the average CPU across Pods is below the threshold and then the HPA scales down.

> Docker Desktop currently has an issue reporting the metrics for Pods. If you run `kubectl top pod` and you see _error: Metrics not available for pod..._ then the HPA won't trigger. [Here is the issue](https://github.com/kubernetes-sigs/metrics-server/issues/1061#issuecomment-1200287201
) - but I don't recommend following the procedure to fix it.

The default settings wait a few minutes before scaling up and a few more before scaling down. Here's my output:

```
NAME     REFERENCE           TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
pi-cpu   Deployment/pi-web   0%/75%     1         5         1          2m52s
pi-cpu   Deployment/pi-web   198%/75%   1         5         1          4m2s
pi-cpu   Deployment/pi-web   66%/75%    1         5         3          5m2s
pi-cpu   Deployment/pi-web   0%/75%     1         5         3          6m2s
pi-cpu   Deployment/pi-web   0%/75%     1         5         1          11m
```

___
## Lab

Adding production concerns is often something you'll do after you've done the initial modelling and got your app running. 

So your task is to add container probes and security settings to the configurable app. Start by running it with a basic spec:

```
kubectl apply -f labs/productionizing/specs/configurable
```

Try the app and you'll see it fails after 3 refreshes and never comes back online. There's a `/healthz` endpoint you can use to check that. Your goals are:

- run 5 replicas and ensure traffic only gets sent to healthy Pods
- restart Pods if the app in the container fails
- add an HPA as a backup, scaling up to 10 if Pods use more than 50% CPU.

This app isn't CPU intensive so you won't be able to trigger the HPA by making HTTP calls. How else can you test the HPA scales up and down correctly? 

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___
## **EXTRA** Pod security 

<details>
  <summary>Restricting what Pod containers can do</summary>

Container resource limits are necessary for HPAs, but you should have them in all your Pod specs because they provide a layer of security. Applying CPU and memory limits protects the nodes, and means workloads can't max out resources and starve other Pods.

Security is a very large topic in containers, but there are a few features you should aim to include in all your specs:

- changing the user to ensure the container process doesn't run as `root`
- don't mount the Service Account API token unless your app needs it
- add a [Security Context](https://kubernetes.io/docs/concepts/security/pod-security-standards/) to limit the OS capabilities the app can use

Kubernetes doesn't apply these by default, because they can cause breaking changes in your app.

```
kubectl exec deploy/pi-web -- whoami

kubectl exec deploy/pi-web -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

kubectl exec deploy/pi-web -- chown root:root /app/Pi.Web.dll
```

> The app runs as root, has a token to use the Kubernetes API server and has powerful OS permissions

This alternative spec fixes those security issues:

- [pi-secure/deployment.yaml](specs/pi-secure/deployment.yaml) - sets a non-root user, doesn't mount the SA token and drops Linux capabilities

```
kubectl apply -f labs/productionizing/specs/pi-secure/

kubectl get pod -l app=pi-secure-web --watch
```

> The spec is more secure, but the app fails. Check the logs and you'll see it doesn't have permission to listen on the port.

Port 80 is privileged inside the container, so apps can't listen on it as a least-privilege user with no Linux capabilities. This is a .NET app which can use a custom port:

- [deployment-custom-port.yaml](specs/pi-secure/update/deployment-custom-port.yaml) - configures the app to listen on non-privileged port 5001

📋 Deploy the update and check it  fixes those security holes.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/productionizing/specs/pi-secure/update

kubectl wait --for=condition=Ready pod -l app=pi-secure-web,update=ports
```

The Pod container is running, so the app is listening, and now it's more secure:

```
kubectl exec deploy/pi-secure-web -- whoami

kubectl exec deploy/pi-secure-web -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

kubectl exec deploy/pi-secure-web -- chown root:root /app/Pi.Web.dll
```

</details><br/>

This is not the end of security - it's only the beginning. Securing containers is a multi-layered approach which starts with your securing your images, but this is a good step up from the default Pod security.

</details><br/>

___
## Cleanup

```
kubectl delete all,hpa -l kubernetes.courselabs.co=productionizing
```