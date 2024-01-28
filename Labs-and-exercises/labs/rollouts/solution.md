# Lab Solution

## Diagnosis

Check the Deployments created by the Helm chart:

```
kubectl get deploy -l app.kubernetes.io/managed-by=Helm
```

Look at the Pods and the "slot" label:

```
kubectl get po -l component=web -L slot -o wide
```

You'll see all the Pods in the Service - the selector is not choosing by the slot label:

```
kubectl describe svc vweb-web
```

Browse to the app at http://localhost:30019; requests are load-balanced between the blue and green Pods.

## Fixing the chart

The fix is to the label selector in the Service - adding the `activeSlot` value:

- [solution/helm/vweb/templates/service.yaml](./solution/helm/vweb/templates/service.yaml)

Update the chart to use the new template:

```
helm upgrade vweb labs/rollouts/solution/helm/vweb
```

Refresh at http://localhost:30019 - all responses are blue (v1), which is the default slot in the values file.

Switch to the green slot:

```
helm upgrade --set activeSlot=green vweb labs/rollouts/solution/helm/vweb
```

And now the app is running the green (v2) release.

> With a blue-green update there is no delay while the new Pods come online, they're already up and running.

## Automatic rollbacks

Open a new split terminal so you can track the changes to the blue release:

```
kubectl get po -l slot=blue --watch
```

The Helm `upgrade` command supports the `atomic` flag - so any errors in the upgrade cause the whole release to roll back to the previous definition.

This update doesn't cause an error during deployment, so you need a timeout to force the rollback when the Pods enter the CrashLoopBackOff state:

```
helm upgrade --reuse-values --set blueImage=kiamol/ch09-vweb:v3 --atomic --timeout 30s  vweb labs/rollouts/solution/helm/vweb
````

> You'll see the new v3 Pods fail, and after the timeout Helm rolls back they get terminated. The v1 Pods keep running because the update fails.

Specifying `reuse-values` means the green release is still active, so the failed blue update doesn't affect the app.

> Back to the [exercises](README.md)