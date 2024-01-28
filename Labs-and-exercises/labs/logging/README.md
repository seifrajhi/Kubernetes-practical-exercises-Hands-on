# Centralized Logging with Elasticsearch, Fluentd and Kibana (EFK)

It's difficult to work with Pod logs at scale - Kubectl doesn't let you search or filter log entries. The production-ready option is to run a central logging subsystem, which collects all Pod logs and stores them in a central database. EFK is the usual system for doing that in Kubernetes.

## Reference

- [Kubernetes logging architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/#logging-at-the-node-level)
- [Fluent Bit configuration for Kubernetes](https://docs.fluentbit.io/manual/installation/kubernetes) 

<details>
  <summary>Fluent Bit configuration</summary>

Fluent Bit is a streamlined log collector which evolved from Fluentd. It will run as a Pod on every node, collecting that nodes container logs. Fluent Bit uses a pipeline to process logs. This input block reads container log files from the nodes:

```
[INPUT]
  Name              tail
  Tag               kube.<namespace_name>.<container_name>.<pod_name>.<container_id>-
  Tag_Regex         (?<pod_name>[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?://.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<container_id>[a-z0-9]{64})/.log$
  Path              /var/log/containers/*.log
```

- `tail` reads files, watching them for new content
- `path` is where the container runtime stores log files
- `Tag_Regex` extracts metadata from the log file name

This output block saves each log line as a document in Elasticsearch:

```
[OUTPUT]
  Name            es
  Match           kube.default.*
  Host            elasticsearch
  Index           app-logs
  Generate_ID     On
```

- `Match` selects logs from Pods in the default namespace
- `Host` is the DNS name of the Elasticsearch server
- `Index` is the name of the index where documents get created

</details><br/>

## Finding Pod logs

We'll start by seeing how Kubernetes stores container logs on the node where the Pod is running.

The fulfiment API is a simple REST API which write log entries - there's nothing special in the manifest:

- [fulfilment-api/deployment.yaml](./specs/fulfilment-api/deployment.yaml) - runs a single Pod with no extra logging configuration

📋 Deploy the app and check the logs it prints at startup

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/logging/specs/fulfilment-api

kubectl logs -l app=fulfilment,component=api
```

This is a Java Spring Boot app - you'll see a set of startup logs.

</details><br/>

The log entries are stored in the filesystem of the node that runs the Pod. You might not have access to the filesystem directly, but you can get it using a volume:

- [jumpbox/pod.yaml](./specs/jumpbox/pod.yaml) - mounts the log paths from the node into the container filesystem

_Run the Pod and use it to examine the log files on the node:_

```
kubectl apply -f labs/logging/specs/jumpbox

kubectl exec -it jumpbox -- sh

ls /var/log/containers

# use cat to read the contents of API log

exit
```

> Each container on the node has a .log file

Files are named with a pattern:

- `fulfilment-processor-7695b895d7-h878q_default_app-260923b9ceb2c8223ebff38c2c3d81c2cd6301edfb3ae88ddebb1d1a6a19ad2c.log`

- `[pod-name]_[namespace]_[container_name]_[container-id]`

That's the pattern Fluent Bit will use to add metadata to each log entry.

## Run the EFK stack

Logging is a cluster-wide concern and we'll run it in a separate namespace:

- [logging/fluentbit.yaml](./specs/logging/fluentbit.yaml) - runs Fluent Bit in a DaemonSet so there's a Pod on each node, mounting the log path volumes

- [logging/fluentbit-config.yaml](./specs/logging/fluentbit-config.yaml) - sets the Fluent Bit pipeline in a ConfigMap; logs are collected from two namespaces

- [logging/elasticsearch.yaml](./specs/logging/elasticsearch.yaml) - runs the latest OSS version of Elasticsearch

- [logging/kibana.yaml](./specs/logging/kibana.yml) - runs the latest OSS version of Kibana

📋 Which namespaces will have logs collected, and which indices will the log documents be stored in?

<details>
  <summary>Not sure?</summary>

There are two output blocks in the ConfigMap:

```
    [OUTPUT]
        Name            es
        Match           kube.default.*
        Host            elasticsearch
        Index           app-logs
        Generate_ID     On

    [OUTPUT]
        Name            es
        Match           kube.kube-system.*
        Host            elasticsearch
        Index           sys-logs
        Generate_ID     On
```

The `Match` uses tag metadata which includes the namespace. Logs from the `default` namespace will be stored in the `app-logs` index and logs from `kube-system` will be stored in the `sys-logs` index.

</details><br/>

_Deploy the app and wait for the Pods to be ready:_

```
kubectl apply -f labs/logging/specs/logging

kubectl get all -n logging
```

Elasticsearch uses a REST API on port 9200 to insert & query data. We can use it from the jumpbox Pod.

Generate some application logs by making a call to the fulfilment REST API:

```
# you can use the NodePort address:
curl http://localhost:30018/documents

# or the LoadBalancer
curl http://localhost:8011/documents
```

📋 Connect to the jumpbox Pod and make an HTTP request with curl, to the `/_cat/indices` path on the Elasticsearch Pod.

<details>
  <summary>Not sure how?</summary>

First exec into a shell session on the Pod:

```
kubectl exec -it jumpbox -- sh
```

The container image has curl installed - you need to use the fully-qualified domain name for the Elasticsearch Service, and the port:

```
curl http://elasticsearch.logging.svc.cluster.local:9200/_cat/indices

exit
```

</details><br/>

> The output shows a list of indices, which includes where logs are stored:

```
yellow open app-logs  85auSZIAQ2SYpflMN7NYGQ 5 1 12984 0   3.4mb   3.4mb
yellow open sys-logs  aKQAl5XvQWaC30upiwo71Q 5 1   106 0 658.9kb 658.9kb
green  open .kibana_1 bEezIodMQ_6FoJ8cQ5mP5A 1 0     0 0    230b    230b
```

You can do everything with the REST API, but the Kibana UI is much easier to use.

## View application logs in Kibana

Browse to Kibana on http://localhost:5601 or http://localhost:30016 

From the left menu:

- Click _Stack Management_
- Then _Index Patterns_
- Click _Create index pattern_
  - Use the name `app-logs`
  - And select time field `@timestamp`

Now from the left menu

- Click _Discover_

> You can see all the container logs, plus metadata (namespace, pod, image etc.)

Make another call to the Spring Boot API:

```
curl localhost:30018/documents
```

Click _Refresh_ in Kibana and you'll see a log entry recording the HTTP request you just made.

## Add system logs to Kibana

Index patterns in Kibana are used to query data in Elasticsearch. System component logs are being stored in a different index, so you need a new index pattern.

From the left menu:

- Click _Stack Management_
- Then _Index Patterns_
- Click _Create index pattern_
  - Use the name `sys-logs`
  - And select time field `@timestamp`

Switch to the Discover tab and choose the new index pattern. Kibana is pretty user friendly and this is a good place to explore your logs.

📋 Filter the entries to show logs from Kubernetes API server.

<details>
  <summary>Not sure how?</summary>

Click on the field `kubernetes.labels.component`, and you'll see all the values.

Click the + next to `kube-apiserver` to see the API logs

</details><br/>

You'll see log entries about core system processes.

## Lab 

This is a generic log collection system which will fetch logs from every Pod - but all not Pods generate logs:

- [fulfilment-processor/deployment.yaml](./specs/fulfilment-processor/deployment.yaml) - runs a background processor which doesn't generate any logs

Start by running the app:

```
kubectl apply -f labs/logging/specs/fulfilment-processor
```

Check the logs with Kubectl and Kibana - there are none for this new component:

```
kubectl logs -l app=fulfilment,component=processor
```

The application does write logs, to a file in the container filesystem:

```
kubectl exec deploy/fulfilment-processor -- cat /app/logs/fulfilment-processor.log
```

Your task is to extend the Pod spec so those logs are pulled out and published as Pod logs.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup


```
kubectl delete ns,deploy,svc,po -l kubernetes.courselabs.co=logging
```