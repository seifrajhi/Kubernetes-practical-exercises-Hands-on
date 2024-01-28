# Lab Solution

You use the `kubectl create` command to imperatively create objects. Don't use it for Pods or Deployments - YAML is a much better option - but it can work well for ConfigMaps.

## Create ConfigMap from literal

The easiest option is to specify the key and value for environment variable settings as a literal:

```
kubectl create configmap configurable-env-lab --from-literal=Configurable__Release='21.04-lab'

kubectl describe cm configurable-env-lab
```

## Create ConfigMap from env file

Alternatively store the values in a .env file - like [configurable.env](solution/configurable.env). This is not the same as storing the config in YAML, because it's the native format and can be used outside of Kubernetes.

You'll need to delete the literal ConfigMap to try this - that's why desired state in YAML is a better option:

```
kubectl delete configmap configurable-env-lab

kubectl create configmap configurable-env-lab --from-env-file=labs/configmaps/solution/configurable.env

kubectl describe cm configurable-env-lab
```

## Create ConfigMap from config file

- [override.json](solution/override.json) has the required JSON settings. The filename is the same as the expected filename the app will read.

```
kubectl create configmap configurable-override-lab --from-file=labs/configmaps/solution/override.json

kubectl describe cm configurable-override-lab
```

## Deploy the app

- [deployment-lab.yaml](specs/configurable/lab/deployment-lab.yaml) expects the same ConfigMap names we've used, so we can deploy:

```
kubectl apply -f labs/configmaps/specs/configurable/lab/
```

> Browse to your Service and you should see the configured settings from the expected sources

> Back to the [exercises](README.md).