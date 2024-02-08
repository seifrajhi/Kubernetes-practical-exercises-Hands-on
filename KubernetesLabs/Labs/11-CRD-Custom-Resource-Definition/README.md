

# K8S Hands-on


---
# Custom resources definition (CRD)

### Intro
- **Custom resources definition (CRD)** was added to  Kubernetes 1.7
- CRD added the ability to define Custom objects/resources 

---
#### What is a Custom Resource Definition(CRD)
- Custom resources

    A resource is an endpoint in the Kubernetes API that stores a collection of API objects of a certain kind; for example, the built-in pods resource contains a collection of Pod objects.

    A custom resource is an **extension of the Kubernetes API** that is not necessarily available in a default Kubernetes installation. It represents a customization of a particular Kubernetes installation. However, many core Kubernetes functions are now built using custom resources, making Kubernetes more modular.

    Custom resources can appear and disappear in a running cluster through **dynamic registration**, and cluster admins can update custom resources independently of the cluster itself. 
    
    Once a custom resource is installed, users can create and access its objects using `kubectl`, just as they do for built-in resources like Pods.

    The custom resource created is also stored in the etcd cluster with proper replication and lifecycle management. 

---

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../10-Istio">10-Istio</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../12-Wordpress-MySQL-PVC">12-Wordpress-MySQL-PVC</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->