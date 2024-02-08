

# K8S Hands-on



---

# Helm Chart

- In This tutorial you will learn the basics of Helm Charts (version 3).
- This demo will cover the following:
  - build
  - package
  - install
  - list packages

---

## PreRequirements

- [Helm](https://helm.sh/docs/intro/install/)
- K8S cluster

---

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)

### **<kbd>CTRL</kbd> + click to open in new window**

---

## `codewizard-nginx-helm`

- The custom `codewizard-nginx-helm` Helm chart is build upon the following K8S resources:

  - ConfigMap
  - Deployment
  - Service

- Since we are using Helm we also have the following Helm resources:
  - Chart.yaml
  - values.yaml
  - templates/\_helpers.tpl

---

### Step 1 - Pack

Package the `codewizard-nginx-helm` chart

## `helm package`

```
# Package a chart directory into a chart archive.
# `helm package` packages a chart into a **versioned chart archive file**.
# If a path is given, this will look at that path for a chart (which must contain a `Chart.yaml` file) and then package that directory.

helm package codewizard-nginx-helm
```

### Step 2 - install

Install the `codewizard-nginx-helm` chart into Kubernetes cluster

```
# Install the packed helm
helm install charts-demo codewizard-nginx-helm-0.1.0.tgz
```

### STEP 3: Verify the installation

- Examine newly created Helm chart release, and all cluster created resources

```
# List the installed helms
helm ls

# Check the resources
kubectl get all -A
```

#### STEP 4: Test the service

- Perform an HTTP GET request, send it to the newly created cluster service
- Confirm that the response contains the `CloudAcademy DevOps 2020 v1` message passed from the `values.yaml` file

```sh
kubectl run \
        -it \
        --rm \
        --restart=Never \
        --image=busybox bbox1 \
        -- /bin/sh -c "wget -qO- http://charts-demo-codewizard-nginx-helm"
```

### STEP 5: Upgrade the release to newer version

- Perform a Helm upgrade on the `charts-demo` release

```
# upgrade and pass different value than the one from the default values
helm  upgrade \
      charts-demo \
      codewizard-nginx-helm-0.1.0.tgz \
      --set nginx.conf.message="Helm Rocks"
```

### STEP 6: Check the upgrade

- Perform another HTTP GET request.
- Confirm that the response now has the updated message `Helm Rocks`

```sh
kubectl run \
        -it \
        --rm \
        --restart=Never \
        --image=busybox bbox1 \
        -- /bin/sh -c "wget -qO- http://charts-demo-codewizard-nginx-helm"
```

### STEP 7:

Examine the `charts-demo` release history

```
helm history charts-demo
```

# STEP 8:

Rollback the `charts-demo` release to previous version

```
helm rollback charts-demo
```

# STEP 9:

Perform another HTTP GET request. Confirm that the response has now been reset to the `CloudAcademy DevOps 2020 v1` message stored in the `values.yaml` file

```
kubectl run --image=busybox bbox1 --rm -it --restart=Never \
-- /bin/sh -c "wget -qO- http://charts-demo-codewizard-nginx-helm"
```

# STEP 10:

Uninstall the `charts-demo` release

```
helm uninstall charts-demo
```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../12-Wordpress-MySQL-PVC">12-Wordpress-MySQL-PVC</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../14-Logging">14-Logging</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->
