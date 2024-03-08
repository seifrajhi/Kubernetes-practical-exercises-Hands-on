# Ingress on Google Cloud

GoogleKubernetesEngine (GKE) does Ingress a bit differently. For reference, those brave of you who want to play with Minikube, I have two more you can do - [nginx](06-ingress-nginx.md) and [traefik](06-ingress-traefik.md).

However because we are running things on GKE, we are going to focus on that today.

An ingress is loosely translatable to DNS namespace, and makes it so that:

- Traffic to port `80` (http) and port `443` (https) goes to ingress rules instead AND
- A name call to (example) myapplication.example.local gets translated to an IP and then routed to a container.

Create an Nginx deployment and service, exposing the service as a nodeport. If you need a hint as to how this is done, look at the [Pods and Deployments](01-pods-deployments.md) and [Service Discovery and Loadbalancing](02-service-discovery-and-loadbalancing) exercises.

GKE automatically exposes NodePorts through a Loadbalancer, but the 'correct' way is the ingress rule, which will work on all infrastructure.

## Creating an 'address' on Google Cloud

> NB: To manipulate `address` on Google Cloud you need the `Compute Admin Network`-right or similar on your service account.
> If you have trouble creating the `address` verify (or ask your trainer to verify) that your service account is configured properly.

Google cloud need an address created. All the steps running gcloud commands, are unusual and can be disregarded for a normal Kubernetes setup outside of GKE.

```shell
$ gcloud compute addresses create <my-address-name> --global --project praqma-education
Created [https://www.googleapis.com/compute/v1/projects/praqma-education/global/addresses/<my-address-name>].
```

You can see the allocated IP of the address you created by running the following command:

```shell
$ gcloud compute addresses describe <my-address-name> --global --format='value(address)' --project praqma-education
<your-ip>
```

## Using the created address in an ingress object

Ingress' can be told by annotation where the source request came from. This is useful when going through multiple networks, as the ingress rule then understand things like sticky sessions and other networking things like SSL termination and so on.

```yaml
annotations:
  kubernetes.io/ingress.global-static-ip-name: "my-address-name"
```

The above only works for GKE, but an equivalent for nginx would look like this:

```yaml
annotations:
  kubernetes.io/ingress.class: "nginx"
  nginx.org/ssl-services: "my-service"
```

So lets put the following ingress spec into `ingress-file.yaml`:

```yaml,k8s
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx
  annotations:
    kubernetes.io/ingress.global-static-ip-name: "my-address-name"    # should match the name of the address you created before
spec:
  backend:
    serviceName: nginx
    servicePort: 80
```

And create it!

```shell
$ kubectl apply -f ingress-file.yml
ingress.extensions/nginx created
```

Find it in the Kubernetes cluster (hint: `.. get ing nginx`)

The `ADDRESS` bit, should match the IP of the address you created before.

## See your application on the internet

You should be able to visit this address, and see the nginx homesite!
> NB: if you get an error from Google,
> try checking your ingress object with `kubectl describe ingress nginx`,
> the `annotation` called `backends` needs to be `HEALTHY`, like below:
> ```shell
> Annotations:
>   ...
>   kubernetes.io/ingress.global-static-ip-name:  my-address-name
>   ingress.kubernetes.io/backends:               {"<backend id>":"HEALTHY"}
>   ...
> ```
> if the `backend` is `UNKNOWN` and your `ingress.global-static-ip-name`
> points correctly to the address you created before, don't fear,
> Google Cloud Load Balancers needs a certain amount of successes on an endpoint,
> before it starts serving traffic; the backend should become `HEALTHY` within a few minutes.

## DNS Rules

Normally you *COULD* add a dns rule, and say "I want nginx.local to route to this container" and it would look something like this:

```yaml,k8s
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        backend:
          serviceName: ingress-test
          servicePort: replaceport
```

Because GKE "makes ingress easy", these things need a DNS setup on GKE which we are not going to do. But this should give an impression of ingress.

I thoroughly recommend looking at minikube and ingress, if you plan to use this more extensively.
