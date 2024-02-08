

# K8S Hands-on



### Verify pre-requirements

- **`kubectl`** - short for Kubernetes Controller - is the CLI for Kubernetes cluster and is required in order to be able to run the labs.
- In order to install `kubectl` and if required creating a local cluster, please refer to [Kubernetes - Install Tools](https://kubernetes.io/docs/tasks/tools/)

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Build the docker image](#01-Build-the-docker-image)
   - [01.01. The script which will be used for query K8S API](#0101-The-script-which-will-be-used-for-query-K8S-API)
   - [01.02. Build the docker image](#0102-Build-the-docker-image)
 - [02. Deploy the Pod to K8S](#02-Deploy-the-Pod-to-K8S)
   - [02.01. Run kustomization to deploy](#0201-Run-kustomization-to-deploy)
   - [02.02. Query the K8S API](#0202-Query-the-K8S-API)

---

<!-- inPage TOC end -->

### 01. Build the docker image

- In order to demonstrate the APi query we will build a custom docker image.
- You can use the pre-build image and skip this step

### 01.01. The script which will be used for query K8S API

- In order to be able to access K8S api from within a pod we will be using the following script:
- `api_query.sh`

  ```sh
  #!/bin/sh

  #################################
  ## Access the internal K8S API ##
  #################################
  # Point to the internal API server hostname
  API_SERVER_URL=https://kubernetes.default.svc

  # Path to ServiceAccount token
  # The service account is mapped by the K8S Api server in the pods
  SERVICE_ACCOUNT_FOLDER=/var/run/secrets/kubernetes.io/serviceaccount

  # Read this Pod's namespace if required
  # NAMESPACE=$(cat ${SERVICE_ACCOUNT_FOLDER}/namespace)

  # Read the ServiceAccount bearer token
  TOKEN=$(cat ${SERVICE_ACCOUNT_FOLDER}/token)

  # Reference the internal certificate authority (CA)
  CACERT=${SERVICE_ACCOUNT_FOLDER}/ca.crt

  # Explore the API with TOKEN and the Certificate
  curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${API_SERVER_URL}/api
  ```

### 01.02. Build the docker image

- For the pod image we will use the following Dockerfile
- `Dockerfile`

  ```Dockerfile
  FROM    alpine

  # Update and install dependencies
  RUN     apk add --update nodejs npm curl

  # Copy the endpoint script
  COPY    api_query.sh .

  # Set the execution bit
  RUN     chmod +x api_query.sh .
  ```

### 02. Deploy the Pod to K8S

- Once the image is ready we can deploy the image as pod to the cluster
- The required resources are under the k8s folder

### 02.01. Run kustomization to deploy

- Deploy to the cluster

```sh
# Remove old content if any
kubectl kustomize k8s | kubectl delete -f -

# Deploy the content
kubectl kustomize k8s | kubectl apply -f -
```

### 02.02. Query the K8S API

- Run the following script to verify that the connection to the API is working

```sh
# Get the deployment pod name
POD_NAME=$(kubectl get pod -A -l app=monitor-app -o jsonpath="{.items[0].metadata.name}")

# Print out the logs to verify that the pods is connected to the API
kubectl exec -it -n codewizard $POD_NAME sh ./api_query.sh
```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../21-Auditing">21-Auditing</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../22-Rancher">22-Rancher</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->