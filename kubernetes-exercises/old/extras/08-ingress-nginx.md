# Ingress
If we look at Service as an endpoint, then the Kubernetes ingress object is a DNS.
It takes care of things like load balancing traffic, terminating SSL and naming among other things. 

To enable an ingress object, we need an ingress controller. In this example we will be using [NGINX](https://www.nginx.com/). If you prefer [Træfik (optimized for Kubernetes) there is another exercise doing it with Træfik](./03-ingress-traefik.md).

To get started with NGINX ingress, we (re)deploy an app of our choice: 
```shell
kubectl create deployment ingress-test --image=<your-image>
kubectl scale deployment ingress-test --replicas=3
kubectl expose deployment ingress-test --port=<your-port>
```

The NGINX ingress controller requires a default backend which serves as a fallback for nginx in case a request fails. 
It will:
- Serve a 404 page at /
- Serve 200 on /healthz

The [example deployment file for nginx-ingress-controller](ingress-nginx/nginx-backend/nginx-backend.yml) is taken from [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx), as is the [service exposing the backend](ingress-nginx/nginx-backend/nginx-service.yml).

Deploy by running: 
```shell
kubectl create -f ingress-nginx/nginx-backend/.
```

We will need a certificate for NGINX, which has been prepared in [a script](ingress-nginx/self-signed-cert.sh). We will need to turn that into a secret.

When prompted to put a "common name" in the certificate, write myapp.local (*important!*). This is going to be our host rule for our ingress later.

```shell
./ingress-nginx/self-signed-cert.sh
kubectl create secret tls tls-certificate --key tls-key.key --cert tls-cert.crt
kubectl create secret generic tls-dhparam --from-file=dhparam.pem
```

We then have to enable ingress, which is very simple:
```
minikube addons enable ingress
```
The reason it is not natively enabled, is because early versions of Kubernetes shipped without it. 

Enabling gave us: 
- A configmap 
    * kubectl get configmap nginx-load-balancer-conf -n kube-system
    * This describes the nginx configuration
- The nginx-ingress-controller
    * kubectl get rc nginx-ingress-controller -n kube-system
    * This enables us to do ingress
- A service exposing default NGINX backend pod handling
    * kubectl get svc default-http-backend -n kube-system
    * This serves (together with the deployed yaml from earlier) the 404 and 200. 


Nginx can be accessed this way : 
```shell
curl $(minikube service nginx-ingress --url)
```

Which will return 404 default backend. 

Go and modify [the yaml for your ingress](./ingress-nginx/ingress.yml) to reflect the correct service and deployment. 

Ingress works by using the DNS name, so we need to modify our hostfile to reflect the correct name (modify hosts file to include myapp.local pointing to the cluster): 

```shell
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts
```

To make it work for your cluster, replace the minikube ip with a node ip. 

You can now access it on http://myapp.local, though you probably get a https error on the certificate because it was self signed.

This concludes the exercise for ingress. 

