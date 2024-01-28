# Ingress

There are two parts to Ingress:

- the controller, which is a reverse proxy that receives all incoming traffic
- the Ingress objects which set up the routing rules for the controller.

You can choose from different controllers. We'll use the [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/), but [Traefik](https://doc.traefik.io/traefik/providers/kubernetes-ingress/) and [Contour - a CNCF project](https://projectcontour.io) are popular alternatives.

## API specs

- [Ingress (networking.k8s.io/v1)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#ingress-v1-networking-k8s-io)

<details>
  <summary>YAML overview</summary>

Ingress rules can have multiple mappings, but they're pretty straightforward. 

You usually have one object per app, and they are namespaced, so you can deploy them in the same namespace as the app:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: whoami
spec:
  rules:
  - host: whoami.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: whoami-internal
            port: 
              name: http
```

- `rules` - collection of routing rules
- `host` - the DNS host name of the web app
- `http` - ingress routing is only for web traffic
- `paths` - collection of request paths, mapping to Kubernetes Services
- `path` - the HTTP request path, can be generic `/` or specific `/admin`
- `pathType` - whether path matching is as a `Prefix` or `Exact`
- `backend.service` - Service where the controller will fetch content

</details><br/>

## Deploy an Ingress controller

It's not a good name, because an ingress controller isn't a specific type of Kubernetes object - like a Deployment is a Pod controller. 

An ingress controller is a logical thing, composed of a Service, a Pod controller and a set of RBAC rules:

- [01_namespace.yaml](specs/ingress-controller/01_namespace.yaml) - ingress controllers are shared for all apps, so they usuall have their own namespace
- [02_rbac.yaml](specs/ingress-controller/02_rbac.yaml) - RBAC rules so the ingress controller can query the Kubernetes API for Service endpoints, Ingress objects and more
- [configmap.yaml](specs/ingress-controller/configmap.yaml) - additional config for Nginx, to enable proxy caching
- [daemonset.yaml](specs/ingress-controller/daemonset.yaml) - DaemonSet to run the ingress controller Pods; contains a few fields you haven't seen yet
- [services.yaml](specs/ingress-controller/services.yaml) - Services for external access

Deploy the controller:

```
kubectl apply -f labs/ingress/specs/ingress-controller

kubectl get all -n ingress-nginx

kubectl wait --for=condition=Ready pod -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

> Browse to http://localhost:8000 or http://localhost:30000. There are no apps running in the cluster but you'll get a 404 response, which comes from the ingress controller

The ingress controller is powered by Nginx, but you don't need to configure routing inside Nginx - you treat it as a black box and do all the configuration with Ingress objects.

## Publish a default app through ingress

We'll start with a default app which will be a catch-all, so users won't ever see the 404 response from the ingress controller.

- [default/deployment.yaml](specs/default/deployment.yaml) - a simple Nginx deployment, using the standard Nginx image not the ingress controller
- [default/configmap.yaml](specs/default/configmap.yaml) - configuration containing HTML file for Nginx to show
- [default/service.yaml](specs/default/service.yaml) - ClusterIP Service

📋 Deploy the default web app from `labs/ingress/specs/default`:

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/ingress/specs/default
```

</details><br/>

Nothing happens yet. Services aren't automatically wired up to the ingress controller - you do that by specifying routing rules in an Ingress object:

- [ingress/default.yaml](specs/default/ingress/default.yaml) - Ingress rule with no host specified, so all requests will go here by default

📋 Now deploy the ingress rule in `labs/ingress/specs/default/ingress` and list all rules:

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/ingress/specs/default/ingress

kubectl get ingress
```

</details><br/>

When you browse to any URL you'll see the default response:

> Browse to http://localhost:8000/a/bc.php or http://localhost:30000/a/bc.php

<details>
  <summary>ℹ Ingress controllers usually have their own default backend.</summary>
 
 That's where the 404 response originally came from Nginx. An alternative to running your own default app is to [customize the default backend](https://kubernetes.github.io/ingress-nginx/user-guide/default-backend/) - but that's specific to the ingress controller you're using.

</details><br/>

## Publish an app to a specific host address

To publish all of your apps through the ingress controller it's the same pattern - have an internal Service over the application Pods, and an Ingress object with routing rules.

Here's the spec for the whoami app, which will publish to a specific host name:

- [whoami.yaml](specs/whoami/whoami.yaml) - Deployment and ClusterIP Service for the app, nothing ingress-specific
- [whoami/ingress.yaml](specs/whoami/ingress.yaml) - Ingress which routes traffic with the host domain `whoami.local` to the ClusterIP Service

📋 Deploy the app in `labs/ingress/specs/whoami` and check the Ingress rules.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/ingress/specs/whoami

kubectl get ingress
```

</details><br/>

To access the site locally you'll need to add an entry in your [hosts file](https://en.wikipedia.org/wiki/Hosts_(file)) - this script will do it for you (replace the IP address with a node IP if you're using a remote cluster):

```
# using Powershell - your terminal needs to be running as Admin:
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
./scripts/add-to-hosts.ps1 whoami.local 127.0.0.1

# on macOS or Linux - you'll be asked for your sudo password:
sudo chmod +x ./scripts/add-to-hosts.sh
./scripts/add-to-hosts.sh whoami.local 127.0.0.1
```

> Browse to http://whoami.local:8000 or http://whoami.local:30000 and you'll see the site. There are multiple replicas - refresh to see load-balancing between them

## Use ingress with response caching

The Ingress API doesn't support all the features of every ingress controller, so to use custom features you set the configuration in annotations.

We'll publish the Pi web app on the hostname `pi.local`, first using a simple Ingress with no response cache:

- [pi.yaml](specs/pi/pi.yaml) - Deployment and Service for the app
- [pi/ingress.yaml](specs/pi/ingress.yaml) - Ingress which routes `pi.local` to the Service

📋 Deploy the app in `labs/ingress/specs/pi`, check the status and add `pi.local` to your hosts file.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/ingress/specs/pi

kubectl get ingress

kubectl get po -l app=pi-web

# Windows:
./scripts/add-to-hosts.ps1 pi.local 127.0.0.1

# *nix:
./scripts/add-to-hosts.sh pi.local 127.0.0.1
```

</details><br/>

> Browse to http://pi.local:8000/pi?dp=25000 / http://pi.local:30000/pi?dp=25000 it'll take a second or so to see the response. Refresh and you'll see the request is load-balanced and the response is calculated every time.

We can update the Ingress object to use response caching - which the Nginx ingress controller supports:

- [ingress-with-cache.yaml](specs/pi/update/ingress-with-cache.yaml) - uses Nginx annotations to use the cache; the controller looks for this when it sets up the config for the site

There's no change to the app, only the Ingress:

```
kubectl apply -f labs/ingress/specs/pi/update
```

> Now browse to http://pi.local:8000/pi?dp=25000 / http://pi.local:30000/pi?dp=25000 - you'll see the cached response with every refresh.


<details>
  <summary>ℹ Typically you won't want to cache all parts of your app.</summary>

You may have different Ingress rules - one for all static content which has the cache annotation, and another for dynamic content.

</details><br />

## Lab

Two parts to this lab. First we want to take the configurable web app and publish it through the ingress controller. 

The app spec is already in place to get you started, your job is to build and deploy the Ingress routing:

```
kubectl apply -f labs/ingress/specs/configurable
```

The second part is we'd like to change the ingress controller to use the standard ports - 80 for HTTP and 443 for HTTPS. You'll only be able to do that if you're using the LoadBalancer.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## **EXTRA** Ingress for HTTPS

<details>
  <summary>SSL termination and redirects</summary>

Ingress controllers can apply TLS certificates to encrypt HTTPS traffic, so you don't need that logic in your apps. [Ingress for HTTPS](ingress-https.md) takes you through that.

</details><br />

___

## Cleanup

```
kubectl delete all,secret,ingress,clusterrolebinding,clusterrole,ns,ingressclass -l kubernetes.courselabs.co=ingress
```