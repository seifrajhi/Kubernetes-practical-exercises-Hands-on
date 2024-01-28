
You can go to town here, but the main focus is productionizing your Pod specs:

- adding readiness and liveness probes
- setting resource limits
- increasing security

My changes are all in the Deployment and StatefulSet objects - if you diff the files between parts 4 and 5, you'll see where the changes are.

Deployment:

```
kubectl apply -f hackathon/solution-part-5/ingress-controller -f hackathon/solution-part-5/products-db -f hackathon/solution-part-5/products-api  -f hackathon/solution-part-5/stock-api -f hackathon/solution-part-5/web
```

Everything works in the same way:

> Browse to http://widgetario.local to see the app

> See the API response at http://api.widgetario.local/products

Cleanup:

```
kubectl delete all,statefulset,pvc,secret,configmap -l kubernetes.courselabs.co=hackathon
```