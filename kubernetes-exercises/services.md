# Services

## Learning Goals

- Communicate between pods internally in the cluster.
- Reach pods from outside the cluster.
- Understand service discovery.

## Introduction

In this exercise you'll learn about how pods can be exposed using services and test connectivity between them.

## Service Discovery & Services

One of the features of Kubernetes is that we do not have to care on which machine our pods are running.
This does create an interesting problem for us - if we don't know where (the IP address) the pod is, how can we route traffic to it?
This is solved by what is called **service discovery**, as the words imply, Kubernetes will look for your pods, and dynamically route traffic to them.

This is achieved using the Kubernetes kind `service`, which is a network abstraction for service discovery (and more!).

The `service` receives a static IP address that will not change throughout the life cycle of the service, so while the pod IP addresses might change, the `service` will not.

Service discovery works in Kubernetes by putting `labels` on pods, and then using a `selector` in the `service` to match the same labels.
This is handled by the Kubernetes API, which means that we only need to know the labels of the pods we want to send traffic to, and Kubernetes will take of the rest!

The `service` then routes traffic the pods that it selects, you can think of `service` as a kind of proxy - you route traffic to the service, and the service routes the traffic to your pods.

While the `service` gets a static IP address we actually prefer not use it, because Kubernetes actually runs its own DNS server in the cluster network, and every time we create a `service` a DNS record is created that points to the `service` IP address.
The DNS record is always the `name` of the service, and can be referenced either from the same namespace by using the name or from a different namespace by using the long form: `<name>.<namespace>.svc.cluster.local`.

<details>
<summary>
Example
</summary>

An Example `pod` with labels

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: frontend # <-- These labels are selected by the service
    environment: dev
  name: frontend
spec:
  containers:
    - image: ghcr.io/eficode-academy/quotes-flask-frontend:release
      name: frontend
      resources: {}
```

An example `service` that selects the labels of the pod

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  ports:
    - port: 5000
      protocol: TCP
      targetPort: 5000
  selector:
    app: frontend # <-- The service selects pods that have this list of labels
    environment: dev
  type: ClusterIP
```

</details>

## `service` Types

Since Kubernetes can recreate pods at any time, it is not a good idea to rely on the IP address of a pod.
Instead, we can create a service that will expose the pod(s) to the outside world.
The service IP address will not change, even if the pod(s) it is exposing are destroyed and recreated.
It will only change if the service is deleted and recreated.

The service also load balances traffic between the pods it is exposing if there are more than one pod.

The service finds the pods it is exposing by using labels. The service will expose all pods that have the labels specified in the `selector` part of the service.

### `service` Manifest

A generic service manifest file looks like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels: # list of labels for this service
  name: # Service name
spec:
  ports: # Ports to expose
    - port:
      protocol: # TCP or UDP
      targetPort: # Pod port to route to
  selector: # List of labels to match pods
  type: # ClusterIP, NodePort or LoadBalancer
```

Here is an example `service` manifest:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: backend
  name: backend
spec:
  ports:
    - port: 5000
      protocol: TCP
      targetPort: 5000
  selector:
    app: backend
  type: ClusterIP
```

Services come in three types: `ClusterIP`, `NodePort` and `LoadBalancer`.

### Service type: ClusterIP

The `ClusterIP` service type is for routing internal network traffic between pods in the cluster.

We can use either the static IP address or the DNS name to route traffic between pods.

We prefer to use the DNS name, because we know what it will be _before_ the service is created and receives a random static IP address.

The `ClusterIP` service type does not allow for any communication from clients outside the cluster.

<details>
    <summary> :bulb: More about ClusterIP</summary>

The service type ClusterIP does not have any external IP. This means it is not accessible over the internet, but we can still access it from within the cluster using its `CLUSTER-IP`.

- The IPs assigned to services as Cluster-IP are from a different Kubernetes network called _Service Network_, which is a completely different network altogether. i.e. it is not connected (nor related) to pod-network or the infrastructure network. Technically it is actually not a real network per-se; it is a labeling system, which is used by Kube-proxy on each node to setup correct iptables rules. (This is an advanced topic, and not our focus right now).
- No matter what type of service you choose while _exposing_ your pod, Cluster-IP is always assigned to that particular service.
- Every service has end-points, which point to the actual pod serving as a backend of a particular service.
- As soon as a service is created, and is assigned a Cluster-IP, an entry is made in Kubernetes' internal DNS against that service, with this service name and the Cluster-IP. e.g. `backend.default.svc.cluster.local` would point to Cluster-IP `172.20.114.230` .

</details>

### Service type: NodePort

Services of type `NodePort` have all of the functionality of `ClusterIP` services, but add more functionality: it will also open up a port on each node in the cluster, which will route traffic to the service.

For example a `NodePort` service might open port `32593` on all nodes, and route traffic from this port to the service.

So now, if we know the IP of our nodes (and they are externally accessible), we can access this service from the internet.

### Other types

There are other types of services, like `LoadBalancer`, but we won't cover them in this exercise.

If you want to know more about Services, you can read more about them [here](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types).

> :bulb: Hint: You can use the `kubectl explain` command to get more information about the fields in the yaml file. For example, `kubectl explain service.spec` will give you more information about the spec field in the service yaml file.

## Exercise

In this exercise you will start both the frontend and backend quotes-flask pods.

### Overview

- Apply both frontend and backend pods
- Create backend service with type ClusterIP
- Exec into frontend pod, reach backend through service DNS name
- Create frontend service with type NodePort
- Access it from the nodes IP address

:bulb: If you get stuck somewhere along the way, you can check the solution in the done folder.

### Step by step instructions

<details>
<summary>
Step by step:
</summary>

- Go into the `services/start` directory.
- Apply the `backend-pod.yaml` & `frontend-pod.yaml` files.

<details>
<summary>:bulb: Hint </summary>

You can use the `kubectl apply -f <file>` command to deploy the pod.
The pod is defined in the `backend-pod.yaml` file.
Hint: the apply command can take more than one `-f` parameter to apply more than one yaml file

</details>

- Check that the pods are running with `kubectl get pods` command.

You should see something like this:

```
NAME          READY   STATUS    RESTARTS   AGE
pod/backend   1/1     Running   0          28s
pod/frontend  1/1     Running   0          20s
```

Now that we have the pods running, we can create a service that will expose the backend pod to the cluster network, so we will create a service of type `ClusterIP`.

- Open the `backend-svc.yaml` file and fill in the missing parts.
- apiVersion and kind are already filled in for you.
- Metadata section should have the name `backend` and a label with key `run` and value `backend`.
- Spec section should have a port with port `5000`, protocol `TCP` and targetPort `5000`.
- Selector section should have a label with key `run` and value `backend`.
- Type should be `ClusterIP`.

> :bulb: If you get stuck somewhere along the way, you can check the solution in the done folder.

- Apply backend-svc.yaml that you just created. `kubectl apply -f backend-svc.yaml`

- Check that the service is created with `kubectl get services` command.

You should see something like this:

```
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/backend   ClusterIP   172.20.114.230   <none>        5000/TCP   23s
```

- Exec into frontend pod
  `kubectl exec -it frontend -- bash`

You should see something like this:

```
root@frontend:/app#
```

Make sure that you are inside a pod and not in your terminal window.

- Try to reach backend pod through backend service `Cluster-IP` from within your frontend pod

```sh
curl 172.20.114.230:5000
```

You should see something like this:

```
Hello from the backend!
```

- Try accessing the service using dns name now

```sh
curl backend:5000
```

You should see the same output as above.

You can type `exit` or press `Ctrl-d` to exit from your container.

- Next we create the service file for the frontend with type `NodePort`.

- While we can write manifests by hand, we can also use some tricks to generate boilerplate manifests: For example we can use the `kubectl expose` command to create a service from a pod or deployment.

> For example, `kubectl expose pod frontend --type=NodePort --port=5000` will create a service for the frontend pod with type NodePort and port 5000.
> We can then use Unix shell pipes (`>`) to direct the output of the command to a file, e.g. `<command> > <file>`
> We run `kubectl expose` with the arguments `--dry-run=client -o yaml` to only perform the operation locally without sending the result to the server, and formatting the output as `yaml`.

- Create the frontend service manifest with the command above: `kubectl expose pod frontend --type=NodePort --port=5000 -o yaml --dry-run=client > frontend-svc.yaml`

- Apply frontend-svc.yaml that you just created.

- Check that the service is created with `kubectl get services` command.

You should see something like this:

```
NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
frontend          NodePort    10.106.136.250   <none>        5000:31941/TCP   23s
service/backend   ClusterIP   172.20.114.230   <none>        5000/TCP         23s
```

- Note down the port number for the frontend service. In this case it is `31941` (yours will be different).

- Get the nodes IP address. Run `kubectl get nodes -o wide`.

You should see something like this:

```
NAME                                        STATUS   ROLES    AGE    VERSION               INTERNAL-IP   EXTERNAL-IP      OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
ip-10-0-33-234.eu-west-1.compute.internal   Ready    <none>   152m   v1.23.9-eks-ba74326   10.0.33.234   54.194.220.73    Amazon Linux 2
5.4.219-126.411.amzn2.x86_64   docker://20.10.17
ip-10-0-38-95.eu-west-1.compute.internal    Ready    <none>   152m   v1.23.9-eks-ba74326   10.0.38.95    34.244.123.152   Amazon Linux 2
5.4.219-126.411.amzn2.x86_64   docker://20.10.17
ip-10-0-57-206.eu-west-1.compute.internal   Ready    <none>   152m   v1.23.9-eks-ba74326   10.0.57.206   34.242.240.121   Amazon Linux 2
5.4.219-126.411.amzn2.x86_64   docker://20.10.17
ip-10-0-62-15.eu-west-1.compute.internal    Ready    <none>   152m   v1.23.9-eks-ba74326   10.0.62.15    54.246.17.102    Amazon Linux 2
5.4.219-126.411.amzn2.x86_64   docker://20.10.17
```

Copy the external IP address of any one of the nodes, for example, `34.244.123.152` and paste it in your browser.

Copy the port from your frontend service that looks something like `31941` and paste it after to your IP in the browser, separated by a colon (`:`), for example `34.244.123.152:31941` and load the page.

Alternatively, you could also test it using curl from your terminal window.

```sh
curl 34.244.123.152:31941 | grep h1
```

You should see something like this:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3051  100  3051    0     0   576k      0 --:--:-- --:--:-- --:--:--  595k
        <h1>Programming Quotes</h1>
```

<details>
<summary>
:bulb: Food for thought
</summary>

Think about why you didn't need to exec into a pod to test frontend service but needed it to test the backend service.

</details>

</details>

### Clean up

Delete the pods and services with `kubectl delete pod frontend backend` and `kubectl delete service frontend backend` commands.

You have successfully tested connectivity between frontend and backend pods using services.

### Extra: Filter on the basis of labels

<details>
<summary>
Optional extra exercise
</summary>

To filter the output of `kubectl get pods` based on a `label`, you can use the `--selector` flag followed by the label key and value.
For example, to filter the pods based on a label with the key foo and the value bar, you would run the following command:

`kubectl get pods --selector=foo=bar`

This will return a list of all the pods that have a label with the key foo and the value bar.

You can use the != operator to specify that you want to exclude resources with a particular label value.
For example, to filter the pods based on a label with the key foo but exclude those with the value bar, you would run the following command:

`kubectl get pods --selector=foo!=bar`

Try to apply the manifests again and write four commands that does the following:

- List only the pods with the label app=frontend
- List only the pods with the label app=backend
- List only the pods where label app is not frontend
- List only the pods where label app is not backend

The documentation on this can be found here: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/

Remember to clean up after you are done.

</details>
