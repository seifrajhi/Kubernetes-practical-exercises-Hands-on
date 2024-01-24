## Installation

### Installing base application
```
# install namespaces
kubectl apply -f namespaces.yaml

# Install application
kubectl apply -f httpbin-deploy.yaml
```
Now the application should be installed and accessible only through the cluster. Check installation with.
```
kubectl get pods -n demo
kubectl port-forward -n demo svc/httpbin 8000:8000
```
There should be one pod deployed in demo with only 1/1 containers ready. When installing istio there will be a
sidecar added here. Access the application on localhost:8000

### Installing Istio

In this guide I was using Azures AKS which has the option to use the LoadBalancer service type with a static Ip.
If you also use Azure replace the ips in `istio-controlplane.yaml` with your public IP. If you are not using a
provider with support for LoadBalancers you can replace this with NodePorts. An example of this is commented in
the `istio-controlplane.yaml` file. After the config is ready install istio with:

```
kubectl apply -f istio-1.12.1/manifests/charts/base/crds/crd-all.gen.yaml
./istio-1.12.1/bin/istioctl operator init
kubectl apply -f istio-controlplane.yaml
./istio-1.12.1/bin/istioctl verify-install
```


### Installing cert-manager

```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.4.0 \
  --set installCRDs=true \
  --set startupapicheck.enabled=false
```

### Create gateways and certificates
Replace `email` in `cluster-issuer.yaml` then replace the occurrences of `httpbin.example.com` with the url
you want to use for your httpbin-app. Do this in both `httpbin-istio-gw.yaml` and `httpbin-tls-cert.yaml`
```
kubectl apply -f cluster-issuer.yaml
kubectl apply -f httpbin-istio-gw.yaml
kubectl apply -f httpbin-tls-cert.yaml
```

### Validate

```
# check pods
kubectl get pods -n cert-manager
kubectl get pods -n demo
# Both should have sidecars and be ready.
kubectl get certificate -n istio-system
```
Visit url.

### Installing Dex

replace `issuer` with the url for your dex and `redirectURIs:` with the url for your app in `dex-values.yaml`.
Then run:

```
helm repo add dex https://charts.dexidp.io
helm repo update
helm install \
  --namespace demo \
  --values dex-values.yaml \
  --version 0.6.5 \
  dex dex/dex
```

Replace the occurrences of `dex.example.com` with the url
you want to use for dex. Do this in both `dex-istio-gw.yaml` and `dex-tls-cert.yaml` Then apply with:
```
kubectl apply -f dex-istio-gw.yaml
kubectl apply -f dex-tls-cert.yaml
```

For authentication we can use any IDP which supports OIDC. In this example Dex is installed
which can in turn be connected to other AD sources see our blog post on 
[how to connect dex to google](https://elastisys.com/elastisys-engineering-how-to-use-dex-with-google-accounts-to-manage-access-in-kubernetes/) 
for more information. In this post we will only use Dex static user as an example.

### Installing oauth2-proxy
Replace `oidc_issuer_url` and `cookie_domains` from `oauth2-proxy-values.yaml` with your domain name then apply with:

```
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
helm repo update
helm install \
  --namespace demo \
  --values oauth2-proxy-values.yaml \
  --version 5.0.6 \
  oauth2-proxy oauth2-proxy/oauth2-proxy
```

### Apply authorization policy
Replace `httpbin.example.com` with you app url in `authorization-policy.yaml` then apply with:
```
kubectl apply -f authorization-policy.yaml
```

The authorization policy will trigger when trying to access the hostname configured. 
When the policy is triggered it will use the extensionProvider from the `istio-controlplane.yaml` config.
This will cause a redirect to the oauth2-proxy which in turn will go to dex for authentication. Authenticate
with:
```
Username: admin
Password: password
```

### Verify

You should now be able to access the httpbin application again which is now protected by the authentication service. 
You can see that the application have received the access_token by going to your app-url and /headers `httpbin.example.com/headers`.
This should now include the `Authorization` header with a jwt-token. You can decode this token to see the information stored there.

### Final words

This guide will make all applications behind the authorization policy have to go through the Oauth2 authentication flow to access these applications.
This provides the security that the user will have to be able to login to your IDP service to access the apps. OBS that this does NOT include authorization which the applications themselves will still have to support. 
