
## Publishing the configurable app

Ingress objects reference Services in the local namespace, so you need to create your Ingress in the same namespace as the app:

- [configurable-http.yaml](solution/ingress/configurable-http.yaml) 

```
kubectl apply -f labs/ingress/solution/ingress
```

It's a new domain so you need to add it to your hosts file:

```
# on Windows:
./scripts/add-to-hosts.ps1 configurable.local 127.0.0.1

# on *nix:
./scripts/add-to-hosts.sh configurable.local 127.0.0.1
```

> Now you can browse to http://configurable.local:8000 (or http://configurable.local:30000)

## Using standard HTTP and HTTPS ports

For this all you need to do is change the public ports for the ingress controller LoadBalancer Service:

- [controller/service-lb.yaml](solution/controller/service-lb.yaml)

```
kubectl apply -f labs/ingress/solution/controller

kubectl get svc -n ingress-nginx
```

Now you can use normal URLs:

- http://configurable.local
- http://pi.local
- http://localhost
- https://pi.local (you'll see an error about the TLS cert being untrusted)

## Why can't you do this with a cluster that doesn't support LoadBalancer Services?

NodePorts are restricted to the unprivileged port range - 30000+. You can't have a NodePort listen on 80 or 443.

> Back to the [exercises](README.md).