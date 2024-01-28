

```
kubectl apply -f hackathon/solution-part-4/ingress-controller -f hackathon/solution-part-4/products-db -f hackathon/solution-part-4/products-api  -f hackathon/solution-part-4/stock-api -f hackathon/solution-part-4/web
```

Update hosts:

```
.\scripts\add-to-hosts.ps1 widgetario.local 127.0.0.1

.\scripts\add-to-hosts.ps1 api.widgetario.local 127.0.0.1
```

> Browse to http://widgetario.local to see the app

> See the API response at http://api.widgetario.local/products

Cleanup:

