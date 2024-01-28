# Lab Solution

My solution adds an Alpine container as the logger, with an EmptyDir volume defined in the Pod and shared by the logger and app containers:

- [solution/deployment.yaml](./solution/deployment.yaml)

Deploy the update:

```
kubectl apply -f ./labs/logging/solution/
```

Wait for the update to roll out and you'll see the logs in the Pod:

```
kubectl logs -l app=fulfilment,component=processor -c logger
```

Browse to Kibana and load the app logs index pattern in the Discover tab. Filter on the labels - app=fulfilment, component=processor - and you'll see the logs flowing in from Fluent Bit.

> The downside is that the log metadata refers to logger container, e.g. no app image

> Back to the [exercises](README.md)