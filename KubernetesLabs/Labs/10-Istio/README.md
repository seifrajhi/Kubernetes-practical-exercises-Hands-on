

# K8S Hands-on


---
# Istio
![](../../resources/k8s-istio-gcp.png)

---
## Pre-Requirements 
- K8S cluster (this demo is explained with minikube)

- In this lab we will get to know Istio (https://istio.io/). Istio is an implementation os `Service Mesh`, there are other implementations as well but istio is a known one so i have chosen to demonstrate Istio.
- Istio has a lot of features build in along side with addons and much more.
- In this lab we will focus on few of those features

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Download latest Istio release (Linux)](#01-Download-latest-Istio-release-Linux)
 - [01.01 Add the istioctl client to your path (Linux or macOS):](#0101-Add-the-istioctl-client-to-your-path-Linux-or-macOS)
   - [01.02. Install Istio](#0102-Install-Istio)
   - [01.03. Add the required label](#0103-Add-the-required-label)
   - [01.02. Install Kiali server](#0102-Install-Kiali-server)
 - [02. Deploy the demo application](#02-Deploy-the-demo-application)
   - [02.01. Check the installation](#0201-Check-the-installation)
   - [02.02. Verify that Istio is working](#0202-Verify-that-Istio-is-working)

---

<!-- inPage TOC end -->

#### Step 01

### 01. Download latest Istio release (Linux)
- I have prepared a startup script which will start minikube, install istio & kiali
```sh
# Set the desired Istio version to download and install
export ISTIO_VERSION=1.10.3

# Set the Istio home, we will use this home for the installation
export ISTIO_HOME=${PWD}/istio-${ISTIO_VERSION}

# Download Istio with the specific verison
curl -L https://istio.io/downloadIstio | \
      ISTIO_VERSION=$ISTIO_VERSION \
      TARGET_ARCH=arm64 \
      sh -

# Navigate to the Istio folder
# The installation directory contains:
# Sample applications in samples/
# The istioctl client binary in the bin/ directory.
```
### 01.01 Add the istioctl client to your path (Linux or macOS):
```
# Add the istio cli to the path
export PATH="$PATH:${ISTIO_HOME}/bin"

```

### 01.02. Install Istio
```sh
# Check if our cluster is ready for istio
istioctl x precheck 

# For this installation, we use the demo configuration profile
# Istio support different profiles
$ istioctl install --set profile=demo -y

# The output should be something like
✔ Istio core installed
✔ Istiod installed
✔ Egress gateways installed
✔ Ingress gateways installed
✔ Installation complete
```

### 01.03. Add the required label
- Istio will inject its proxy/envoy/sidecar, once we will add the required label to the desired namespace.
- Add a label to our namespace, instructing Istio to **automatically inject Envoy sidecar** proxies when you deploy your application later:
```sh
$ kubectl label namespace default istio-injection=enabled
namespace/default labeled
```

### 01.02. Install Kiali server
- We will use Kiali to track our traffic
```sh
# Install kiali server
helm install \
  --namespace   istio-system \
  --set         auth.strategy="anonymous" \
  --repo        https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```

### 02. Deploy the demo application
- The demo application for this tutorial is one of istio samples
```sh
# install the demo application
kubectl apply -f https://github.com/istio/istio/blob/master/samples/bookinfo/platform/kube/bookinfo.yaml
```


### 02.01. Check the installation
- The application will start. 
- As each pod becomes ready, the Istio sidecar will be deployed along with it.
```
$ kubectl get all
NAME                                  READY   STATUS   
pod/details-v1-79c697d759-vwqdw       2/2     Running   
pod/productpage-v1-65576bb7bf-w2gpr   2/2     Running   
pod/ratings-v1-7d99676f7f-krwk9       2/2     Running   
pod/reviews-v1-987d495c-ltxvx         2/2     Running   
pod/reviews-v2-6c5bf657cf-r74lq       2/2     Running   
pod/reviews-v3-5f7b9f4f77-qgtn5       2/2     Running 

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    
service/details       ClusterIP   10.109.142.110   <none>        9080/TCP   
service/kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP    
service/productpage   ClusterIP   10.106.91.75     <none>        9080/TCP   
service/ratings       ClusterIP   10.106.35.0      <none>        9080/TCP   
service/reviews       ClusterIP   10.99.208.202    <none>        9080/TCP   

NAME                             READY   UP-TO-DATE   AVAILABLE   
deployment.apps/details-v1       1/1     1            1           
deployment.apps/productpage-v1   1/1     1            1           
deployment.apps/ratings-v1       1/1     1            1           
deployment.apps/reviews-v1       1/1     1            1           
deployment.apps/reviews-v2       1/1     1            1           
deployment.apps/reviews-v3       1/1     1            1           

NAME                                        DESIRED   CURRENT   READY   
replicaset.apps/details-v1-79c697d759       1         1         1       
replicaset.apps/productpage-v1-65576bb7bf   1         1         1       
replicaset.apps/ratings-v1-7d99676f7f       1         1         1       
replicaset.apps/reviews-v1-987d495c         1         1         1       
replicaset.apps/reviews-v2-6c5bf657cf       1         1         1       
replicaset.apps/reviews-v3-5f7b9f4f77       1         1         1       
```

### 02.02. Verify that Istio is working
- Run this command to see if the app is running inside the cluster and serving HTML pages by checking for the page title in the response:
```sh
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" \
        -c ratings \
        -- curl \
        -s productpage:9080/productpage \
        | grep -o "<title>.*</title>"
```        

---
# Lab - Istio Demo with working example




<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../09-StatefulSet">09-StatefulSet</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../11-CRD-Custom-Resource-Definition">11-CRD-Custom-Resource-Definition</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->