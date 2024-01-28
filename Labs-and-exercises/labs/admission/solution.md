# Lab Solution

The output from Kubectl apply gives you the first violation:

```
Error from server ([requiredlabels-ns] you must provide labels: {"kubernetes.courselabs.co"}): error when creating "labs//admission//specs//apod//01-namespace.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [requiredlabels-ns] you must provide labels: {"kubernetes.courselabs.co"}
```

So you'll need to add the label to the namespace spec; here's my solution:

- [01-namespace.yaml](./solution/01-namespace.yaml)

Now the resources can all be created, but the Deployments never get up to scale:

```
kubectl get deploy -n apod
```

Fetch the details for the ReplicaSets (any one will do):

```
kubectl describe rs -n apod
```

You'll see the failures:

```
Error creating: admission webhook "validation.gatekeeper.sh" denied the request: [resource-limits] container <web> has no cpu limit[requiredlabels-pods] you must provide labels: {"app", "version"} 
```

The Pod specs need labels, and the container specs need resource limits:

- [api.yaml](./solution/api.yaml)
- [log.yaml](./solution/log.yaml)
- [web.yaml](./solution/web.yaml)

Apply the fixed specs:

```
kubectl apply -f labs/admission/solution
```

The Deployments should all get up to scale, and the app should be running at to http://localhost:30016