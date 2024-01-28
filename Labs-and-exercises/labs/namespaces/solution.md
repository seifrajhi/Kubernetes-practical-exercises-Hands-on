# Lab Solution

My solution creates a new namespace for Nginx to run in, and uses a FQDN in the Nginx config to proxy the Pi web app - and specifies the correct port:

- [solution/01-namespace.yaml](solution/01-namespace.yaml) - the `front-end` namespace
- [nginx-configMap.yaml](solution/nginx-configMap.yaml) - the configuration, using `http://pi-web-np.pi.svc.cluster.local:8030` as the `proxy_pass` setting

Deploy the namespace first:

```
kubectl apply -f labs/namespaces/solution/01-namespace.yaml
```

Then the original proxy setup:

```
kubectl apply -n front-end -f labs/namespaces/specs/reverse-proxy
```

> Browse to http://localhost:30040 - you'll get an error from your browser

Check the logs and you'll see the proxy won't run if the "upstream" server can't be found:

```
kubectl  logs -n front-end -l app=pi-proxy
```

> You'll see _nginx: [emerg] host not found in upstream "pi-web-internal" in /etc/nginx/nginx.conf:28_

Update the ConfigMap with the correct FQDN, using the app in the existing `pi` namespace, and then you'll need to rollout new Pods to pick up the config change:

```
kubectl apply -f labs/namespaces/solution/nginx-configMap.yaml

kubectl rollout restart -n front-end deploy/pi-proxy
```

> Browse to http://localhost:30040/pi?dp=40000 - now the proxy loads the content from the Pi app; the response will take a couple of seconds

Confirm the cache is being used:

```
kubectl exec -n front-end deploy/pi-proxy -- ls /tmp
```

> Refresh the web app and your response will be instant

> Back to the [exercises](README.md).