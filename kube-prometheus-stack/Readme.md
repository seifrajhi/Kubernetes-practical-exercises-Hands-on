Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [What is Prometheus?](#what-is-prometheus)
  - [Features](#features)
  - [Architecture](#architecture)
- [What is Grafana?](#what-is-grafana)
  - [Why use Grafana?](#why-use-grafana)
- [kube-prometheus-stack](#kube-prometheus-stack)
  - [Prerequisites](#prerequisites)
  - [Get Helm Repository Info](#get-helm-repository-info)
  - [Reference links](#reference-links)


# What is Prometheus?

Prometheus is an open-source systems monitoring and alerting toolkit.

It collects and stores its metrics as time series data, i.e. metrics information is stored with the timestamp at which it was recorded, alongside optional key-value pairs called labels.

## Features

Prometheus's main features are:

- a multi-dimensional data model with time series data identified by metric name and key/value pairs
- PromQL, a flexible query language to leverage this dimensionality
- no reliance on distributed storage; single server nodes are autonomous
- time series collection happens via a pull model over HTTP
- pushing time series is supported via an intermediary gateway
- targets are discovered via service discovery or static configuration
- multiple modes of graphing and dashboarding support

## Architecture

This diagram illustrates the architecture of Prometheus and some of its ecosystem components:

![prometheus-architecture](/images/prometheus-architecture.png)

# What is Grafana?

Grafana enables you to query, visualize, alert on, and explore your metrics, logs, and traces wherever they are stored. 

Grafana provides you with tools to turn your time-series database (TSDB) data into insightful graphs and visualizations.

## Why use Grafana?

- **Unifying the existing data from multiple sources(Kubernetes cluster, different cloud services, etc..) and visualize it from the single dashboard.**

- **Easily accessible and visualization of data.**

- **Insightful dashboard created from the provided data sources.**

- **Translate and transform any of your data into flexible and versatile dashboards.**

- **With advanced querying and transformation capabilities, you can customize your panels to create visualizations that are actually helpful for you.**

# kube-prometheus-stack

A collection of Kubernetes manifests, Grafana dashboards, Alert manager and Prometheus rules, which will allow us to visualize, query, and alert metrics.

## Prerequisites

-   Kubernetes 1.16+
-   Helm 3+

To monitor the kubernetes cluster, we are going to need a cluster up and running.

```
kubectl get nodes
```

We are going to use the helm package manager to install kube prometheus stack.

## Get Helm Repository Info

Here, we will fetch the `kube-prometheus-stack` packages from a  `prometheus-community` repository, and download it locally.
 
```
helm pull prometheus-community/kube-prometheus-stack
```

Please extract `kube-prometheus-stack` and go to the directory.

Here, we will add the chart repository.

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

The following command  will update the local repository with the latest version:

```
helm repo update
```

Here, we will create a namespace to avoid installing on default namespace:

```
kubectl create namespace monitoring
```

Here, we will verify the namespace that it is created:

```
kubectl get namespace
```

For secure password, we will create a secret named `grafana-admin-credentials` and store it in kubernetes and use that secret for grafana dashboard sign-in.

Echo username and password to a file:

```
echo -n 'adminuser' > ./admin-user # change your username 
```

```
cat admin-user
```

```
echo -n 'p@ssw0rd1!' > ./admin-password # change your password
```

```
 cat admin-password
```

Here, we will create a kubernetes secret:

```
kubectl create secret generic grafana-admin-credentials --from-file=./admin-user --from-file=admin-password -n monitoring
```

Output:

```
secret/grafana-admin-credentials created
```

We can verify the secret:

```
kubectl describe secret -n monitoring grafana-admin-credentials
```

Output:

```
Name:         grafana-admin-credentials
Namespace:    monitoring
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
admin-password:  10 bytes
admin-user:      9 bytes
```

We can see the `grafana-admin-credentials` json output:

```
k get secrets grafana-admin-credentials -o json
```

Output:

```json
{
    "apiVersion": "v1",
    "data": {
        "admin-password": "cEBzc3cwcmQxIQ==",
        "admin-user": "YWRtaW51c2Vy"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-10-06T05:18:57Z",
        "name": "grafana-admin-credentials",
        "namespace": "monitoring",
        "resourceVersion": "17245153",
        "uid": "e0e524ea-5805-4f37-b043-ce33c9cb6286"
    },
    "type": "Opaque"
}
```

Here, we will decode the `admin-user` property from base64 as the secrets are encoded with base64:

```
kubectl get secret -n monitoring grafana-admin-credentials -o jsonpath="{.data.admin-user}" | base64 --decode
````

Output:

```
adminuser%
```

Here, we will decode the `admin-password` property from base64

```
kubectl get secret -n monitoring grafana-admin-credentials -o jsonpath="{.data.admin-password}" | base64 --decode
```

Output:

```
p@ssw0rd1!%
```

Remove username and password file from filesystem:

```
rm admin-user && rm admin-password
```

Here, we have provided release name: `prometheus` , repository name: `prometheus-community/kube-prometheus-stack` and we have mentioned `values.yaml` file that we have modified:

Install command:

```
helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack -f values.yaml
```

Here, we will list down the resources that have been deployed:

```
kubectl get deployments
```

```
kubectl get pods
```

```
kubectl get ds
```

```
kubectl get rs
```

```
kubectl get sts
```

```
kubectl get svc
```

Here, we are going to port-forward:

```
kubectl port-forward -n monitoring [grafana-pod-name] 8080:3000
```

Now, go to your browser:

```
http://localhost:8080
```

Enter your grafana username and password.

Now, you will be able to browse through dashboards.


## Reference links

- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)

- [Grafana Overview](https://grafana.com/grafana/)

- [Dashboards with Grafana and Prometheus - Monitoring](https://www.youtube.com/watch?v=fzny5uUaAeY)

- [kube-grafana-prometheus documentation](https://docs.technotim.live/posts/kube-grafana-prometheus/)

- [updated yaml file](https://github.com/techno-tim/launchpad/blob/master/kubernetes/kube-prometheus-stack/values.yml)
				       


