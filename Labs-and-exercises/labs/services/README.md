# Networking Pods with Services

Every Pod has an IP address which other Pods in the cluster can reach, but that IP address only applies for the life of the Pod.

[Services](https://kubernetes.io/docs/concepts/services-networking/service/) provide a consistent IP address linked to a DNS name, and you'll always use Services for routing internal and external traffic into Pods.

Services and Pods are loosely-coupled: a Service finds target Pods using a [label selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).

## API specs

- [Service](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#service-v1-core)

<details>
  <summary>YAML overview</summary>

Service definitions have the usual metadata. The spec needs to include the network ports and the label selector:

```
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  selector:
    app: whoami
  ports:
    - name: http
      port: 80
      targetPort: 80
```

The ports are where the Service listens, and the label selector can match zero to many Pods.

* `selector` - list of labels to find target Pods
* `ports` - list of ports to listen on
* `name` - port name within Kubernetes
* `port` - port the Service listens on
* `targetPort` - port on the Pod where traffic gets sent

## Pod YAML

Pods need to include matching labels to receive traffic from the Service.

Labels are specified in metadata:

```
apiVersion: v1
kind: Pod
metadata:
  name: whoami
  labels:
    app: whoami
spec:
  # ...
```

> Labels are abitrary key-value pairs. `app`, `component` and `version` are typically used for application Pods.

</details><br/>

## Run sample Pods

Start by creating some simple Pods from definitions which contain labels:

* [whoami.yaml](specs/pods/whoami.yaml)
* [sleep.yaml](specs/pods/sleep.yaml)

```
kubectl apply -f labs/services/specs/pods
```

> You can work with multiple objects and deploy multiple YAML manifests with Kubectl

📋 Check the status for all Pods, printing all the IP addresses and labels.

<details>
  <summary>Not sure how?</summary>

```
kubectl get pods -o wide --show-labels
```

</details><br/>

The Pod name has no affect on networking, Pods can't find each other by name:

```
kubectl exec sleep -- nslookup whoami
```

## Deploy an internal Service

Kubernetes provides different types of Service for internal and external access to Pods. 

[ClusterIP](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/) is the default and it means the Service gets an IP address which is only accessible within the cluster - its for components to communicate internally.

* [whoami-clusterip.yaml](specs/services/whoami-clusterip.yaml) defines a ClusterIP service which routes traffic to the whoami Pod

📋 Deploy the Service from `labs/services/specs/services/whoami-clusterip.yaml` and print its details.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/services/specs/services/whoami-clusterip.yaml
```

Print the details:

```
kubectl get service whoami

kubectl describe svc whoami
```

> The `get` and `describe` commands are the same for all objects; Services have the alias `svc`

</details><br/>

The Service has its own IP address, and that is static for the life of the Service.

## Use DNS to find the Service

Kubernetes runs a DNS server inside the cluster and every Service gets an entry, linking the IP address to the Service name.

```
kubectl exec sleep -- nslookup whoami
```

> This gets the IP address of the Service from its DNS name. The first line is the IP address of the Kuberentes DNS server itself.

Now the Pods can communicate using DNS names:

```
kubectl exec sleep -- curl -s http://whoami
```

📋 Recreate the whoami Pod and the replacement will have a new IP address - but service resolution with DNS still works. 

<details>
  <summary>Not sure how?</summary>

Check the current IP address then delete the Pod:

```
kubectl get pods -o wide -l app=whoami

kubectl delete pods -l app=whoami
```

> You can use label selectors in Kubectl too - labels are a powerful management tool

Create a replacement Pod and check its IP address:

```
kubectl apply -f labs/services/specs/pods

kubectl get pods -o wide -l app=whoami
```

</details><br/>

The Service IP address doesn't changed, so if clients cache that IP they'll still work. Now the Service routes traffic to the new Pod:

```
kubectl exec sleep -- nslookup whoami

kubectl exec sleep -- curl -s http://whoami
```

## Understanding external Services

There are two types of Service which can be accessed outside of the cluster: [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/) and [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport).

They both listen for traffic coming into the cluster and route it to Pods, but they work in different ways. LoadBalancers are easier to work with, but not every Kubernetes cluster supports them.

> In this course we'll deploy both LoadBalancers and NodePorts for all our sample apps so you can follow along with your cluster.

<details>
  <summary>ℹ Here's why some clusters don't support LoadBalancers</summary>

- LoadBalancer Services integrate with the platform they're running on to get a real IP address. In a managed Kubernetes service in the cloud you'll get a unique public IP address for every Service, integrated with a cloud load balancer to direct traffic to your nodes. In Docker Desktop the IP address will be `localhost`; in k3s it will be a local network address.

- NodePorts don't need any external setup so they work in the same way on all Kubernetes clusters. Every node in the cluster listens on the specified port and forwards traffic to Pods. The external port number must be >= 30000 - a security feature so Kubernetes components don't need to run with elevated privileges on the node.

Platform | LoadBalancer | NodePort 
--- | --- | --- |
Docker Desktop | ✔ | ✔
K3s  | ✔ | ✔
K3d  | 🌓 | ✔
AKS, EKS, GKE etc.  | ✔ | ✔
Kind | ❌ | ✔
Minikube | ❌  |  ✔
Microk8s | ❌  |  ✔
Bare-metal | ❌  |  ✔

> If you don't have LoadBalancer support you can add it with [MetalLB](https://metallb.universe.tf/), but that's not in scope for this course :)

</details><br/>

## Deploy an external Service

There are two Service definitions to make the whoami app available outside the cluster:

* [whoami-nodeport.yaml](specs/services/whoami-nodeport.yaml) - for clusters which don't support LoadBalancer Services 
* [whoami-loadbalancer.yaml](specs/services/whoami-loadbalancer.yaml) - for clusters which do

You can deploy both:

```
kubectl apply -f labs/services/specs/services/whoami-nodeport.yaml -f labs/services/specs/services/whoami-loadbalancer.yaml
```

📋 Print the details for the services - both have the label `app=whoami`.

<details>
  <summary>Not sure how?</summary>

```
kubectl get svc -l app=whoami
```

</details><br/>

> If your cluster doesn't have LoadBalancer support, the `EXTERNAL-IP` field will stay at `<pending>` forever

External Services **also** create a ClusterIP, so you can access them internally. 

You always need to use the Service port for communication:

```
kubectl exec sleep -- curl -s http://whoami-lb:8080

kubectl exec sleep -- curl -s http://whoami-np:8010
```

> The Services all have the same label selector, so they all direct traffic to the same Pod

Now you can call the whoami app from your local machine:

```
# either
curl http://localhost:8080

# or
curl http://localhost:30010
```

> If your cluster isn't running locally, use the node's IP address for NodePort access or the EXTERNAL-IP address field for the LoadBalancer

## Lab

Services are a networking abstraction - they're like routers which listen for incoming traffic and direct it to Pods.

Target Pods are identified with a label selector, and there could be zero or more matches.

Create new Services and whoami Pods to test these scenarios:

* zero Pods match the label spec
* multiple Pods match the label spec

What happens? How can you find the target Pods for a Service?

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___
## Cleanup

Every YAML spec for this lab adds a label `kubernetes.courselabs.co=services` .

That makes it super easy to clean up, by deleting all those resources:

```
kubectl delete pod,svc -l kubernetes.courselabs.co=services
```