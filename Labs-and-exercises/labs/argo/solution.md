# Lab Solution

This ArgoCD command creates a new app with the correct source setup and the app set to auto-sync:

```
argocd app create lab --repo http://gogs.infra.svc.cluster.local:3000/kiamol/kiamol.git --path labs/argo/project/apod/base --dest-server https://kubernetes.default.svc --dest-namespace default --sync-policy auto --self-heal
```

Check the app has been created:

```
argocd app list
```

Watch in the ArgCD UI at https://localhost:30018/applications/lab or use Kubectl to see the Pods being created:

```
kubectl get po -n default -l project=apod --watch
```

When the Pods are all ready, you can find the app URL by looking for public Services in the ArgoCD UI or Kubectl.

Try the app at http://localhost:30008. You should see NASA's Astronomy Picture of the Day.


