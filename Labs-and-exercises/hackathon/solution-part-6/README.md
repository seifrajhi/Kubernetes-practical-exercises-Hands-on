

- Deploy Prometheus & Grafana

```
kubectl apply -f hackathon/solution-part-6/monitoring 
```

- Configure Apps to Publish Metrics

```
kubectl apply -f hackathon/solution-part-6/ingress-controller -f hackathon/solution-part-6/widgetario
```


- Load Dashboard

hackathon\files\grafana-dashboard.json

- Deploy EFK Stack


```
kubectl apply -f hackathon/solution-part-6/logging 
```

- Load Dashboard

hackathon\files\kibana-dashboard.ndjson


