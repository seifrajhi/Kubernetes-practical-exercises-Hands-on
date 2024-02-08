

# K8S Hands-on


---
# Data Store

### Pre-Requirements
- K8S cluster - <a href="../00-VerifyCluster">Setting up minikube cluster instruction</a>

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)  
**<kbd>CTRL</kbd> + <kbd>click</kbd> to open in new window**

---

## Secrets and ConfigMaps

- Secrets/ConfigMap are ways to store and inject configurations into your deployments.
- Secrets usually store passwords,certificates, API keys and more.
- ConfigMap usually store configuration (data).

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Create namespace and clear previous data if there is any](#01-Create-namespace-and-clear-previous-data-if-there-is-any)
 - [02. Build the docker container](#02-Build-the-docker-container)
   - [02.01. write the server code](#0201-write-the-server-code)
   - [02.02. Write the DockerFile](#0202-Write-the-DockerFile)
   - [02.03. Build the docker container](#0203-Build-the-docker-container)
   - [02.04. Test the container](#0204-Test-the-container)
 - [03. Using K8S deployment &amp; Secrets/ConfigMap](#03-Using-K8S-deployment--SecretsConfigMap)
   - [03.01. Writing the deployment &amp; Service file](#0301-Writing-the-deployment--Service-file)
   - [03.02. Deploy to cluster](#0302-Deploy-to-cluster)
   - [03.03. Test the app](#0303-Test-the-app)
 - [04. Using Secrets &amp; config maps](#04-Using-Secrets--config-maps)
   - [04.01. Create the desired secret and config map for this lab](#0401-Create-the-desired-secret-and-config-map-for-this-lab)
   - [04.02. Updating the Deployment to read the values from Secrets &amp; ConfigMap](#0402-Updating-the-Deployment-to-read-the-values-from-Secrets--ConfigMap)
   - [04.03. Update the deployment to read values from K8S resources](#0403-Update-the-deployment-to-read-values-from-K8S-resources)
   - [04.04. Test the changes](#0404-Test-the-changes)

---

<!-- inPage TOC end -->

## Lets play with Secrets first

### 01. Create namespace and clear previous data if there is any

```sh
# If the namespace already exist and contains data from previous steps, lets clean it
kubectl delete namespace codewizard

# Create the desired namespace [codewizard]
$ kubectl create namespace codewizard
namespace/codewizard created
```

### You can skip section #2 if you don't wish to build and push your docker container

### 02. Build the docker container

#### 02.01. write the server code
- For this demo we will use a tiny NodeJS server which will consume the desired configuration values from the secret
- This is the code of our server [server.js](server.js)

```js
//
// server.js
//
const 
  // Get those values in runtime.
  // The variables will be passed from the Docker file and later on from K8S ConfingMap/ecret
  language = process.env.LANGUAGE,
  token = process.env.TOKEN;

require("http")
  .createServer((request, response) => {
    response.write(`Language: ${language}`);
    response.write(`Token   : ${token}\n`);
    response.end(`\n`);
  })
  // Set the default port to 5000
  .listen(process.env.PORT || 5000 );
```

#### 02.02. Write the DockerFile

- First lets wrap it up as docker container
- If you wish you can skip this and use the existing docker image: `nirgeier/k8s-secrets-sample`
- In the docker file we will set the `ENV` for or variables

```Dockerfile
# Base Image
FROM        node

# exposed port - same port is defined in the server.js
EXPOSE      5000

# The "configuration" which we pass in runtime
# The server will "read" those variables at run time and will print them out
ENV         LANGUAGE    Hebrew
ENV         TOKEN       Hard-To-Guess

# Copy the server to the container
COPY        server.js .

# start the server
ENTRYPOINT  node server.js
```

#### 02.03. Build the docker container
```sh
# The container name is prefixed withthe Dockerhub account
# !!! You should replace the prefix to your dockerhub account
# In the sample the username wis `nirgeier`
$ docker build . -t nirgeier/k8s-secrets-sample

# The output should be similar to this
Sending build context to Docker daemon   12.8kB
Step 1/6 : FROM        node
latest: Pulling from library/node
2587235a7635: Pull complete
953fe5c215cb: Pull complete
d4d3f270c7de: Pull complete
ed36dafe30e3: Pull complete
00e912dd434d: Pull complete
dd25ee3ea38e: Pull complete
7e835b17ced9: Pull complete
79ae84aa9e91: Pull complete
629164f2c016: Pull complete
Digest: sha256:3a9d0636755ebcc8e24148a148b395c1608a94bb1b4a219829c9a3f54378accb
Status: Downloaded newer image for node:latest
 ---> d6740064592f
Step 2/6 : EXPOSE      5000
 ---> Running in 060220eaa65b
Removing intermediate container 060220eaa65b
 ---> 68262a3e6741
Step 3/6 : ENV         LANGUAGE    Hebrew
 ---> Running in c404e7e6fa16
Removing intermediate container c404e7e6fa16
 ---> 45fcf1fe03aa
Step 4/6 : ENV         TOKEN       Hard-To-Guess
 ---> Running in d3c1491f9de5
Removing intermediate container d3c1491f9de5
 ---> 71e8acdbdab2
Step 5/6 : COPY        server.js .
 ---> 42233d2b66a8
Step 6/6 : ENTRYPOINT  node server.js
 ---> Running in 223629e16589
Removing intermediate container 223629e16589
 ---> f5cbb1895d66
Successfully built f5cbb1895d66
Successfully tagged nirgeier/k8s-secrets-sample:latest
```
#### 02.04. Test the container

```sh
# Run the docker container which you build earlier,
# replace the name if you used your own name
# and check the response from the serrver 
# It should print out the variables which were defined in side the DockerFile 
$ docker run -d -p5000:5000 nirgeier/k8s-secrets-sample --name server

# Get the response from the container 
# The port is the one which we exposed inside the DockerFile
curl 127.0.0.1:5000

# Response:
Language: Hebrew
Token   : Hard-To-Guess
```

- Stop the container
```sh
# Stop the running contatiner
# We are using the name which we passed in the `docker run` command --name <containr name>
docker stop server
```
- Push the container to your docker hub account if you wish

### 03. Using K8S deployment & Secrets/ConfigMap

### 03.01. Writing the deployment & Service file

- Deploy the docker container you prepared in the previous step with the following `Deployment` file.
- In this sample we will define the values in the yaml file,later on we will use Secrets/ConfigMap [variables-from-yaml.yaml](./variables-from-yaml.yaml)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: codewizard
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secrets-app
  namespace: codewizard
spec:
  replicas: 1
  selector:
    matchLabels:
      name: secrets-app
  template:
    metadata:
      labels:
        name: secrets-app
    spec:
      containers:
        - name: secrets-app
          image: nirgeier/k8s-secrets-sample
          imagePullPolicy: Always
          ports:
            - containerPort: 5000
          env:
            - name: LANGUAGE
              value: Hebrew
            - name: TOKEN
              value: Hard-To-Guess2
          resources:
            limits:
              cpu: "500m"
              memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: codewizard-secrets
  namespace: codewizard
spec:
  selector:
    app: codewizard-secrets
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
```

### 03.02. Deploy to cluster
```
$ kubectl apply -n codewizard -f variables-from-yaml.yaml
deployment.apps/codewizard-secrets configured
service/codewizard-secrets created
```
### 03.03. Test the app

- We will need a second container for executing the curl request.
- We will us a busyBox image for this purpose
```sh
# grab the name of the pod
$ kubectl get pods -n codewizard

# Output
NAME                                  READY   STATUS    RESTARTS   AGE
codewizard-secrets-56f556c758-2mknc   1/1     Running   0          6m27s

# Login to the container and test the reponse
# kubectl exec -it -n codewizard <pod name> -- sh
# For the above output we will use
kubectl exec -it -n codewizard codewizard-secrets-56f556c758-2mknc -- sh

# Now get the server response (from inside the container)
$ curl localhost:5000                    

# Response
Language: Hebrew
Token   : Hard-To-Guess2

```

### 04. Using Secrets & config maps

### 04.01. Create the desired secret and config map for this lab

```sh
# Create the secret 
#   Key   = Token
#   Value = Hard-To-Guess3
$ kubectl create -n codewizard secret generic token --from-literal=TOKEN=Hard-To-Guess3
secret/token created

# Create the config map 
#   Key   = LANGUAGE
#   Value = English
$ kubectl create -n codewizard configmap language --from-literal=LANGUAGE=English
configmap/language created

# Verify that the resources have been created:
$ kubectl get secrets,cm -n codewizard
NAME                         TYPE                                  DATA   AGE
secret/default-token-8hzhn   kubernetes.io/service-account-token   3      14m
secret/token                 Opaque                                1      80s
NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      14m
configmap/language           1      44s

# Like other resources we can use describe to view the resource
$ kubectl describe secret token -n codewizard
Name:         token
Namespace:    codewizard
Labels:       <none>
Annotations:  <none>

Type:  Opaque <----- The content is stored as BASE64

Data
====
TOKEN:  14 bytes

# Same way for the ConfigMap
$ kubectl describe cm language -n codewizard
Name:         language
Namespace:    codewizard
Labels:       <none>
Annotations:  <none>
Data
====
LANGUAGE:
----
English
Events:  <none>
```

### 04.02. Updating the Deployment to read the values from Secrets & ConfigMap

- Change the `env` section to the following:
```yaml
          env:
            - name: LANGUAGE
              valueFrom:
                configMapKeyRef:    # This value will be read from the config map
                  name:   language  # The name of the ConfigMap
                  key:    LANGUAGE  # The key in the config map
            - name: TOKEN
              valueFrom:
                  secretKeyRef:         # This value will be read from the secret
                      name:   token     # The name of the secret
                      key:    TOKEN     # The key in the secret
```

### 04.03. Update the deployment to read values from K8S resources

```sh
$ kubectl apply -n codewizard -f variables-from-secrets.yaml
deployment.apps/codewizard-secrets configured
service/codewizard-secrets unchanged
```
### 04.04. Test the changes
- Refer to step 3.3 for testing your server
```sh
# Login to the server
# In this sample this is the pod name: codewizard-secrets-76d99bdc54-s66vl
kubectl exec -it codewizard-secrets-76d99bdc54-s66vl -n codewizard -- sh

# Test the changes to verify that they are set from the Secret/ConfigMap
curl localhost:5000

# Out put should be
Language: English
Token   : Hard-To-Guess3
```
---

### !!! Note
> Pods are not recreated or updated automatically when secrets or ConfigMaps change so you will have to restart your pods

- To update existing secrets or ConfigMap:
```
$ kubectl create secret generic token -n codewizard --from-literal=Token=Token3 -o yaml --dry-run=client | kubectl replace -f -
secret/token replaced
```
- Test your server to and verify that you see the old values
- Delete the old pods so they can come back to life with the new values
- Test your server again, now you should see view the changes

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../05-Services">05-Services</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../07-nginx-Ingress">07-nginx-Ingress</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->