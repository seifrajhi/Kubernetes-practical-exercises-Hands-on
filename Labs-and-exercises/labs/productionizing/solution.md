# Lab Solution

Here's my solution:

- [deployment-productionized.yaml](solution/deployment-productionized.yaml) - adds CPU resources and container probes
- [hpa-cpu.yaml](solution/hpa-cpu.yaml) - HPA to scale the Deployment

```
kubectl apply -f labs/productionizing/solution
```

Open two terminals and you can watch the repair and scale in action:

```
kubectl get pods -l app=configurable --watch

kubectl get endpoints configurable-lb --watch
```

> Browse to the app and refresh lots. You might see failures because the app fails so frequently, but leave it a few seconds between refreshes and the app comes back online.

Or if you have `watch` installed (`brew install watch` on macOS; already on Linux; not available on Windows):

```
watch -n 0.5 kubectl get pods,endpoints,hpa

watch -n 0.5 curl -s http://localhost:8040
```

Eventually all the Pods will go into CrashLoopBackOff because Kubernetes thinks the app is unstable.

## Testing the HPA

The HPA is independent of the Deployment. You can scale the Deployment manually (or delete Pods to simulate node loss) and the HPA will override it.

Scale down manually:

```
kubectl scale deployment/configurable --replicas 1

kubectl get hpa configurable-cpu --watch
```

> The HPA scales back up after a few minutes - the minimum is not dependent on CPU usage and it overrides the scale setting for the Deployment.

Scale up manually:

```
kubectl scale deployment/configurable --replicas 8

kubectl get hpa configurable-cpu --watch
```

> After a few more minutes the HPA scales down - it scales down to the maximum initially, but there's no CPU activity so it will repeatedly scale down until it gets to the minimum.

You can't configure the scale-up and scale-down timings for v1 HPAs. If you need that level of control you can use [HorizontalPodAutoscaler (autoscaling/v2)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#horizontalpodautoscaler-v2-autoscaling), which is a more complex HPA spec that allows for [other metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-resource-metrics).

> Back to the [exercises](README.md)