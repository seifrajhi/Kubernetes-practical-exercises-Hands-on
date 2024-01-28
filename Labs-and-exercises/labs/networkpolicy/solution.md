# Lab Solution

Start by deleting the original app:

```
kubectl delete -f labs/networkpolicy/specs/apod

kubectl delete -f labs/networkpolicy/specs/apod/network-policies
```

You should still have the default deny policy:

```
kubectl get netpol
```

My solution (in labs/networkpolicy/solution/apod) adds a namespace to all the Pod selectors:

- [network-policies.yaml](./solution/apod/network-policies.yaml)

Deploy the app:

```
kubectl apply -f labs/networkpolicy/solution/apod
```

Test the web app can access the API, and the API can access the external API:

```
kubectl exec -n apod deploy/apod-web -- wget -O- -T2 http://apod-api/image
```

> Refresh http://localhost:30016, the app should be working correctly

Try to access the API from the sleep Pod:

```
kubectl exec sleep -- wget -O- http://apod-api.apod.svc.cluster.local/image
```

> You'll get a bad address error, because the Pod can't access DNS

Try with the IP address instead:

```
kubectl get po -n apod -l app=apod-api -o wide

# this will fail with a timeout
kubectl exec sleep -- wget -O- -T2 http://<pod-ip-address>/image
```

> Now you'll get a timeout error, because Calico is blocking the connection

> Back to the [exercises](README.md)