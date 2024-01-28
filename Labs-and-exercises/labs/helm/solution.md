# Lab Solution

Start by adding the repo and updating your local package list:

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update
```

Search for the chart - version `4.2.0` installs app version `1.3.0`, and you can see the default values:

```
helm search repo ingress-nginx --versions

helm show values ingress-nginx/ingress-nginx --version 4.2.0
```

Install the chart to a custom namespace, which Helm will create if it doesn't exist; the `f` flag has the path to the local values file:

```
helm install -n ingress --create-namespace -f labs/helm/ingress-nginx/dev.yaml ingress-nginx ingress-nginx/ingress-nginx --version 4.2.0

# the output docs include sample Ingress spec
```

Helm releases are namespaced - you won't see the ingress controller in the default namespace:

```
helm ls

helm ls -A
```

Check the Service to confirm the type and port:
```
kubectl get svc -n ingress
```

> Browse to http://localhost:30040

And that's a production-grade 404 you're seeing :)

> Back to the [exercises](README.md).