

# K8S Hands-on


---

# Rollout (RollingUpdate)

- In this step we will deploy the same application with several different versions and we will "switch" between them
- For learning purposes we will play a little bit with the cli

---
### Pre-Requirements
- K8S cluster - <a href="../00-VerifyCluster">Setting up minikube cluster instruction</a>

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/seifrajhi/Kubernetes-practical-exercises-Hands-on&cloudshell_workspace=KubernetesLabs&cloudshell_open_in_editor=README.md)  
**<kbd>CTRL</kbd> + <kbd>click</kbd> to open in new window**

<!-- inPage TOC start -->

---
## Lab Highlights:
 - [01. Create namespace](#01-Create-namespace)
 - [02. Create the desired deployment](#02-Create-the-desired-deployment)
 - [03. Expose nginx as service](#03-Expose-nginx-as-service)
 - [04. Verify that the pods and the service are running](#04-Verify-that-the-pods-and-the-service-are-running)
 - [05. Change the number of replicas to 3](#05-Change-the-number-of-replicas-to-3)
 - [06. Verify that now we have 3 replicas](#06-Verify-that-now-we-have-3-replicas)
 - [07. Test the deployment](#07-Test-the-deployment)
 - [08. Deploy another version of nginx](#08-Deploy-another-version-of-nginx)
 - [09. Investigate rollout history:](#09-Investigate-rollout-history)
 - [10. Lets see what was changed during the previous updates:](#10-Lets-see-what-was-changed-during-the-previous-updates)
 - [11. Undo the version upgrade by rolling back and restoring previous version](#11-Undo-the-version-upgrade-by-rolling-back-and-restoring-previous-version)
 - [12. Rolling Restart](#12-Rolling-Restart)

---

<!-- inPage TOC end -->

### 01. Create namespace

```sh
# Create the desired namespace [codewizard]
$ kubectl create namespace codewizard
namespace/codewizard created
```

- In order to set this is as your default namespace refer to: <a href="../01-Namespace#2-setting-the-default-namespace-for-kubectl">set default namespace</a>

### 02. Create the desired deployment

- We will use the `save-config` flag
  > `save-config`  
  > If true, the configuration of current object will be saved in its annotation.  
  > Otherwise, the annotation will be unchanged.  
  > This flag is useful when you want to perform kubectl apply on this object in the future.

```sh
# In case we already have this delployed we will get an error message
$ kubectl create deployment -n codewizard nginx --image=nginx:1.17 --save-config
```

### 03. Expose nginx as service

```sh
# Again: In case we already have this service we will get an error message as well
$ kubectl expose deployment -n codewizard nginx --port 80 --type NodePort
service/nginx exposed
```

### 04. Verify that the pods and the service are running

```sh
$ kubectl get all -n codewizard

# The output should be similar to this
NAME                        READY      STATUS    RESTARTS   AGE
pod/nginx-db749865c-lmgtv   1/1        Running   0          66s

NAME                        TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
service/nginx               NodePort   10.102.79.9   <none>        80:31204/TCP   30s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           66s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-db749865c   1         1         1       66s
```

### 05. Change the number of replicas to 3

```sh
$ kubectl scale deployment -n codewizard nginx --replicas=3
deployment.apps/nginx scaled
```

### 06. Verify that now we have 3 replicas

```sh
$ kubectl get pods -n codewizard
NAME                    READY   STATUS    RESTARTS   AGE
nginx-db749865c-f5mkt   1/1     Running   0          86s
nginx-db749865c-jgcvb   1/1     Running   0          86s
nginx-db749865c-lmgtv   1/1     Running   0          4m44s
```

### 07. Test the deployment

```sh
# !!! Get the Ip & port for this service
$ kubectl get services -n codewizard -o wide # Write down the port number
NAME    TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE    SELECTOR
nginx   NodePort   10.102.79.9   <none>        80:31204/TCP   7m7s   app=nginx

$ kubectl cluster-info  # Get the cluster IP
Kubernetes control plane is running at https://192.168.49.2:8443

# Using the above <host>:<port> test the nginx
# -I is for getting the headers
$ curl -sI <host>:<port>

# The response should display the nginx version
example: curl -sI 192.168.49.2:31204

HTTP/1.1 200 OK
Server: nginx/1.17.10 <------------ This is the pod version
Date: Fri, 15 Jan 2021 20:13:48 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 14 Apr 2020 14:19:26 GMT
Connection: keep-alive
ETag: "5e95c66e-264"
Accept-Ranges: bytes
...
```

### 08. Deploy another version of nginx

```sh
# Deploy another version of nginx (1.16)
$ kubectl set image deployment -n codewizard nginx nginx=nginx:1.16 --record
deployment.apps/nginx image updated

# Check to verify that the new version deployed - same as in previous step
$ curl -sI <host>:<port>

# The response should display the new version
HTTP/1.1 200 OK
Server: nginx/1.16.1 <------------ This is the pod version (new version)
Date: Fri, 15 Jan 2021 20:16:11 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 10:05:00 GMT
Connection: keep-alive
ETag: "5d528b4c-264"
Accept-Ranges: bytes
```

### 09. Investigate rollout history:

- The rollout history command print out all the saved records

```sh
$ kubectl rollout history deployment nginx -n codewizard
deployment.apps/nginx
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment nginx nginx=nginx:1.16 --record=true
3         kubectl set image deployment nginx nginx=nginx:1.15 --record=true
```

### 10. Lets see what was changed during the previous updates:

- Print out the rollout changes

```sh
# replace the X with 1 or 2 or any number revision id
$ kubectl rollout history deployment nginx -n codewizard --revision=1
deployment.apps/nginx with revision #1
Pod Template:
  Labels:       app=nginx
        pod-template-hash=db749865c
  Containers:
   nginx:
    Image:      nginx:1.17
    Port:       <none>
    Host Port:  <none>
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
```

### 11. Undo the version upgrade by rolling back and restoring previous version

```
# Check the current nginx version
$ curl -sI <host>:<port>

# Undo the last deployment
$ kubectl rollout undo deployment nginx
deployment.apps/nginx rolled back

# Verify that we have the previous version
$ curl -sI <host>:<port>
```

### 12. Rolling Restart

**Note:**

- If we deploy out deplymnet with `imagePullPolicy: always` we can use `rollout restart` to force K8S to grab the latest image
- **This is the fastest restart method those days**

```
# Force pods restart
kubectl rollout restart deployment [deployment_name]
```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../03-Deployments-Declarative">03-Deployments-Declarative</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../05-Services">05-Services</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->