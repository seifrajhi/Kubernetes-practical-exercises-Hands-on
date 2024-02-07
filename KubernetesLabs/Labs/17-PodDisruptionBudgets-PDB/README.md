

# K8S Hands-on


---

# PodDisruptionBudgets(PDB)

### Pre-Requirements
- K8S cluster - <a href="../00-VerifyCluster">Setting up minikube cluster instruction</a>

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)  
**<kbd>CTRL</kbd> + <kbd>click</kbd> to open in new window**

---

## `PodDisruptionBudgets`: Budgeting the Number of Faults to Tolerate

- A pod disruption budget is an **indicator of the number of disruptions that can be tolerated at a given time for a class of pods** (a budget of faults). 

- Disruptions may be caused by **deliberate** or **accidental** Pod deletion.
- Whenever a disruption to the pods in a service is calculated to cause the service to **drop below the budget**, the operation is paused until it can maintain the budget. This means that the `drain event` could be temporarily halted while it waits for more pods to become available such that the budget isn’t crossed by evicting the pods.

- You can specify Pod Disruption Budgets for Pods managed by these built-in Kubernetes controllers:

    - `Deployment`
    - `ReplicationController`
    - `ReplicaSet`
    - `StatefulSet`

- For this tutorial you should get familier with Kubernetes Eviction Policies since it demonstrates how Pod Disruption Budgets handle evictions.

- As in the Kubernetes Eviction Policies tutorial we start with eviction-hard="memory.available<480M


### Sample
- In the below sample we will configure a `PodDisruptionBudget` which insure that we will always have **at least** 1 Nginx instance.

- First we need an [Nginx Deployment](./resources/Deployment.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: codewizard
  labels:
    app: nginx # <- We will use this name below
...
```
```yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 1 # <--- This will insure that we will have at least 1
  selector:
    matchLabels:
      app: nginx # <- The deployment app label 
```      

---
## Walkthrough
[01. start minikube with Feature Gates](#01-start-minikube-with-feature-gates)
[02. Check Node Pressure(s)](#02-check-node-pressure)

---
### 01. start minikube with Feature Gates
- For more details about Feature Gates read: 
  https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/#feature-stages

- For more details about eviction-signals
  https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#eviction-signals



```sh
minikube start \
    --extra-config=kubelet.eviction-hard="memory.available<480M" \
    --extra-config=kubelet.eviction-pressure-transition-period="30s" \
    --extra-config=kubelet.feature-gates="ExperimentalCriticalPodAnnotation=true"
```

### 02. Check Node Pressure(s)
- Check to see the Node conditions, if we have any kind of "Presure"
```sh
kubectl describe node minikube | grep MemoryPressure

# Output should be similar to :
Conditions:
  Type             Status  Reason                       Message
  ----             ------  ------                       -------
  MemoryPressure   False   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    KubeletReady                 kubelet is posting ready status. AppArmor enabled
  ...
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                750m (37%)  0 (0%)
  memory             140Mi (6%)  340Mi (16%)
  ephemeral-storage  0 (0%)      0 (0%)  
```

### 03. Create 3 Pods using 50 MB each.
```yaml
# ./resources/50MB-ram.yaml
...

# 3 replicas
spec:
  replicas: 3

# resources request and limits
resources:
  requests:
    memory: "50Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```
- Create the pods
```sh
kubectl apply -f resources/50MB-ram.yaml
```

### 04. Check MemoryPressure 
```sh
$ kubectl describe node minikube | grep MemoryPressure

# Output should be similar to 
MemoryPressure   False   ...   KubeletHasSufficientMemory   kubelet has sufficient memory available
```
<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../16-Affinity-Taint-Tolleration">16-Affinity-Taint-Tolleration</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../18-ArgoCD">18-ArgoCD</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->