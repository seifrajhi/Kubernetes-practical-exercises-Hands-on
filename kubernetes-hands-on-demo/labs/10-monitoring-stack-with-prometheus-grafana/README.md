# Monitoring with Prometheus and Grafana

## RBAC 

Create the tiller service account: 

```
$ kubectl create serviceaccount tiller --namespace kube-system
serviceaccount/tiller created
```

Create the toller cluster role bindings:

```
> kubectl create clusterrolebinding tiller-role-binding --clusterrole cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io/tiller-role-binding created
```

## Helm

Initialize Helm:

```
> helm init --service-account tiller
$HELM_HOME has been configured at /Users/ruan.bekker/.helm.
Error: error installing: the server could not find the requested resource
```

If you run into the error as above, there is a issue on GitHub: 
- https://github.com/helm/helm/issues/6374

Workaround:

```
> helm init --service-account tiller --override  spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
deployment.apps/tiller-deploy created
service/tiller-deploy created
```

Verify that tiller is running:

```
> kubectl get pods --namespace kube-system
NAME                                      READY   STATUS      RESTARTS   AGE
metrics-server-6d684c7b5-ktfpl            1/1     Running     0          17m
local-path-provisioner-58fb86bdfd-qj7hn   1/1     Running     0          17m
helm-install-traefik-kjld9                0/1     Completed   0          17m
svclb-traefik-hk6ht                       2/2     Running     0          17m
svclb-traefik-bj7r9                       2/2     Running     0          17m
svclb-traefik-4lx56                       2/2     Running     0          17m
coredns-d798c9dd-vdg56                    1/1     Running     0          17m
traefik-6787cddb4b-zvrph                  1/1     Running     0          17m
tiller-deploy-cf88b7d9-h8lxf              1/1     Running     0          2m14s
```

Update the Helm Repo:

```
> helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "jumo" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
```

Search for the latest prometheus-operator:

```
> helm search stable/prometheus-operator --versions --version=">=8.5" --col-width=20
NAME                	CHART VERSION	APP VERSION	DESCRIPTION
stable/prometheus...	8.7.0        	0.35.0     	Provides easy mon...
stable/prometheus...	8.6.0        	0.35.0     	Provides easy mon...
```

Install the version of choice under the monitoring namespace:

```
> helm install stable/prometheus-operator --version 8.7.0 --name monitoring --namespace monitoring
NAME:   monitoring
LAST DEPLOYED: Thu Feb 13 07:29:37 2020
NAMESPACE: monitoring
STATUS: DEPLOYED
```

After a couple of minutes have a look at your pods under the monitoring namespace:

```
> kubectl get pods -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
monitoring-prometheus-node-exporter-9tnwl                1/1     Running   0          81s
monitoring-prometheus-node-exporter-wxd5t                1/1     Running   0          81s
monitoring-prometheus-node-exporter-ghfhp                1/1     Running   0          81s
monitoring-kube-state-metrics-56b4969bdd-v7wvt           1/1     Running   0          81s
monitoring-prometheus-oper-operator-55985bc487-94d57     2/2     Running   0          81s
alertmanager-monitoring-prometheus-oper-alertmanager-0   2/2     Running   0          62s
monitoring-grafana-7dbfdf4c7f-wc4lx                      2/2     Running   0          81s
prometheus-monitoring-prometheus-oper-prometheus-0       3/3     Running   1          52s
```

## Test with Port Forwarding

Once everything is running, test prometheus by port forwarding a host port to the container port, then access it on your browser:

```
> kubectl port-forward -n monitoring prometheus-monitoring-prometheus-oper-prometheus-0 9090:9090
Forwarding from 127.0.0.1:9090 -> 9090
```

Test Grafana by forwarding a host port to the container port:

```
> kubectl port-forward monitoring-grafana-7dbfdf4c7f-wc4lx -n monitoring 3000:3000
Forwarding from 127.0.0.1:3000 -> 3000
```

As a side note, you can get a pods name by selector:

```
> kubectl get pods --selector=app=grafana -n monitoring --output=jsonpath="{.items..metadata.name}"
monitoring-grafana-7dbfdf4c7f-wc4lx
```

## Ingress

Create ingress using Traefik:

```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: prometheus.co.local
    http:
      paths:
      - backend:
          serviceName: monitoring-prometheus-oper-prometheus
          servicePort: 9090
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: grafana.co.local
    http:
      paths:
      - backend:
          serviceName: monitoring-grafana
          servicePort: 80
```

Then deploy the ingresses:

```
> kubectl apply -f ingress.yml
ingress.extensions/prometheus-ingress created
ingress.extensions/grafana-ingress created
```

Verify that the ingresses are there:

```
> kubectl get ingress -n monitoring
NAME                 HOSTS                 ADDRESS      PORTS   AGE
prometheus-ingress   prometheus.co.local   172.26.0.3   80      17s
grafana-ingress      grafana.co.local      172.26.0.3   80      17s
```

## Passwords

Get the Grafana Username and Password:

```
> kubectl get secret/monitoring-grafana -n monitoring -o jsonpath="{.data.admin-user}" | base64 --decode -
admin

> kubectl get secret/monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode -
prom-operator
```

## Dashboards

The nice thing about this installation is that our dashboards are pre-populated:

Nodes:

<img width="1268" alt="image" src="https://user-images.githubusercontent.com/30043398/74435529-4be63000-4e6d-11ea-93cb-dcbf3396353e.png">

Compute Resources Cluster:

<img width="1264" alt="image" src="https://user-images.githubusercontent.com/30043398/74435578-6cae8580-4e6d-11ea-9924-90a7cb211c75.png">

Compute Resources Pods:

<img width="1259" alt="image" src="https://user-images.githubusercontent.com/30043398/74435684-b13a2100-4e6d-11ea-85e0-35225bc55f74.png">


