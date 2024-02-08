

# K8S Hands-on


---
# Deployment - Imperative

### Pre-Requirements

- K8S cluster - <a href="../00-VerifyCluster">Setting up minikube cluster instruction</a>

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)  
**<kbd>CTRL</kbd> + <kbd>click</kbd> to open in new window**

---

## Creating deployments using `kubectl create`

- We start with creating the following deployment
  [praqma/network-multitool](https://github.com/Praqma/Network-MultiTool)
- This is a multitool for container/network testing and troubleshooting.

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Create namespace](#01-Create-namespace)
 - [02. Deploy multitool image](#02-Deploy-multitool-image)
 - [03. Test the deployment](#03-Test-the-deployment)
   - [03.01. Create a Service using `kubectl expose`](#0301-Create-a-Service-using-kubectl-expose)
   - [03.02. Find the port &amp; the IP which was assigned to our pod by the cluster.](#0302-Find-the-port--the-IP-which-was-assigned-to-our-pod-by-the-cluster)
   - [03.03. Test the deployment](#0303-Test-the-deployment)

---

<!-- inPage TOC end -->

### 01. Create namespace

```sh
# Create the desired namespace [codewizard]
$ kubectl create namespace codewizard
namespace/codewizard created
```

- In order to set this is as your default namespace refer to: <a href="../01-Namespace#2-setting-the-default-namespace-for-kubectl">set default namespace</a>

### 02. Deploy multitool image

```sh
# Deploy the first container
$ kubectl create deployment multitool -n codewizard --image=praqma/network-multitool
deployment.apps/multitool created
```

- `kubectl create deployment` actually creating a replica set for us.
- We can verify it:

```
$ kubectl get all -n codewizard
NAME                                    READY    UP-TO-DATE  AVAILABLE
deployment.apps/multitool               1/1      1           1

NAME                                    DESIRED  CURRENT     READY
replicaset.apps/multitool-7885b5f94f    1        1           1

NAME                                    READY    STATUS      RESTARTS
pod/multitool-7885b5f94f-9s7xh          1/1      Running     0
```

## 03. Test the deployment

- The above deployment contains a container [`multitool`]
- In order of us to be able to access this `multitool` container we need to create a resource of type `Service` which will "open" the server for incoming traffic

### 03.01. Create a Service using `kubectl expose`

```sh
# "Expose" the desired port for incoming traffic
# This command is equivalent to declare a `kind: Service` im yaml file
$ kubectl expose deployment -n codewizard multitool --port 80 --type NodePort
service/multitool exposed
```

- Verify that the service have been created

```sh
$ kubectl get service -n codewizard

# The output should be something like
NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/multitool   NodePort   10.102.73.248   <none>        80:31418/TCP   3s
```

### 03.02. Find the port & the IP which was assigned to our pod by the cluster.

- Grab the port from the previous output.
  - Port: In the above sample its `31418` [`80:31418/TCP`]
  - IP: we will need to gtrab the cluster ip using `kubectl cluster-info`

```sh

# get the IP
$ kubectl cluster-info

# You should get output similar to this one
Kubernetes control plane is running at https://192.168.49.2:8443
KubeDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# Programmatically get the port and the IP
CLUSTER_IP=$(kubectl get nodes \
            --selector=node-role.kubernetes.io/master \
            -o jsonpath='{$.items[*].status.addresses[?(@.type=="InternalIP")].address}')

NODE_PORT=$(kubectl get -o \
            jsonpath="{.spec.ports[0].nodePort}" \
            services multitool -n codewizard)
```

- In this sample the cluster-ip is `192.168.49.2`

### 03.03. Test the deployment

- Test to see if the deployment worked using the `ip & port` you got above
- Execute `curl` with the following prameters: `http://${CLUSTER_IP}:${NODE_PORT}`

```sh
curl http://${CLUSTER_IP}:${NODE_PORT}

# Or in the above sample
curl 192.168.49.2:30436

# The output should be similar to this:
Praqma Network MultiTool (with NGINX) ...
```
<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../01-Namespace">01-Namespace</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../03-Deployments-Declarative">03-Deployments-Declarative</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->