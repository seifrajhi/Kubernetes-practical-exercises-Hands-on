<div align=center>
  
## DaemonSet

</div>

A DaemonSet is a Kubernetes workload that ensures that a specified number of copies of a Pod are running on each node in a Kubernetes cluster. The main use case for DaemonSets is to run system-level services on each node, such as a logging or monitoring agent.

To create a DaemonSet we can use the kubectl command-line tool to deploy a manifest file that defines the DaemonSet. Lets see an example manifest file that creates a DaemonSet that runs the nginx web server on each node in the cluster:

![1 ds](https://user-images.githubusercontent.com/58173938/206950618-57307d14-bc7e-422d-8321-ea79461b9961.png)

![2 created](https://user-images.githubusercontent.com/58173938/206950691-50c5bc7e-34c6-4534-84ad-6fb7521086fa.png)

After the DaemonSet is deployed we can verify that the nginx Pods are running on each node in the cluster by running the following command:

```yaml
kubectl get pods -o wide
```
This command yamlould yamlow a list of all the Pods in the cluster, along with the node that each Pod is running on. The Pods created by the DaemonSet yamlould be listed as running on each node in the cluster.

![3 running](https://user-images.githubusercontent.com/58173938/206951062-005b26ed-c604-4f3c-989a-be8512bedcef.png)

In addition to running system-level services, DaemonSets can also be used to run other types of workloads on each node in a cluster. For example we could use a DaemonSet to run a batch processing job on each node in the cluster, or to run a distributed in-memory cache. The main advantage of using a DaemonSet is that it ensures that the specified number of Pods are running on each node in the cluster, making it easy to deploy and manage workloads at a large scale.

To deploy a certain number of Pods on each node using a DaemonSet we can specify the replicas field in the DaemonSet's manifest file. The replicas field specifies the number of copies of the Pod that yamlould be running on each node in the cluster.

Lets see an example manifest file that deploys two copies of the nginx web server on each node in the cluster:

![4 daemonset with replicas](https://user-images.githubusercontent.com/58173938/206952187-264461e8-18a8-44b3-845d-434f11ab7b0d.png)

To deploy the DaemonSet we can run the following command:

```yaml
kubectl apply -f daemonset-with-numberof-repl.yaml
```
After the DaemonSet is deployed we can verify that two copies of the nginx Pods are running on each node in the cluster by running the following command:

```yaml
kubectl get pods -o wide
```

This command yamlould yamlow a list of all the Pods in the cluster, along with the node that each Pod is running on. The Pods created by the DaemonSet yamlould be listed as running on each node in the cluster, with two copies of the Pod on each node.

In this example, the DaemonSet ensures that two copies of the nginx Pod are running on each node in the cluster. This is useful i we want to ensure that there are always two instances of the nginx web server available for handling incoming requests we can adjust the number of replicas as needed to meet the specific requirements of our application.

we can also run a storage daemon on every node in the cluster, so tha we can provide network-attached storage to our containers. we need a container image because it allow we to package the storage daemon and all of its dependencies into a single, easily deployable unit. This makes it much easier to manage and run the storage daemon, sinc we can deploy it to any node in our cluster simply by pulling the container image and running it as a container.

To run a storage daemon using a DaemonSet in Kubernetes we need to do the following:

- Create a container image for our storage daemon, and puyaml it to a container registry.

- Create a Kubernetes deployment file that describes our storage daemon, including the container image, resource requirements, and any necessary configuration settings.

- Use the kubectl command-line tool to create a DaemonSet from our deployment file, specifying tha we want one instance of the storage daemon to run on each node in the cluster.

- Use the kubectl tool to check the status of the DaemonSet, and verify that an instance of the storage daemon is running on each node in the cluster.

Here is an example deployment file for a storage daemon using a DaemonSet:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: storage-daemon
spec:
  selector:
    matchLabels:
      app: storage-daemon
  template:
    metadata:
      labels:
        app: storage-daemon
    spec:
      containers:
      - name: storage-daemon
        image: registry.example.com/storage-daemon:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        volumeMounts:
        - name: storage-daemon-config
          mountPath: /etc/storage-daemon
          readOnly: true
      volumes:
      - name: storage-daemon-config
        configMap:
          name: storage-daemon-config
          items:
          - key: config.json
            path: config.json
```

This deployment file defines a DaemonSet named storage-daemon, which runs a container named storage-daemon from the specified image. It also defines resource requirements and mounts a volume containing configuration settings for the storage daemon.

To create the DaemonSet we would run the following kubectl command:

```yaml
kubectl create -f storage-daemon-deployment.yaml
```

To check the status of the DaemonSet we would run the following kubectl command:

```yaml
kubectl describe daemonset storage-daemon
```

This would display information about the DaemonSet, including the number of nodes that it is running on and the status of the pods.

## ❤ show your support

Give a ⭐️ if this project helped you, Happy learning!
