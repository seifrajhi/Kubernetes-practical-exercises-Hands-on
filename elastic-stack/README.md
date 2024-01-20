Table of Contents
=================

   * [What is Elasticsearch?](#what-is-elasticsearch)
   * [What is Elasticsearch used for?](#what-is-elasticsearch-used-for)
   * [How does Elasticsearch work?](#how-does-elasticsearch-work)
   * [What is an Elasticsearch index?](#what-is-an-elasticsearch-index)
   * [What is Kibana used for?](#what-is-kibana-used-for)
   * [What is Fluent Bit?](#what-is-fluent-bit)
   * [How Fluent Bit works?](#how-fluent-bit-works)
   * [Set up Kubernetes Cluster for Elasticsearch](#set-up-kubernetes-cluster-for-elasticsearch)
   * [Deploy Elasticsearch with Helm](#deploy-elasticsearch-with-helm)
   * [Install Kibana](#install-kibana)
   * [Install Fluent Bit](#install-fluent-bit)
   * [Reference links](#reference-links)


## What is Elasticsearch?

Elasticsearch is a distributed, RESTful search and analytics engine capable of addressing a growing number of use cases. 

-   Add a search box to an app or website
-   Store and analyze logs, metrics, and security event data
-   Use machine learning to automatically model the behavior of your data in real time
-   Automate business workflows using Elasticsearch as a storage engine
-   Manage, integrate, and analyze spatial information using Elasticsearch as a geographic information system (GIS)
-   Store and process genetic data using Elasticsearch as a bioinformatics research tool

As the heart of the free and open Elastic Stack, it centrally stores your data for lightning fast search, fine‑tuned relevancy, and powerful analytics that scale with ease.

Kibana enables you to interactively explore, visualize, and share insights into your data and manage and monitor the stack. 

Elasticsearch is where the indexing, search, and analysis magic happens.

## What is Elasticsearch used for?

The speed and scalability of Elasticsearch and its ability to index many types of content mean that it can be used for a number of use cases:

-   Application search
-   Website search
-   Enterprise search
-   Logging and log analytics
-   Infrastructure metrics and container monitoring
-   Application performance monitoring
-   Geospatial data analysis and visualization
-   Security analytics
-   Business analytics

## How does Elasticsearch work?

Raw data flows into Elasticsearch from a variety of sources, including logs, system metrics, and web applications. _Data ingestion_ is the process by which this raw data is parsed, normalized, and enriched before it is _indexed_ in Elasticsearch. 

Once indexed in Elasticsearch, users can run complex queries against their data and use aggregations to retrieve complex summaries of their data. 

From Kibana, users can create powerful visualizations of their data, share dashboards, and manage the Elastic Stack.

## What is an Elasticsearch index?

An Elasticsearch _index_ is a collection of documents that are related to each other. 

Elasticsearch stores data as **JSON documents**. 

Each document correlates a set of _keys_ (names of fields or properties) with their corresponding values (strings, numbers, Booleans, dates, arrays of _values_, geolocations, or other types of data).

Elasticsearch uses a data structure called an _inverted index_, which is designed to allow very fast full-text searches.

An inverted index lists every unique word that appears in any document and identifies all of the documents each word occurs in.

During the indexing process, Elasticsearch stores documents and builds an inverted index to make the document data searchable in near real-time. 

Indexing is initiated with the index API, through which you can add or update a JSON document in a specific index.

## What is Kibana used for?

Kibana is a data visualization and management tool for Elasticsearch that provides real-time histograms, line graphs, pie charts, and maps. 

Kibana also includes advanced applications such as Canvas, which allows users to create custom dynamic infographics based on their data, and Elastic Maps for visualizing geospatial data.

## What is Fluent Bit?

Fluent Bit is an open source and multi-platform log processor tool which aims to be a generic Swiss knife for logs processing and distribution.

Nowadays the number of sources of information in our environments is ever increasing.

Handling data collection at scale is complex, and collecting and aggregating diverse data requires a specialized tool that can deal with:

- Different sources of information
- Different data formats
- Data Reliability
- Security
- Flexible Routing
- Multiple destinations

Fluent Bit has been designed with performance and low resources consumption in mind.


## How Fluent Bit works?

![How fluent bit works](/images/fluentbit-works.png)

The above image represents the life cycle overview how messages are passed from various components in the Fluent Bit.

- Input : Gathers information from different sources, some of them just collect data from log files while others can gather metrics information from the operating system. There are many plugins for different needs.

- Parser : Dealing with raw strings or unstructured messages is a constant pain; having a structure is highly desired. Ideally we want to set a structure to the incoming data by the Input Plugins as soon as they are collected.

unstructured data:

```
192.168.2.20 - - [28/Jul/2006:10:27:10 -0300] "GET /cgi-bin/try/ HTTP/1.0" 200 3395
```

structured data:

```
{
  "host":    "192.168.2.20",
  "user":    "-",
  "method":  "GET",
  "path":    "/cgi-bin/try/",
  "code":    "200",
  "size":    "3395",
  "referer": "",
  "agent":   ""
 }
 ```

- Filter : In production environments we want to have full control of the data we are collecting, filtering is an important feature that allows us to alter the data before delivering it to some destination.

- Buffer : Fluent Bit offers a buffering mechanism in the file system that acts as a backup system to avoid data loss in case of system failures.

- Router : Routing is a core feature that allows to route your data through Filters and finally to one or multiple destinations. The router relies on the concept of `Tags` and `Matching rules`.

- Output : The output interface allows us to define destinations for the data. Common destinations are remote services, local file system or standard interface with others. Outputs are implemented as plugins and there are many available.

## Set up Kubernetes Cluster for Elasticsearch

Check if your cluster is functioning properly by typing:

```
kubectl cluster-info
```

Output:

```Output
Kubernetes control plane is running at https://127.0.0.1:38187
CoreDNS is running at https://127.0.0.1:38187/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

## Deploy Elasticsearch with Helm

```
helm repo add elastic https://helm.elastic.co
```

Now, use the **`curl`** command to download the **`values.yaml`** file containing configuration information:

```
curl -O https://raw.githubusercontent.com/elastic/helm-charts/main/elasticsearch/examples/kubernetes-kind/values-local-path.yaml
```

Output:

```Output
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   480  100   480    0     0   1075      0 --:--:-- --:--:-- --:--:--  1076
```

Here, we have defined persistent-volume yaml file:

```
apiVersion: v1

kind: PersistentVolume

metadata:

  labels:

    type: hostpath

  name: elasticsearch-data-quickstart-es-default-0  

spec:

  accessModes:

  - ReadWriteMany

  capacity:

    storage: 2Gi

  claimRef:

    apiVersion: v1

    kind: PersistentVolumeClaim

    name: elasticsearch-data-quickstart-es-default-0

    namespace: elasticsearch

  hostPath:

    path: /tmp/mypvsc

    type: DirectoryOrCreate

  persistentVolumeReclaimPolicy: Delete

  storageClassName: mypvsc

  volumeMode: Filesystem
```

```
k apply -f pv.yaml
```

Deploy Elasticsearch chart:

```
helm install elasticsearch elastic/elasticsearch -f ./values-local-path.yaml
```

Run the **`helm test`** command to examine the cluster’s health:

```
helm test elasticsearch
```

Output:

```Output

NAME: elasticsearch
LAST DEPLOYED: Mon Oct 31 12:15:14 2022
NAMESPACE: elasticsearch
STATUS: deployed
REVISION: 1
TEST SUITE:     elasticsearch-mpxoc-test
Last Started:   Mon Oct 31 12:20:11 2022
Last Completed: Mon Oct 31 12:20:15 2022
Phase:          Succeeded
NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=elasticsearch -l app=elasticsearch-master -w2. Test cluster health using Helm test.
  $ helm --namespace=elasticsearch test elasticsearch
```


Once you successfully installed Elasticsearch, use the `kubectl port-forward` command to forward it to **port 9200**:

```
kubectl port-forward svc/elasticsearch-master 9200
```

Run `127.0.0.1:9200` in URL box in browser:

Output:

```Output
{
  "name" : "elasticsearch-master-1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "Yi_QDvdiQoWtG8eNrNtEgQ",
  "version" : {
    "number" : "7.17.3",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "5ad023604c8d7416c9eb6c0eadb62b14e766caff",
    "build_date" : "2022-04-19T08:11:19.070913226Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Install Kibana

1. To install Kibana on top of Elasticsearch, type the following command:

```
helm install kibana elastic/kibana
```

The output confirms the deployment of Kibana:

```Output
NAME: kibana
LAST DEPLOYED: Mon Oct 31 12:36:25 2022
NAMESPACE: elasticsearch
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

2. Check if all the pods are ready:

```
kubectl get pods
```

Kibana pod appears underneath the Elasticsearch pods:

```
NAME                            READY   STATUS    RESTARTS   AGE
elasticsearch-master-0          1/1     Running   0          22m
elasticsearch-master-1          1/1     Running   0          22m
elasticsearch-master-2          1/1     Running   0          22m
kibana-kibana-95dc995b9-s9kj7   1/1     Running   0          87s
```

<center>OR</center>
We can check the Kibana deployment:

```
kubectl get deployments
```

Output:

```Output
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
kibana-kibana   1/1     1            1           2m4s
```

3. Forward Kibana to **port 5601** using **`kubectl`**:

```
kubectl port-forward deployment/kibana-kibana 5601
```

4. Setting up port-forwarding, access Elasticsearch and the Kibana GUI by typing in URL box:

```
http://127.0.0.1:5601
```

## Install Fluent Bit

1. To add the fluent helm repo, run:

```
helm repo add fluent https://fluent.github.io/helm-charts
```

2. To install a release named fluent-bit, run:

```
helm install fluent-bit fluent/fluent-bit
```

3. To see fluent-bit DaemonSet:

```
kubectl get ds
```

4. Visit [Kibana](http://127.0.0.1:5601). You will now be able to create an index pattern. Navigate to **`Management`** > **`Stack Management`** > **`Index patterns`**:

![Index-Pattern.png](/images/Index-Pattern.png)

![Create-Index-Pattern.png](/images/Create-Index-Pattern.png)

5. Click the **`Create Index Pattern`** button to start working with Kibana.
6.  Go to the **Analytics** > **Discover** to visualize the logs:

![Discover-logs](/images/Discover-logs.png)


## Reference links

[What is Elasticsearch?](https://www.elastic.co/what-is/elasticsearch)

[Elasticsearch Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/elasticsearch-intro.html)

[Fluent Bit docs](https://docs.fluentbit.io/manual/)

