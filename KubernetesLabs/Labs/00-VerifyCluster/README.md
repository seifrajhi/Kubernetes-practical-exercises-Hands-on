# K8S Hands-on



### Verify pre-requirements

- **`kubectl`** - short for Kubernetes Controller - is the CLI for Kubernetes cluster and is required in order to be able to run the labs.
- In order to install `kubectl` and if required creating a local cluster, please refer to [Kubernetes - Install Tools](https://kubernetes.io/docs/tasks/tools/)

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Installing minikube](#01-Installing-minikube)
 - [02. Start minikube](#02-Start-minikube)
 - [03. Check the minikube status](#03-Check-the-minikube-status)
 - [04. Verify that the cluster is up and running](#04-Verify-that-the-cluster-is-up-and-running)
 - [05. Verify that you can &#34;talk&#34; to your cluster](#05-Verify-that-you-can-talk-to-your-cluster)
   - [05.01. Verify that you can &#34;talk&#34; to your cluster](#0501-Verify-that-you-can-talk-to-your-cluster)

---

<!-- inPage TOC end -->

### 01. Installing minikube

- If you don't have an existing cluster you can use google cloud for the labs hands-on
- Click on the button below to be able to run the labs on Google Shell <br/>
  **[Use: <kbd>CTRL + click to open in new window]**  
  [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)

- Run the following script in the opened terminal

```sh
# Download minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 02. Start minikube

```sh
minikube start
```

- You should see an output like this:

```sh
* minikube v1.16.0 on Debian 10.7
  - MINIKUBE_FORCE_SYSTEMD=true
  - MINIKUBE_HOME=/google/minikube
  - MINIKUBE_WANTUPDATENOTIFICATION=false
* Automatically selected the docker driver
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
* Downloading Kubernetes v1.20.0 preload ...
    > preloaded-images-k8s-v8-v1....: 491.00 MiB / 491.00 MiB  100.00% 86.82 Mi
* Creating docker container (CPUs=2, Memory=4000MB) ...
* Preparing Kubernetes v1.20.0 on Docker 20.10.0 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Verifying Kubernetes components...
* Enabled addons: default-storageclass, storage-provisioner
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

### 03. Check the minikube status

```
minikube status
```

- You should see output similar to this one:

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
timeToStop: Nonexistent
```

### 04. Verify that the cluster is up and running

```sh
$ kubectl cluster-info

Kubernetes control plane is running at https://192.168.49.2:8443
KubeDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

- Verify that `kubectl` is installed and configured (You should get something like the following)

```sh
kubectl config view
```

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority: /google/minikube/.minikube/ca.crt
      server: https://192.168.49.2:8443
    name: minikube
contexts:
  - context:
      cluster: minikube
      namespace: default
      user: minikube
    name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
  - name: minikube
    user:
      client-certificate: /google/minikube/.minikube/profiles/minikube/client.crt
      client-key: /google/minikube/.minikube/profiles/minikube/client.key
```

### 05. Verify that you can "talk" to your cluster

```sh
# In this sample we have minikube pod running
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE    VERSION
minikube   Ready    control-plane,master   3m9s   v1.20.0
```

### 05.01. Verify that you can "talk" to your cluster

```sh
# In this sample we have minikube pod running
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE    VERSION
minikube   Ready    control-plane,master   3m9s   v1.20.0
```

<!-- navigation start -->

---

<div align="center">
  <a href="../01-Namespace">01-Namespace</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->