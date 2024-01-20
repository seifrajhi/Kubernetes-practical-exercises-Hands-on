```
cd ..
```

```
kn default
```

```
mkcert '*.ghost.svc'
```

```
k create secret tls ghost-secret --cert=_wildcard.ghost.svc.pem --key=_wildcard.ghost.svc-key.pem
```

## alternatively, if you can't or you don't want to use mkcert, you can create a selfsigned cert with:

## openssl genrsa -out tls.key 2048

## openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=my.ghost.svc

## k create secret tls ghost-secret --cert=tls.cert --key=tls.key
```
cat 3-ghost-deployment.yaml
```

```
k create -f 3-ghost-deployment.yaml
```

```
k expose deployment ghost --port=2368
```

```
cat 3-ghost-ingress-tls.yaml
```

```
k create -f 3-ghost-ingress-tls.yaml
```

## Please provide the host entry mapping in your /etc/hosts file like this:

## 192.168.64.23 my.ghost.svc admin.ghost.svc

## the IP should be the IP of the traefik loadbalancer / ingress controller

```
open https://my.ghost.svc
```

```
open https://admin.ghost.svc/ghost
```

## change the service type to LoadBalancer and access ghost with the loadbalancer IP on port 2368 or on any other node (works on k3s with trafik only), e.g.:

```
open http://node2:2368
```

## scale the deployment to have 2 replicas and see how the backend ghost backened https://admin.ghost.svc/ghost doesn't work.
