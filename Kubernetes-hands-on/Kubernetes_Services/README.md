## Kubernetes Services

In simple terms kubernetes service helps expose an application running on multiple pods <br>
as a network service, you don't need to modify the application. Yes, there is no<br>
need to modify the application to use the unknown service discovery mechanism.<br>

Various modern applications are mostly built using containers, <br>
which are microservices with configurations and dependencies. Kubernetes <br>
is an open source software for managing these containers. These allow you <br>
to rapidly create, scale, and deliver containerized applications.

Kubernetes pods are built and destroyed to match the state of the cluster. <br> 
Pods are not permanent. If you use deployment to run an application, <br>
your pods will be destroyed dynamically.

Each pod gets its own unique IP address, but in a deployment, a group of <br> 
pods running at one time can be different from a group that runs later.


## Components of a Kubernetes Service

Kubernetes services use selectors and labels to match pods with other applications.  <br>
The core components of a Kubernetes service are:

- The cluster IP address and assigned port number 
- A label selector to locate Pods
- Port definitions
- Optional mapping of ports reaching a targetPort 

## Different types of Kubernetes services

#### ClusterIP Service: 

The default type of service used to expose a service on an IP address in a cluster. <br>
Access is usually allowed within the cluster.

#### NodePort Service: 

A nodeport opens ports that help route any traffic arriving at a nodeport to a service. <br>
It is considered the foundation for other techniques such as load balancers.

#### ExternalName Service: 

The ExternalName service returns a CNAME record and contains the value defined in ExternalName. <br>
Therefore, it cannot be accessed by the cluster IP address.

#### Load Balancer Service: 

A load balancer service provides the equivalent of a clusterIP service and extends it to an <br>
external load balancer specific to the cloud provider. This is helpful for clusters running <br>
on public cloud providers such as AWS, Azure or any other cloud service.

## How does a Kubernetes service work? 

In Kubernetes, each pod has an IP address. A pod can communicate with another pod <br>
by directly addressing its IP address, but using services is the recommended way.

A service is a set of pods that can be reached by a single, fixed DNS name or IP address.

I hope you learnt something, happy learning guys :)