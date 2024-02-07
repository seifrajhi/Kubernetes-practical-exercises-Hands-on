

# K8S Hands-on


---

# Service Discovery

- In the following labs we will learn what is `Service`, we will go over the different `Service` types.

---
### Pre-Requirements
- K8S cluster - <a href="../00-VerifyCluster">Setting up minikube cluster instruction</a>

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)  
**<kbd>CTRL</kbd> + <kbd>click</kbd> to open in new window**

---

## What is a `Service`

### Few general notes:
- `Service` is a unit of application behavior bound to a unique name in a `service registry`. 
- `Service` consist of multiple `network endpoints` implemented by workload instances running on pods, containers, VMs etc.
- `Service` allow us to gain access any given pod / container (e.g. web service).
- A service is (normally) created on top of an existing and exposing the deployment to the world using ip(s) & port(s).
- K8S define 3 main ways (+FQDN internally) to define a service, which means that we have 4 different ways to access Pods.
- There are several proxy mode which inplements diffrent behaviour, for example in `user proxy mode` for each `Service` `kube-proxy` opens a port (randomly chosen) on the local node. Any connections to this "proxy port" are proxied to one of the Service's backend Pods (as reported via Endpoints)
- All the service types are assigned with a Cluster-IP
- Every service also creates `Endoint(s)`, which point to the actual pods. Endpoint are usually referred to as back-ends of a particular service.

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Create namespace and clear previous data if there is any](#01-Create-namespace-and-clear-previous-data-if-there-is-any)
 - [02. Create the required resources for this hand-on](#02-Create-the-required-resources-for-this-hand-on)
 - [03. Expose the nginx with ClusterIP](#03-Expose-the-nginx-with-ClusterIP)
 - [04. Test the nginx with ClusterIP](#04-Test-the-nginx-with-ClusterIP)
   - [04.01. Test the nginx with ClusterIP](#0401-Test-the-nginx-with-ClusterIP)
   - [04.02. Test the nginx using the deployment name](#0402-Test-the-nginx-using-the-deployment-name)
   - [04.03. using the full DNS name](#0403-using-the-full-DNS-name)
 - [05. Create NodePort](#05-Create-NodePort)
   - [05.01. Delete previous service](#0501-Delete-previous-service)
   - [05.02. Create `NodePort` Service](#0502-Create-NodePort-Service)
   - [05.03. Test the `NodePort` Service](#0503-Test-the-NodePort-Service)
 - [06. Create LoadBalancer (only if you are on real cloud)](#06-Create-LoadBalancer-only-if-you-are-on-real-cloud)
   - [06.01. Delete previous service](#0601-Delete-previous-service)
   - [06.02. Create `LoadBalancer` Service](#0602-Create-LoadBalancer-Service)
   - [06.03. Test the `LoadBalancer` Service](#0603-Test-the-LoadBalancer-Service)

---

<!-- inPage TOC end -->

### 01. Create namespace and clear previous data if there is any

```sh
# If the namespace already exist and contains data form previous steps, lets clean it
kubectl delete namespace codewizard

# Create the desired namespace [codewizard]
$ kubectl create namespace codewizard
namespace/codewizard created
```

### 02. Create the required resources for this hand-on

```sh
# Network tools pod
$ kubectl create deployment -n codewizard multitool --image=praqma/network-multitool
deployment.apps/multitool created

# nginx pod
$ kubectl create deployment -n codewizard nginx --image=nginx
deployment.apps/nginx created

# Verify that the pods running
$ kubectl get all -n codewizard

NAME                             READY   STATUS    RESTARTS   AGE
pod/multitool-74477484b8-bdrwr   1/1     Running   0          29s
pod/nginx-6799fc88d8-p2fjn       1/1     Running   0          7s
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/multitool   1/1     1            1           30s
deployment.apps/nginx       1/1     1            1           8s
NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/multitool-74477484b8   1         1         1       30s
replicaset.apps/nginx-6799fc88d8       1         1         1       8s
```

## Service types

- As learned in the lecture there are several services type.  
  Lets practice them

### Service type: ClusterIP

- If not specified, the default service type id 'ClusterIP`
- Expose the deployment as a service `--type=ClusterIP`
- `ClusterIP` will expose the pods within the cluster and since we don't have an external ip it will not be reached from outside the cluster.
- When the service is created K8S attach DNs record to the service with the following format: `<service name>.<namespace>.svc.cluster.local`

### 03. Expose the nginx with ClusterIP

```sh
# Expose the service on port 80
$ kubectl expose deployment nginx -n codewizard --port 80 --type ClusterIP
service/nginx exposed

# Check the services and see the type
# Grab the ClusterIP - we will use it in the next steps
$ kubectl get services -n codewizard

NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)
nginx        ClusterIP   10.109.78.182   <none>        80/TCP
```

### 04. Test the nginx with ClusterIP

- Since the Service is a cluster ip we will test if we can access the service using the multitool pod

```sh
# Get the name of the multitool pod which we will use
$ kubectl get pods -n codewizard
NAME
multitool-XXXXXX-XXXXX

# Run an interactive shell inside the network-multitool-container
# (same as with docker)
$ kubectl exec -it <pod name> -n codewizard -- sh
```

- Connect to the service in **any** of the following ways:

#### 04.01. Test the nginx with ClusterIP

```sh
# 1. using the ip from the services output grab the server response
bash-5.0# curl -s <ClusterIP>
HTTP/1.1 200 OK
Server: nginx/1.19.6
Date: Fri, 15 Jan 2021 23:10:30 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 15 Dec 2020 13:59:38 GMT
Connection: keep-alive
ETag: "5fd8c14a-264"
Accept-Ranges: bytes
```

#### 04.02. Test the nginx using the deployment name

```sh
# 2. using the service name since its the DNS name behind the scenes
bash-5.0# curl -s nginx
```

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Welcome to nginx!</title>
    <style>
      body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
      }
    </style>
  </head>
  <body>
    <h1>Welcome to nginx!</h1>
    <p>
      If you see this page, the nginx web server is successfully installed and
      working. Further configuration is required.
    </p>
    <p>
      For online documentation and support please refer to
      <a href="http://nginx.org/">nginx.org</a>.<br />
      Commercial support is available at
      <a href="http://nginx.com/">nginx.com</a>.
    </p>
    <p><em>Thank you for using nginx.</em></p>
  </body>
</html>
```

#### 04.03. using the full DNS name

- For every service we have a full FQDN (Fully qualified domain name) so we can use it as well

```sh
# bash-5.0# curl -s <service name>.<namespace>.svc.cluster.local
bash-5.0# curl -s nginx.codewizard.svc.cluster.local
```

### Service type: NodePort

- `NodePort`: Exposes the Service on each Node's IP at a **static port** (the NodePort).
- A ClusterIP Service, to which the NodePort Service routes, **is automatically created**.
- NodePort Service is reachable from outside the cluster, by requesting <NodeIP>:<NodePort>.

### 05. Create NodePort

#### 05.01. Delete previous service

```sh
# Delete the existing service from previous steps
$ kubectl delete svc nginx -n codewizard
service "nginx" deleted
```

#### 05.02. Create `NodePort` Service

```sh
# As before but this time the type is a NodePort
$ kubectl expose deployment -n codewizard nginx --port 80 --type NodePort
service/nginx exposed

# Verify that the type is set to NodePort.
# This time you should see ClusterIP and port as well
$ kubectl get svc -n codewizard
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)
nginx        NodePort    100.65.29.172  <none>        80:32593/TCP
```

#### 05.03. Test the `NodePort` Service

- Now if we can find the host and the nodePort we can connect directly to the pod

- If you followed the previous labs, you should be able to do it your self by now......

```sh
# Tiny clue....
$ kubectl cluster-info
$ kubectl get services

# Executing curl <cluster host ip>:<port> you should see the flowing Output
Welcome to nginx!
...
Thank you for using nginx.
```

### Service type: LoadBalancer

---

Note: **We cannot test LoadBalancer locally on localhost only on real cluster which can create LoadBalancer)**

---

### 06. Create LoadBalancer (only if you are on real cloud)

#### 06.01. Delete previous service

```sh
# Delete the existing service from previous steps
$ kubectl delete svc nginx -n codewizard
service "nginx" deleted
```

#### 06.02. Create `LoadBalancer` Service

```sh
# As before this time the type is a LoadBalancer
$ kubectl expose deployment nginx -n codewizard --port 80 --type LoadBalancer
service/nginx exposed

# In real cloud we should se an EXTERNAL-IP and we can access the service
# via the internet
$ kubectl get svc
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
nginx        LoadBalancer   100.69.15.89   35.205.60.29  80:31354/TCP
```

#### 06.03. Test the `LoadBalancer` Service

```sh
# Testing load balancer only require us to use the EXTERNAL-IP
$ curl -s <EXTERNAL-IP>
```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../04-Rollout">04-Rollout</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../06-DataStore">06-DataStore</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->