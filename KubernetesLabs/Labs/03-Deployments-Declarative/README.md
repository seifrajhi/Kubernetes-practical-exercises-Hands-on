

# K8S Hands-on


---

# Deployment - Declarative

### Pre-Requirements
- K8S cluster - <a href="../00-VerifyCluster">Setting up minikube cluster instruction</a>

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)  
**<kbd>CTRL</kbd> + <kbd>click</kbd> to open in new window**

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Create namespace](#01-Create-namespace)
 - [02. Deploy nginx using yaml file (declarative)](#02-Deploy-nginx-using-yaml-file-declarative)
 - [03. Verify that the deployment is created:](#03-Verify-that-the-deployment-is-created)
 - [04. Check if the pods are running:](#04-Check-if-the-pods-are-running)
 - [05. Update the yaml file with replica&#39;s value of 5](#05-Update-the-yaml-file-with-replicas-value-of-5)
 - [06. Update the deployment using `kubectl apply`](#06-Update-the-deployment-using-kubectl-apply)
 - [07. Scaling down with `kubectl scale`](#07-Scaling-down-with-kubectl-scale)

---

<!-- inPage TOC end -->

### 01. Create namespace

```sh
# Create the desired namespace [codewizard]
$ kubectl create namespace codewizard
namespace/codewizard created
```

- In order to set this is as your default namespace refer to: <a href="../01-Namespace#2-setting-the-default-namespace-for-kubectl">set default namespace</a>

### 02. Deploy nginx using yaml file (declarative)

- Lets create the yaml file for the deployment.
- If this is your first k8s yaml file its recommended that you will type it to get the feeling of the structure
- Save the file with the following name: `nginx.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment # We use a deployment and not pod !!!!
metadata:
  name: nginx # Deployment name
  namespace: codewizard
  labels:
    app: nginx # Deployment label
spec:
  replicas: 2
  selector:
    matchLabels: # Labels for the replica selector
      app: nginx
  template:
    metadata:
      labels:
        app: nginx # Labels for the replica selector
        version: "1.17" # Specify specific verion if required
    spec:
      containers:
        - name: nginx # The name of the pod
          image: nginx:1.17 # The image which we will deploy
          ports:
            - containerPort: 80
```

- Create the deployment using the `-f` flag & `--record=true`

  ```
  $ kubectl apply -n codewizard -f nginx.yaml --record=true
  deployment.extensions/nginx created
  ```

### 03. Verify that the deployment is created:

```
$ kubectl get deployments -n codewizard
NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE
multitool   1         1         1            1
nginx       1         1         1            1
```

### 04. Check if the pods are running:

```
$ kubectl get pods -n codewizard
NAME                         READY   STATUS    RESTARTS
multitool-7885b5f94f-9s7xh   1/1     Running   0
nginx-647fb5956d-v8d2w       1/1     Running   0
```

### 0Playing with K8S replicas

- Lets play with the replica and see K8S in action
- Open a second terminal and execute:

```sh
$ kubectl get pods -n codewizard --watch
```

### 05. Update the yaml file with replica's value of 5

```yaml
spec:
  replicas: 5
```

### 06. Update the deployment using `kubectl apply`

```
$ kubectl apply -n codewizard -f nginx.yaml --record=true
deployment.apps/nginx configured
```

- Switch to the second terminal and you should see something like

```sh
$ kubectl get pods --watch -n codewizard
NAME                         READY   STATUS    RESTARTS   AGE
multitool-74477484b8-dj7th   1/1     Running   0          20m
nginx-dc8bb9b45-hqdv9        1/1     Running   0          111s
nginx-dc8bb9b45-vdmp5        0/1     Pending   0          0s
nginx-dc8bb9b45-28wwq        0/1     Pending   0          0s
nginx-dc8bb9b45-wkc68        0/1     Pending   0          0s
nginx-dc8bb9b45-vdmp5        0/1     Pending   0          0s
nginx-dc8bb9b45-28wwq        0/1     Pending   0          0s
nginx-dc8bb9b45-x7j4g        0/1     Pending   0          0s
nginx-dc8bb9b45-wkc68        0/1     Pending   0          0s
nginx-dc8bb9b45-x7j4g        0/1     Pending   0          0s
nginx-dc8bb9b45-vdmp5        0/1     ContainerCreating   0          0s
nginx-dc8bb9b45-28wwq        0/1     ContainerCreating   0          0s
nginx-dc8bb9b45-wkc68        0/1     ContainerCreating   0          0s
nginx-dc8bb9b45-x7j4g        0/1     ContainerCreating   0          0s
nginx-dc8bb9b45-vdmp5        1/1     Running             0          2s
nginx-dc8bb9b45-28wwq        1/1     Running             0          3s
nginx-dc8bb9b45-x7j4g        1/1     Running             0          3s
nginx-dc8bb9b45-wkc68        1/1     Running             0          3s
```

> Can you explain what do you see?

    Whey there are more containers that requested?

### 07. Scaling down with `kubectl scale`

```sh
# Scaling using kubectl and not by editing the yaml file
kubectl scale -n codewizard --replicas=1 deployment/nginx
```

- Switch to the second terminal and now you should see something like:

```
NAME                         READY   STATUS    RESTARTS   AGE
multitool-74477484b8-dj7th   1/1     Running   0          29m
nginx-dc8bb9b45-28wwq        1/1     Running   0          4m41s
nginx-dc8bb9b45-hqdv9        1/1     Running   0          10m
nginx-dc8bb9b45-vdmp5        1/1     Running   0          4m41s
nginx-dc8bb9b45-wkc68        1/1     Running   0          4m41s
nginx-dc8bb9b45-x7j4g        1/1     Running   0          4m41s
nginx-dc8bb9b45-x7j4g        1/1     Terminating   0          6m21s
nginx-dc8bb9b45-vdmp5        1/1     Terminating   0          6m21s
nginx-dc8bb9b45-28wwq        1/1     Terminating   0          6m21s
nginx-dc8bb9b45-wkc68        1/1     Terminating   0          6m21s
nginx-dc8bb9b45-x7j4g        0/1     Terminating   0          6m22s
nginx-dc8bb9b45-vdmp5        0/1     Terminating   0          6m22s
nginx-dc8bb9b45-wkc68        0/1     Terminating   0          6m22s
nginx-dc8bb9b45-28wwq        0/1     Terminating   0          6m22s
nginx-dc8bb9b45-28wwq        0/1     Terminating   0          6m26s
nginx-dc8bb9b45-28wwq        0/1     Terminating   0          6m26s
nginx-dc8bb9b45-vdmp5        0/1     Terminating   0          6m26s
nginx-dc8bb9b45-vdmp5        0/1     Terminating   0          6m26s
nginx-dc8bb9b45-wkc68        0/1     Terminating   0          6m27s
nginx-dc8bb9b45-wkc68        0/1     Terminating   0          6m27s
nginx-dc8bb9b45-x7j4g        0/1     Terminating   0          6m27s
nginx-dc8bb9b45-x7j4g        0/1     Terminating   0          6m27s
```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../02-Deployments-Imperative">02-Deployments-Imperative</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../04-Rollout">04-Rollout</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->