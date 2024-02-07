

# K8S Hands-on


---
# WordPress, MySQL, PVC

- In This tutorial you will deploy a WordPress site and a MySQL database.
- You will use `PersistentVolumes` and `PersistentVolumeClaims` as storage.

---

## Walkthrough 
- Patch `minikube` so we can use `Service: LoadBalancer`
    ```sh
    # Sourse:
    #   https://github.com/knative/serving/blob/b31d96e03bfa1752031d0bc4ae2a3a00744d6cd5/docs/creating-a-kubernetes-cluster.md#loadbalancer-support-in-minikube
    sudo ip route add \
        $(cat ~/.minikube/profiles/minikube/config.json | \
        jq -r ".KubernetesConfig.ServiceCIDR") \
        via $(minikube ip)

    kubectl run minikube-lb-patch \
        --replicas=1 \
        --image=elsonrodriguez/minikube-lb-patch:0.1 \--namespace=kube-system
    ```
- Create the desired Namespace
- Create the MySQL resources
    - Create `Service`
    - Create `PersistentVolumeClaims`
    - Create `Deployment`
    - Create password file
- Create the WordPress resources
    - Create `Service`
    - Create `PersistentVolumeClaims`
    - Create `Deployment`
- Create a `kustomization.yaml` with
    - Secret generator
    - MySQL resources
    - WordPress resources
- Deploy the stack
- Port forward from the host to the application
    - We use a port forward so we will be able to test and verify if the WordPress is actually running
    ```sh
    kubectl port-forward service/wordpress 8080:32267 -n wp-demo
    ```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../11-CRD-Custom-Resource-Definition">11-CRD-Custom-Resource-Definition</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../13-HelmChart">13-HelmChart</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->