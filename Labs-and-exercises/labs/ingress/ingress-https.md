# Ingress for HTTPS

You can use ingress for SSL termination, storing your HTTPS certificates as Kubernetes Secrets.

The ingress controller takes care of applying the cert to encrypt traffic, and it can also redirect HTTP requests to HTTPS.

##  Create a TLS cert for HTTPS access

Ingress controllers are the single entrypoint for all your apps. They're great for centralizing concerns like caching and HTTPS. 

The controller applies the TLS certificates to the public endpoint, and internally the apps work on plain HTTP.

The Ingress spec supports HTTPS and the Nginx ingress controller is already running with a TLS certificate:

> Browse to https://whoami.local:8040 or https://whoami.local:30040

You'll see an error because this is a self-signed certificate, which means it's not trusted. You can check the cert details in your browser and you'll see something like this:

![](/img/ingress-controller-cert.png)

You can apply your own certificates in Ingress rules. You might buy a TLS cert from an online provider specific to your host domains, but we'll generate our own:

- [cert-generator.yaml](specs/tls/cert-generator.yaml) - uses a tool to create a TLS cert for our domains

Generate the certs:

```
kubectl apply -f labs/ingress/specs/tls

kubectl wait --for=condition=Ready pod tls-cert-generator

kubectl logs tls-cert-generator
```

(The Pod runs some OpenSSH commands - here's the
[script](https://github.com/sixeyed/kiamol/blob/master/ch15/docker-images/cert-generator/start.sh) if you want to see how it's done).

Now you can copy the cert files from the Pod to your local machine:

```
kubectl cp tls-cert-generator:/certs/server-cert.pem tls.crt

kubectl cp tls-cert-generator:/certs/server-key.pem tls.key
```

And use them to create a Secret. Kubernetes supports TLS certificates as a special Secret type, and you pass the certificate file and key to the `create secret` command:

```
kubectl create secret tls https-local --key=tls.key --cert=tls.crt

kubectl label secret https-local kubernetes.courselabs.co=ingress

kubectl describe secret https-local
```

Now we have a Secret with a TLS cert that can be used for our local app domains.

<details>
  <summary>ℹ Creating a TLS Secret is what you do if you have a manual process to get your certificates. </summary>

Ideally you should use an automated process instead so your certs never expire - [cert-manager](https://cert-manager.io) is how you do that in Kubernetes.

</details><br />

___

## Expose apps through HTTPS

HTTPS is really easy to apply with ingress - you just add the name of the Secret containing the TLS certificate to the Ingress spec:

- [pi-https.yaml](specs/tls/ingress/pi-https.yaml) - uses the TLS Secret for the Pi app; the folder contains the same updates for the other Ingress objects

Add TLS support:

```
kubectl apply -f labs/ingress/specs/tls/ingress

kubectl get ingress
```

> The basic Ingress view doesn't show the TLS setup, you need to `describe` to see that

Now you can browse to the sites at the HTTPS endpoint:

- https://pi.local:8040
- https://whoami.local:8040

> You'll still get a browser warning, but if this was a trusted cert from a real authority you wouldn't

Ingress also redirects HTTP requests to HTTP **but it only uses the default port 443**:

```
curl -v http://pi.local:8040/
```

> We're using a non-standard port for HTTPS, so the redirect won't work. In a real cluster the Service for the Ingress controller would listen on ports 80 and 443.

___

## Cleanup

```
kubectl delete all,secret,ingress,ns -l kubernetes.courselabs.co=ingress
```