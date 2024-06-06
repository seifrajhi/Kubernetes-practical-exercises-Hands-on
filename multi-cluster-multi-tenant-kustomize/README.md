# Multi-cluster, Multi-tenant Kustomize Example

This repository shows an example of how to use Kustomize's bases and overlays to maintain manifests for an application that requires one instance of the application to be deployed per tenant and per environment.

Bases are configurations that inherit nothing. Overlays are configurations that inherit from somewhere. Overlays can inherit from bases or from other overlays.

Our example has just one base, the example app represented by a single nginx deployment.

In overlays, we have `clusters`, `plans` and `tenant-envs`.

 1. `clusters`: We have one directory per region. If a tenant-env should be in the us, you add it as a base to the `us/kustomization.yaml`. If a tenant-env should be in the eu, you add it to the `eu/kustomization.yaml` bases.

 1. `plans`: The plans overlay is where you'd put configuration that is different per plan. In our example trial tenants get less replicas then paying tenants.

 1. `tenant-envs`: Our example has a `test` and a `prod` environment per client. Both tenant environments go onto the same cluster. The tenant-env overlays are where you put configuration that is specific to an env. E.g. the database connection should be unique per tenant per env. The tenant envs would also be a good place to give a certain tenant a specific version of the app (e.g. a hotfix) by overwriting the image tags for that tenant and possibly in the tenants test env first.

Adopting a repository structure like this to manage multiple tenants makes it intuitive to understand where certain changes should be made while at the same time reducing the amount of duplicate manifests to a minimum.

Applying a configuration to a cluster ist just one `kustomize build overlays/clusters/eu | kubectl apply -f -` command.

Kustomize has recently been included into kubectl. Once that's released a simple `kubectl apply -f overlays/clusters/eu` is good enough.



## Demo details

### ArgoCD Overview

1. **Purpose and Benefits of ArgoCD**:
   - **Continuous Delivery**: ArgoCD is a declarative GitOps continuous delivery tool for Kubernetes. It ensures that your deployed applications match the desired state defined in your Git repositories.
   - **Automated Deployment**: Automates the deployment of applications to Kubernetes clusters, reducing manual intervention and potential errors.

### Setting Up ArgoCD on Minikube

1. **Prerequisites**:
   - **Minikube Installation**: Ensure Minikube is installed and configured on your local machine. This may require sufficient memory and CPU resources (e.g., 8GB RAM, 3 CPUs)【13†source】.
   - **Kubectl Configuration**: Make sure `kubectl` is installed and configured to interact with your Minikube cluster.

2. **Minikube Cluster Setup**:
   - **Start Minikube**: Initialize Minikube with adequate resources.
     ```bash
     minikube start --memory=8192 --cpus=3 --kubernetes-version=v1.28  -p gitops
     ```
   - **Enable Ingress Addon**: Enable the Ingress addon for handling ingress resources.
     ```bash
     minikube addons enable ingress -p gitops
     ```

3. **ArgoCD Installation**:
   - **Create Namespace and Deploy ArgoCD**: Deploy ArgoCD components in a dedicated namespace.
     ```bash
     kubectl create namespace argocd
     kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
     ```
   - **Monitor Deployment**: Use commands like `watch kubectl get pods -n argocd` to ensure all components are running【13†source】.
   - **Expose ArgoCD Server**: Change the service type to LoadBalancer for easier access.
     ```bash
     kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
     ```

4. **Accessing ArgoCD**:
   - **Web Console**: Access the ArgoCD web console via the exposed service IP. Retrieve the initial admin password and log in.
     ```bash
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
     ```

### Kustomize Integration

1. **What is Kustomize?**:
   - **Configuration Management**: Kustomize allows customization of Kubernetes resource configurations without modifying the original YAML files. It uses a configuration file (`kustomization.yaml`) to manage overlays and customizations.

2. **Using Kustomize with ArgoCD**:
   - **Building Manifests**: Use Kustomize to build Kubernetes manifests by defining custom overlays and patches. This helps manage different environments (e.g., dev, staging, prod) efficiently.
     ```bash
     kustomize build . | kubectl apply -f -
     ```
   - **ArgoCD Support**: ArgoCD natively supports Kustomize, making it easy to integrate and deploy customized resources from your Git repository.

### Local Environment Challenges

1. **Resource Constraints**: Running Minikube locally requires sufficient resources (memory, CPU) which might not be available on all machines.
2. **Configuration Management**: Managing and syncing configurations across multiple local environments can be cumbersome.
3. **Networking Issues**: Exposing services and accessing them locally can be tricky and requires proper configuration of Minikube and local network settings.

### Enhancements with Remote Environments

1. **Resource Availability**: Remote environments typically provide more robust resources (CPU, memory, storage) compared to local setups.
2. **Consistency**: Using a remote environment ensures a consistent setup across all users, reducing the "it works on my machine" problem.
3. **Scalability**: Remote environments can be easily scaled up or down based on the needs of the deployment, providing flexibility and efficiency.
4. **Collaboration**: Teams can collaborate more effectively in a shared remote environment, accessing the same resources and configurations without local setup conflicts.







