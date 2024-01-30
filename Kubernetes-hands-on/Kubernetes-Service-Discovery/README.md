DNS

Each service will get a DNS name that other microservices can use. The format of the DNS record would be: 

```yaml
  service-name.namespace.svc.cluster.local


  apiVersion: v1  #This versions description may change for the type of the resource you used 
  kind: Service   #Object you are going to use 
  metadata:
    name: testing <- this name is registered with the cluster DNS
  spec: # This is where you define the properties of the properties (which is also called as you desire state even your are using a pod, deployment..)
    selector:
      app:web
    ports:

```
By default, Kubernetes creates a service of type clusterIP. We can create different types of services <br>
by having a spec.type property in the service YAML file.

Four types of services:

ClusterIP

available in the cluster. reliant applications can interact with other applications internally <br>
using the ClusterIP service.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: dns-name-service
spec:
  type: ClusterIP 
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
```

NodePort


NodePort services are accessible outside the cluster. It creates a mapping of pods to its <br>
hosting node/machine on a static port.

```yaml
apiVersion: v1
kind: Service 
metadata:
  name: node-port-example
spec:
  type: NodePort
  selector:
    tier: front-end
  ports:
  - port: 80
    targetPort: 80
    nodePort: 32008
```

Load Balancer

This service type creates load balancers on various cloud providers like AWS, GCP, <br>
Azure etc. to expose our application to the internet.

```yaml
apiVersion: v1
kind: Service 
metadata: 
  name: Load-Balancer
spec:
  selector:
    tier: front-end
    type: Load-Balance
  ports:
  - port: 80
    nodePort: 32008
  clusterIP: 10.96.0.200
```

ExternalName
For any pod to access an application outside of the Kubernetes cluster like <br>
the external DB server, we use the ExternalName service type.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-my-sql-db
spec:
  selector:
    app: myapp
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 443
  type: ExternalName
  externalName: remote.server.url.com
```


