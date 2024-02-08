# Kubernetes Hands-on Repository

- A collection of Hands-on labs for Kubernetes (K8S).
- Each lab is a standalone lab and does not require to complete the previous labs.

### Pre-Requirements

- An existing cluster or any other local tool as described [here](https://kubernetes.io/docs/tasks/tools/)
- **kubectl** - The Kubernetes command-line tool, kubectl

---

![](./resources/lab.jpg)

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)

### **<kbd>CTRL</kbd> + click to open in new window**

---

- List of the labs in this repository:

<!-- Labs list start -->

:green_book: [00-VerifyCluster](Labs/00-VerifyCluster/README.md)  
:green_book: [01-Namespace](Labs/01-Namespace/README.md)  
:green_book: [02-Deployments-Imperative](Labs/02-Deployments-Imperative/README.md)  
:green_book: [03-Deployments-Declarative](Labs/03-Deployments-Declarative/README.md)  
:green_book: [04-Rollout](Labs/04-Rollout/README.md)  
:green_book: [05-Services](Labs/05-Services/README.md)  
:green_book: [06-DataStore](Labs/06-DataStore/README.md)  
:green_book: [07-nginx-Ingress](Labs/07-nginx-Ingress/README.md)  
:green_book: [08-Kustomization](Labs/08-Kustomization/README.md)  
:green_book: [09-StatefulSet](Labs/09-StatefulSet/README.md)  
:green_book: [10-Istio](Labs/10-Istio/README.md)  
:green_book: [11-CRD-Custom-Resource-Definition](Labs/11-CRD-Custom-Resource-Definition/README.md)  
:green_book: [12-Wordpress-MySQL-PVC](Labs/12-Wordpress-MySQL-PVC/README.md)  
:green_book: [13-HelmChart](Labs/13-HelmChart/README.md)  
:green_book: [15-Prometheus-Grafana](Labs/15-Prometheus-Grafana/README.md)  
:green_book: [16-Affinity-Taint-Tolleration](Labs/16-Affinity-Taint-Tolleration/README.md)  
:green_book: [17-PodDisruptionBudgets-PDB](Labs/17-PodDisruptionBudgets-PDB/README.md)  
:green_book: [19-CustomScheduler](Labs/19-CustomScheduler/README.md)  
:green_book: [20-CronJob](Labs/20-CronJob/README.md)  
:green_book: [21-KubeAPI](Labs/21-KubeAPI/README.md)

---

:green_book: [00-VerifyCluster](Labs/00-VerifyCluster/README.md)

- [01. Installing minikube](Labs/00-VerifyCluster/README.md#01-Installing-minikube)
- [02. Start minikube](Labs/00-VerifyCluster/README.md#02-Start-minikube)
- [03. Check the minikube status](Labs/00-VerifyCluster/README.md#03-Check-the-minikube-status)
- [04. Verify that the cluster is up and running](Labs/00-VerifyCluster/README.md#04-Verify-that-the-cluster-is-up-and-running)
- [05. Verify that you can "talk" to your cluster](Labs/00-VerifyCluster/README.md#05-Verify-that-you-can-talk-to-your-cluster)
  - [05.01. Verify that you can "talk" to your cluster](Labs/00-VerifyCluster/README.md#0501-Verify-that-you-can-talk-to-your-cluster)

:green_book: [01-Namespace](Labs/01-Namespace/README.md)

- [01. Create Namespace](Labs/01-Namespace/README.md#01-Create-Namespace)
  - [01.01. Create Namespace](Labs/01-Namespace/README.md#0101-Create-Namespace)
- [02. Setting the default Namespace for `kubectl`](Labs/01-Namespace/README.md#02-Setting-the-default-Namespace-for-kubectl)
- [03. Verify that you've updated the namespace](Labs/01-Namespace/README.md#03-Verify-that-youve-updated-the-namespace)

:green_book: [02-Deployments-Imperative](Labs/02-Deployments-Imperative/README.md)

- [01. Create namespace](Labs/02-Deployments-Imperative/README.md#01-Create-namespace)
- [02. Deploy multitool image](Labs/02-Deployments-Imperative/README.md#02-Deploy-multitool-image)
- [03. Test the deployment](Labs/02-Deployments-Imperative/README.md#03-Test-the-deployment)
  - [03.01. Create a Service using `kubectl expose`](Labs/02-Deployments-Imperative/README.md#0301-Create-a-Service-using-kubectl-expose)
  - [03.02. Find the port & the IP which was assigned to our pod by the cluster.](Labs/02-Deployments-Imperative/README.md#0302-Find-the-port--the-IP-which-was-assigned-to-our-pod-by-the-cluster)
  - [03.03. Test the deployment](Labs/02-Deployments-Imperative/README.md#0303-Test-the-deployment)

:green_book: [03-Deployments-Declarative](Labs/03-Deployments-Declarative/README.md)

- [01. Create namespace](Labs/03-Deployments-Declarative/README.md#01-Create-namespace)
- [02. Deploy nginx using yaml file (declarative)](Labs/03-Deployments-Declarative/README.md#02-Deploy-nginx-using-yaml-file-declarative)
- [03. Verify that the deployment is created:](Labs/03-Deployments-Declarative/README.md#03-Verify-that-the-deployment-is-created)
- [04. Check if the pods are running:](Labs/03-Deployments-Declarative/README.md#04-Check-if-the-pods-are-running)
- [05. Update the yaml file with replica's value of 5](Labs/03-Deployments-Declarative/README.md#05-Update-the-yaml-file-with-replicas-value-of-5)
- [06. Update the deployment using `kubectl apply`](Labs/03-Deployments-Declarative/README.md#06-Update-the-deployment-using-kubectl-apply)
- [07. Scaling down with `kubectl scale`](Labs/03-Deployments-Declarative/README.md#07-Scaling-down-with-kubectl-scale)

:green_book: [04-Rollout](Labs/04-Rollout/README.md)

- [01. Create namespace](Labs/04-Rollout/README.md#01-Create-namespace)
- [02. Create the desired deployment](Labs/04-Rollout/README.md#02-Create-the-desired-deployment)
- [03. Expose nginx as service](Labs/04-Rollout/README.md#03-Expose-nginx-as-service)
- [04. Verify that the pods and the service are running](Labs/04-Rollout/README.md#04-Verify-that-the-pods-and-the-service-are-running)
- [05. Change the number of replicas to 3](Labs/04-Rollout/README.md#05-Change-the-number-of-replicas-to-3)
- [06. Verify that now we have 3 replicas](Labs/04-Rollout/README.md#06-Verify-that-now-we-have-3-replicas)
- [07. Test the deployment](Labs/04-Rollout/README.md#07-Test-the-deployment)
- [08. Deploy another version of nginx](Labs/04-Rollout/README.md#08-Deploy-another-version-of-nginx)
- [09. Investigate rollout history:](Labs/04-Rollout/README.md#09-Investigate-rollout-history)
- [10. Lets see what was changed during the previous updates:](Labs/04-Rollout/README.md#10-Lets-see-what-was-changed-during-the-previous-updates)
- [11. Undo the version upgrade by rolling back and restoring previous version](Labs/04-Rollout/README.md#11-Undo-the-version-upgrade-by-rolling-back-and-restoring-previous-version)
- [12. Rolling Restart](Labs/04-Rollout/README.md#12-Rolling-Restart)

:green_book: [05-Services](Labs/05-Services/README.md)

- [01. Create namespace and clear previous data if there is any](Labs/05-Services/README.md#01-Create-namespace-and-clear-previous-data-if-there-is-any)
- [02. Create the required resources for this hand-on](Labs/05-Services/README.md#02-Create-the-required-resources-for-this-hand-on)
- [03. Expose the nginx with ClusterIP](Labs/05-Services/README.md#03-Expose-the-nginx-with-ClusterIP)
- [04. Test the nginx with ClusterIP](Labs/05-Services/README.md#04-Test-the-nginx-with-ClusterIP)
  - [04.01. Test the nginx with ClusterIP](Labs/05-Services/README.md#0401-Test-the-nginx-with-ClusterIP)
  - [04.02. Test the nginx using the deployment name](Labs/05-Services/README.md#0402-Test-the-nginx-using-the-deployment-name)
  - [04.03. using the full DNS name](Labs/05-Services/README.md#0403-using-the-full-DNS-name)
- [05. Create NodePort](Labs/05-Services/README.md#05-Create-NodePort)
  - [05.01. Delete previous service](Labs/05-Services/README.md#0501-Delete-previous-service)
  - [05.02. Create `NodePort` Service](Labs/05-Services/README.md#0502-Create-NodePort-Service)
  - [05.03. Test the `NodePort` Service](Labs/05-Services/README.md#0503-Test-the-NodePort-Service)
- [06. Create LoadBalancer (only if you are on real cloud)](Labs/05-Services/README.md#06-Create-LoadBalancer-only-if-you-are-on-real-cloud)
  - [06.01. Delete previous service](Labs/05-Services/README.md#0601-Delete-previous-service)
  - [06.02. Create `LoadBalancer` Service](Labs/05-Services/README.md#0602-Create-LoadBalancer-Service)
  - [06.03. Test the `LoadBalancer` Service](Labs/05-Services/README.md#0603-Test-the-LoadBalancer-Service)

:green_book: [06-DataStore](Labs/06-DataStore/README.md)

- [01. Create namespace and clear previous data if there is any](Labs/06-DataStore/README.md#01-Create-namespace-and-clear-previous-data-if-there-is-any)
- [02. Build the docker container](Labs/06-DataStore/README.md#02-Build-the-docker-container)
  - [02.01. write the server code](Labs/06-DataStore/README.md#0201-write-the-server-code)
  - [02.02. Write the DockerFile](Labs/06-DataStore/README.md#0202-Write-the-DockerFile)
  - [02.03. Build the docker container](Labs/06-DataStore/README.md#0203-Build-the-docker-container)
  - [02.04. Test the container](Labs/06-DataStore/README.md#0204-Test-the-container)
- [03. Using K8S deployment & Secrets/ConfigMap](Labs/06-DataStore/README.md#03-Using-K8S-deployment--SecretsConfigMap)
  - [03.01. Writing the deployment & Service file](Labs/06-DataStore/README.md#0301-Writing-the-deployment--Service-file)
  - [03.02. Deploy to cluster](Labs/06-DataStore/README.md#0302-Deploy-to-cluster)
  - [03.03. Test the app](Labs/06-DataStore/README.md#0303-Test-the-app)
- [04. Using Secrets & config maps](Labs/06-DataStore/README.md#04-Using-Secrets--config-maps)
  - [04.01. Create the desired secret and config map for this lab](Labs/06-DataStore/README.md#0401-Create-the-desired-secret-and-config-map-for-this-lab)
  - [04.02. Updating the Deployment to read the values from Secrets & ConfigMap](Labs/06-DataStore/README.md#0402-Updating-the-Deployment-to-read-the-values-from-Secrets--ConfigMap)
  - [04.03. Update the deployment to read values from K8S resources](Labs/06-DataStore/README.md#0403-Update-the-deployment-to-read-values-from-K8S-resources)
  - [04.04. Test the changes](Labs/06-DataStore/README.md#0404-Test-the-changes)

:green_book: [07-nginx-Ingress](Labs/07-nginx-Ingress/README.md)

:green_book: [08-Kustomization](Labs/08-Kustomization/README.md)

:green_book: [09-StatefulSet](Labs/09-StatefulSet/README.md)

- [01. Create namespace and clear previous data if there is any](Labs/09-StatefulSet/README.md#01-Create-namespace-and-clear-previous-data-if-there-is-any)
- [02. Create and test the Stateful application](Labs/09-StatefulSet/README.md#02-Create-and-test-the-Stateful-application)
- [03. Test the Stateful application](Labs/09-StatefulSet/README.md#03-Test-the-Stateful-application)
- [04. Scale down the StatefulSet and check that its down](Labs/09-StatefulSet/README.md#04-Scale-down-the-StatefulSet-and-check-that-its-down)
  - [04.01. Scale down the `Statefulset` to 0](Labs/09-StatefulSet/README.md#0401-Scale-down-the-Statefulset-to-0)
  - [04.02. Verify that the pods Terminated](Labs/09-StatefulSet/README.md#0402-Verify-that-the-pods-Terminated)
  - [04.03. Verify that the DB is not reachable](Labs/09-StatefulSet/README.md#0403-Verify-that-the-DB-is-not-reachable)
- [05. Scale up again and verify that we still have the prevoius data](Labs/09-StatefulSet/README.md#05-Scale-up-again-and-verify-that-we-still-have-the-prevoius-data)
  - [05.01. scale up the `Statefulset` to 1 or more](Labs/09-StatefulSet/README.md#0501-scale-up-the-Statefulset-to-1-or-more)
  - [05.02. Verify that the pods is in Running status](Labs/09-StatefulSet/README.md#0502-Verify-that-the-pods-is-in-Running-status)
  - [05.03. Verify that the pods is using the previous data](Labs/09-StatefulSet/README.md#0503-Verify-that-the-pods-is-using-the-previous-data)

:green_book: [10-Istio](Labs/10-Istio/README.md)

- [01. Download latest Istio release (Linux)](Labs/10-Istio/README.md#01-Download-latest-Istio-release-Linux)
- [01.01 Add the istioctl client to your path (Linux or macOS):](Labs/10-Istio/README.md#0101-Add-the-istioctl-client-to-your-path-Linux-or-macOS)
  - [01.02. Install Istio](Labs/10-Istio/README.md#0102-Install-Istio)
  - [01.03. Add the required label](Labs/10-Istio/README.md#0103-Add-the-required-label)
  - [01.02. Install Kiali server](Labs/10-Istio/README.md#0102-Install-Kiali-server)
- [02. Deploy the demo application](Labs/10-Istio/README.md#02-Deploy-the-demo-application)
  - [02.01. Check the installation](Labs/10-Istio/README.md#0201-Check-the-installation)
  - [02.02. Verify that Istio is working](Labs/10-Istio/README.md#0202-Verify-that-Istio-is-working)

:green_book: [11-CRD-Custom-Resource-Definition](Labs/11-CRD-Custom-Resource-Definition/README.md)

:green_book: [12-Wordpress-MySQL-PVC](Labs/12-Wordpress-MySQL-PVC/README.md)

:green_book: [13-HelmChart](Labs/13-HelmChart/README.md)

:green_book: [15-Prometheus-Grafana](Labs/15-Prometheus-Grafana/README.md)

:green_book: [16-Affinity-Taint-Tolleration](Labs/16-Affinity-Taint-Tolleration/README.md)

:green_book: [17-PodDisruptionBudgets-PDB](Labs/17-PodDisruptionBudgets-PDB/README.md)

- [01. start minikube with Feature Gates](Labs/17-PodDisruptionBudgets-PDB/README.md#01-start-minikube-with-Feature-Gates)
- [02. Check Node Pressure(s)](Labs/17-PodDisruptionBudgets-PDB/README.md#02-Check-Node-Pressures)
- [03. Create 3 Pods using 50 MB each.](Labs/17-PodDisruptionBudgets-PDB/README.md#03-Create-3-Pods-using-50-MB-each)
- [04. Check MemoryPressure](Labs/17-PodDisruptionBudgets-PDB/README.md#04-Check-MemoryPressure)

:green_book: [19-CustomScheduler](Labs/19-CustomScheduler/README.md)

:green_book: [20-CronJob](Labs/20-CronJob/README.md)

:green_book: [21-KubeAPI](Labs/21-KubeAPI/README.md)

- [01. Build the docker image](Labs/21-KubeAPI/README.md#01-Build-the-docker-image)
  - [01.01. The script which will be used for query K8S API](Labs/21-KubeAPI/README.md#0101-The-script-which-will-be-used-for-query-K8S-API)
  - [01.02. Build the docker image](Labs/21-KubeAPI/README.md#0102-Build-the-docker-image)
- [02. Deploy the Pod to K8S](Labs/21-KubeAPI/README.md#02-Deploy-the-Pod-to-K8S)
  - [02.01. Run kustomization to deploy](Labs/21-KubeAPI/README.md#0201-Run-kustomization-to-deploy)
  - [02.02. Query the K8S API](Labs/21-KubeAPI/README.md#0202-Query-the-K8S-API)
  <!-- Labs list ends -->
