# Lab Solution

How you rollout config changes depends a lot on your organization structure and workflow.

This solution shows two valid options, but often the process is automated with [Kustomize](https://kustomize.io) or [Helm](https://helm.sh).


## Using new names for config objects

If you want to trigger a Deployment rollout when you change config, you can create new config objects with new names and update the Pod spec in the Deployment to use the new objects.

Deploy a v1 set of config:

```
kubectl apply -f labs/secrets/solution
```

> Browse to the app at :30020 or :8020

The update is done with a new Secret and an update to the Deployment:

- [secret-v2.yaml](solution/v2-name/secret-v2.yaml) - is a whole new Secret object with the new settings
- [deployment.yaml](solution/v2-name/deployment.yaml) - updates the existing Deployment object with the new Secret name in the Pod spec

```
kubectl apply -f labs/secrets/solution/v2-name
```

Refresh the app and you'll see the new config as soon as the Pod rollout is complete.

This option has the advantage of preserving the old config settings, so you can roll back if there's a problem:

```
kubectl get secrets -l app=configurable-lab

kubectl rollout undo deploy/configurable-lab
```

## Using annotations with config versions

Annotations are the other popular option. Annotations are metadata items like labels, but they're used to record extra information, while labels are used internally by Kubernetes.

Reset the lab by removing and re-deploying:

```
kubectl delete deployment,secret -l app=configurable-lab

kubectl apply -f labs/secrets/solution
```

> Browse to :30020 or :8020 - the config is back to v1

Now deploy the update - it's a change to the existing Secret object, and a new annotation in the Pod spec:

- [secret-v2.yaml](solution/v2-annotation/secret-v2.yaml) - is an update to the data in the existing Secret object
- [deployment.yaml](solution/v2-annotation/deployment.yaml) - updates the existing Deployment object, still with the same Secret name but adding an annotation to store the config version

```
kubectl apply -f labs/secrets/solution/v2-annotation
```

Metadata changes in the Pod spec trigger a rollout (but not in the metadata for the Deployment itself). You'll see the v2 config setting when you refresh.

This option doesn't preserve config history, so to undo the changes you'd need to apply the v1 Secret again and then rollback:

```
kubectl get secrets -l app=configurable-lab

kubectl apply -f labs/secrets/solution/secret.yaml

kubectl rollout undo deploy/configurable-lab
```

> Which of these works for a project depends on your organization, how you store configuration, and whether you want deployments to be fully automated or you need to decouple config management from app deployments.

> Back to the [exercises](README.md).