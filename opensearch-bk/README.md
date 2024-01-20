<img src="https://opensearch.org/assets/brand/SVG/Logo/opensearch_logo_default.svg" height="64px"/>


Table of Contents
=================

   * [Set up Overview](#set-up-overview)
   * [Installation](#installation)
   * [Access the cluster](#access-the-cluster)
   * [Reference links](#reference-links)

## Set up Overview

For demo purposes, I am using Rancher platform for running kubernetes (v1.24.3) cluster. The Helm chart version used for this demo for Opensearch and  OpenSearch Dashboards is 2.8.0 and 2.6.0 respectively. I have created the resources in `opensearch` namespace.

A minimum of 4GiB of memory is required. It is recommended to have 8 GiB of memory available for this setup to avoid any intermittent failures.

Please clone the github repository as we are going to make changes in the `values.yaml` which is located inside **`charts  --> opensearch`** folder.

```Shell
git clone https://github.com/opensearch-project/helm-charts.git
```

## Installation

To install the OpenSearch Helm charts, execute the following commands:

```
cd helm-charts/charts/opensearch
```

Here, we have defined persistent-volume yaml file:

```YAML
#pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: opensearch-cluster-master-pv-master
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 8Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: opensearch-cluster-master-opensearch-cluster-master-0
    namespace: opensearch
  hostPath:
    path: /tmp/mypvsc
    type: DirectoryOrCreate
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-path
  volumeMode: Filesystem
```

```
k apply -f pv.yaml
```

You can use vim editor or any text editor of your choice. Here, I have used visual studio code to edit the `values.yaml` file.

We are creating a single replica of opensearch so we have changed configuration for `singleNode` to `true` from `false` and `replicas` to `1` from `3` in `values.yaml` file.

Please save and close the `values.yaml`

To install the OpenSearch Helm charts, execute the following commands:

```
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
```

```
helm repo update
```

You can now deploy charts with this command.

```shell
 helm install opensearch-master . -f values.yaml
```

Please run following command to get the status of `opensearch-cluster-master` StatefulSet and pod:

```
kubectl get sts
```

```
NAME                        READY   AGE
opensearch-cluster-master   1/1     1m
```

```
kubectl get pod
```

```
NAME                             READY   STATUS    RESTARTS   AGE
opensearch-cluster-master-0      1/1     Running   0          1m
```

We have installed **`OpenSearch Dashboards`** with the `default` configuration by doing a Helm install.

```
helm install dashboards opensearch/opensearch-dashboards
```

Please run following command to get the status of `opensearch-dashboards` deployment and pod:

```
kubectl get deployments
```

```
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
dashboards-opensearch-dashboards   1/1     1            1           2m
```

```
kubectl get pods
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
dashboards-opensearch-dashboards-74995cf479-jhct9   1/1     Running   0          2m
opensearch-cluster-master-0                         1/1     Running   0          1m
```

## Access the cluster

1. To access the cluster locally use `kubectl` to forward it to port 9200 using the below command.

```
 kubectl port-forward opensearch-cluster-master-0 9200
```

2. Open a different tab in the terminal and run the following command to check your cluster is spinning

```
 curl -XGET https://localhost:9200 -u 'admin:admin' --insecure
```

You can also open a new browser tab and type, https://localhost:9200 in URL box.
Once asked for credentials, please provide username as `admin` and password as `admin`.

```Output
{
  "name" : "opensearch-cluster-master-0",
  "cluster_name" : "opensearch-cluster",
  "cluster_uuid" : "se6VXgQESmWGeR9Jf7Yciw",
  "version" : {
    "distribution" : "opensearch",
    "number" : "2.4.0",
    "build_type" : "tar",
    "build_hash" : "744ca260b892d119be8164f48d92b8810bd7801c",
    "build_date" : "2022-11-15T04:42:29.671309257Z",
    "build_snapshot" : false,
    "lucene_version" : "9.4.1",
    "minimum_wire_compatibility_version" : "7.10.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
```

3. To access the OpenSearch Dashboards URL locally, forward it to port 5601.

```
 kubectl get pods
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
dashboards-opensearch-dashboards-74995cf479-jhct9   1/1     Running   0          2m
opensearch-cluster-master-0                         1/1     Running   0          1m
```

After getting the pod name do a `port-forward` to 5601 by running the following command:

```
kubectl port-forward dashboards-opensearch-dashboards-74995cf479-jhct9 5601
```

4. Visit this URL http://localhost:5601/ and use username and password as “admin” to login and view OpenSearch Dashboards.
5. We can `Cancel` or `close` the next pop-up for `Select your tenant`.
6.  Click on Menu button (hamburger button) on top left side, Navigate to `Management` > `Stack Management` > `Index Patterns` and follow below images for the next steps:

![Create-Index-Pattern-Opensearch](/images/Create-Index-Pattern-Opensearch.png)

![Defined-Index-Pattern-Opensearch](/images/Defined-Index-Pattern-Opensearch.png)

![Defined-Index-Pattern-2-Opensearch](/images/Defined-Index-Pattern-2-Opensearch.png)

7. Go to the **OpenSearch Dashboards** > **Discover** to visualize the logs:
![Discover-logs-Opensearch](/images/Discover-logs-Opensearch.png)

## Reference links

[Setup OpenSearch multi-node cluster on Kubernetes using Helm Charts](https://opensearch.org/blog/technical-posts/2021/11/setup-multinode-cluster-kubernetes/)

[OpenSearch helm charts](https://github.com/opensearch-project/helm-charts)

