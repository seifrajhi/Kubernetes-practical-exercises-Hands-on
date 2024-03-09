# [Monitoring](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

<br />

### Monitor the node consumption

<br />

```bash
kubectl top nodes
```

<br />

### Monitor the pod consumption

```bash
kubectl top pods
```

<br />

### Find pod with label `name=high-cpu` running with high CPU workloads

```bash
kubectl top pods -l name=high-cpu --sort-by=CPU
```

<br />

