# Kubernetes secrets

The objective of this exercise use SSL certs in nginx, using secrets. 

Generate self signed certs: (check support-files/ directory)
```
./generate-self-signed-certs.sh
```
This will create `tls.*` files.


Create  (tls type) secret for nginx:

```
kubectl create secret tls nginx-certs --cert=tls.crt --key=tls.key
```

Examine the secret you just created:
```
kubectl describe secret nginx-certs
```

```
kubectl get secret nginx-certs -o yaml
```


Create configmap for nginx: (check support-files/  directory)
```
kubectl create configmap nginx-config --from-file=nginx-connectors.conf
```

Examine the configmap you just created:

```
kubectl describe configmap nginx-config
```

```
kubectl get configmap nginx-config -o yaml
```


Create a nginx deployment with SSL support using the secret and config map you created in the previous steps (above): (check support-files/  directory)
```
kubectl create -f nginx-ssl.yaml
```

You should be able to see nginx running. Expose it as a service and curl it from your computer. You can also curl it through the multitool pod from within the cluster.


