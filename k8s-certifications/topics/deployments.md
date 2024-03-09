# [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

A Deployment provides declarative updates for Pods and ReplicaSets.

 1. [Basics](#basics)
 2. [Deployment HA & Self Healing](#deployment-self-healing)
 2. [Deployment Scaling](#deployment-scaling)
 3. [Deployment Rollout](#deployment-rollout)
 4. [Deployment Deletion](#deployment-deletion)
 5. [HPA](#hpa)

<br />

## Basics
 
<br />

### Check number of deployments in the default namespace

<br />

<details><summary>show</summary><p>

```bash
kubectl get deployments
# OR 
kubectl get deploy
```

</p></details>

<br />

### Create deployment named `nginx-deployment` with `nginx:1.20` image with `3` replicas

<br />

<details><summary>show</summary><p>

```bash
kubectl create deploy nginx-deployment --image nginx:1.20 && kubectl scale deploy nginx-deployment --replicas 3
# deployment.apps/nginx-deployment created
# deployment.apps/nginx-deployment scaled

kubectl get replicaset # check the replica set created
# NAME                         DESIRED   CURRENT   READY   AGE
# nginx-deployment-bd78d5dc6   3         3         3       37s

```

OR 

```yaml
cat << EOF > nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.20
        name: nginx
EOF

kubectl apply -f nginx-deployment.yaml

```

</p></details>

<br />

### View the YAML of `nginx-deployment` deployment

<br />

<details><summary>show</summary><p>

```bash
kubectl get deploy nginx-deployment -o yaml
```

</p></details> 

<br />

### Create a new deployment for running nginx with the following parameters
- Name the deployment `frontend` and configure with 4 replicas
- Configure the pod with a container image of nginx:1.21
- Set an environment variable of NGINX PORT=8080 and also expose that port for the container above

<br />

<details><summary>show</summary><p>

```bash
kubectl create deployment frontend --replicas=4 --image=nginx:1.21 --dry-run=client -o yaml > frontend.yaml
# --replicas is newly introduced and if it does not work use it without the replicas
kubectl create deployment frontend --image=nginx:1.21 --dry-run=client -o yaml > frontend.yaml
```

#### Edit the frontend.yaml for replicas, port and env variable

```yaml
cat << EOF > frontend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 4
  selector:
    matchLabels:
      app: frontend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: frontend
    spec:
      containers:
      - image: nginx:1.21
        name: nginx
        ports:
        - containerPort: 8080
        env:
        - name: NGINX_PORT
          value: "8080"
        resources: {}
status: {}
EOF

kubectl apply -f frontend.yaml
```

</p></details> 

<br />

### Create a deployment as follows:
- Name: nginx-random using the nginx image
- Exposed via a service nginx-random
- Ensure that the service & pod are accessible via their respective DNS records
- Use the utility nslookup to lookup the DNS records of the service & pod

<br />

<details><summary>show</summary><p>

```bash
kubectl create deployment nginx-random --image=nginx
kubectl expose deployment nginx-random --name=nginx-random --port=80 --target-port=80
```

#### Verify the nslookup works. (Busybox latest version had issues with service nslookup, so using dnsutils)

```yaml
cat << EOF > dnsutils.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils
spec:
  containers:
  - name: dnsutils
    image: k8s.gcr.io/e2e-test-images/jessie-dnsutils:1.3
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF

kubectl apply -f dnsutils.yaml

kubectl exec dnsutils -- nslookup nginx-random
# Server:         10.96.0.10
# Address:        10.96.0.10#53

# Name:   nginx-random.default.svc.cluster.local
# Address: 10.110.119.135

kubectl get pods -l app=nginx-random -o wide
# NAME                            READY   STATUS    RESTARTS   AGE     IP          NODE           NOMINATED NODE   READINESS GATES
# nginx-random-77fb464776-sbp8v   1/1     Running   0          8m25s   10.50.0.8   controlplane   <none>           <none>

kubectl exec dnsutils -- nslookup 10.50.0.8
# Server:         10.96.0.10
# Address:        10.96.0.10#53

# 8.0.50.10.in-addr.arpa  name = 10-50-0-8.nginx-random.default.svc.cluster.local.

```

</p></details>

<br />

## Deployment Self healing

<br />

### Create a deployment named nginx-ha using nginx image with 3 replicas to test self-healing properties. Delete all pod and check the behaviour.

<br />

<details><summary>show</summary><p>

#### Create deployment

```bash
kubectl create deployment nginx-ha --image=nginx --replicas=3

kubectl get pods -l app=nginx-ha
# NAME                       READY   STATUS    RESTARTS   AGE
# nginx-ha-684994c76-2j4w8   1/1     Running   0          57s
# nginx-ha-684994c76-7ssm8   1/1     Running   0          57s
# nginx-ha-684994c76-kdp28   1/1     Running   0          57s
```

#### Delete all the pods and check behaviour as new pods are created.

```bash
kubectl delete pods -l app=nginx-ha --force

kubectl get pods -l app=nginx-ha -w
# NAME                       READY   STATUS              RESTARTS   AGE
# nginx-ha-684994c76-m5n28   0/1     ContainerCreating   0          3s
# nginx-ha-684994c76-pqfj4   0/1     ContainerCreating   0          3s
# nginx-ha-684994c76-qxgfl   0/1     ContainerCreating   0          2s
# nginx-ha-684994c76-pqfj4   1/1     Running             0          7s
# nginx-ha-684994c76-m5n28   1/1     Running             0          9s
# nginx-ha-684994c76-qxgfl   1/1     Running             0          8s
```

</p></details>

<br />

## Deployment Scaling

<br />

### Scale up the `nginx-deployment` from 3 replica to 5 replicas

<br />

<details><summary>show</summary><p>

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

OR

#### Edit the replica set definition file and use `kubectl apply -f nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 5 # Update the replicas count
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.20 
        name: nginx
```

</p></details>

<br />

### Scale down the `nginx-deployment` from 5 replica to 3 replicas

<br />

<details><summary>show</summary><p>

```bash
kubectl scale deployment nginx-deployment --replicas=3
```

OR

#### Edit the replica set definition file and use `kubectl apply -f nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 3 # Update the replicas count
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.20 
        name: nginx
```

</p></details>

<br />

### Scale the deployment with below specs for availability, and create a service to expose the deployment within your infrastructure. Start with the deployment named ha-deployment which has already been deployed to the namespace ha . 
Edit it to:
- create namespace ha
- Add the func=frontend key/value label to the pod template metadata to identify the pod for the service definition
- Have 4 replicas
- Exposes the service on TCP port 8080
- is mapped to the pods defined by the specification of ha-deployment
- Is of type NodePort
- Has a name of cherry

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ha-deployment
  name: ha-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ha-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: ha-deployment
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
EOF 
```

<details><summary>show</summary><p>

#### Create namespace `ha`

```bash
kubectl create namespace ha
```

#### Edit the deployment specs for 4 replicas and label

```yaml
cat << EOF > ha-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ha-deployment
  name: ha-deployment
spec:
  replicas: 4 # 4 replicas
  selector:
    matchLabels:
      app: ha-deployment
  strategy: {}
  template:
    metadata:
      labels:
        app: ha-deployment
        func: frontend # label added to pod
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
EOF

kubectl apply -f ha-deployment.yaml -n ha

kubectl get pods -n ha
# NAME                             READY   STATUS    RESTARTS   AGE
# ha-deployment-66b7f8d45b-4pndp   1/1     Running   0          22s
# ha-deployment-66b7f8d45b-5r77r   1/1     Running   0          22s
# ha-deployment-66b7f8d45b-7hq7q   1/1     Running   0          22s
# ha-deployment-66b7f8d45b-szklj   1/1     Running   0          22s
```

#### Expose the deployment as a service with name cherry

```bash
kubectl expose deployment ha-deployment --name cherry --type NodePort --port 8080 --target-port 80 --namespace ha

kubectl get svc -n ha
# NAME     TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
# cherry   NodePort   10.104.241.152   <none>        8080:30321/TCP   20s

# test using any node ip and node port
# curl http://<node-ip>:30321/
```

</p></details>

<br />

## Deployment Rollout

<br />

### Check the rollout for `nginx-deployment` deployment

<br />

<details><summary>show</summary><p>

```bash
kubectl rollout status deploy nginx-deployment
# deployment "nginx-deployment" successfully rolled out
```

</p></details> 

<br />

### Update the `nginx-deployment` deployment image to `nginx:1.20.2`

<br />

<details><summary>show</summary><p>

```bash
kubectl set image deploy nginx-deployment nginx=nginx:1.20.2
# deployment.apps/nginx-deployment image updated
```

OR 

#### Update the `nginx-deployment.yaml` file and `kubectl apply -f nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.20.2 # Update the image
        name: nginx
```

</p></details> 

<br />

### Check the rollout history for `nginx-deployment` deployment and confirm that the replicas are OK

<br />

<details><summary>show</summary><p>

```bash
kubectl rollout history deploy nginx-deployment
# deployment.apps/nginx-deployment 
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>

kubectl get replicaset # check that a new replica set has been created
# NAME                          DESIRED   CURRENT   READY   AGE
# nginx-deployment-7cd9b6bb76   3         3         3       36s
# nginx-deployment-bd78d5dc6    0         0         0       2m40s
```

</p></details> 

<br />

### Undo the latest rollout and verify that new pods have the old image (nginx:1.20)

<br />

<details><summary>show</summary><p>

```bash
kubectl rollout undo deploy nginx-deployment # wait a bit
# deployment.apps/nginx-deployment rolled back

# verify the rollback 

kubectl rollout history deploy nginx-deployment
# deployment.apps/nginx-deployment 
# REVISION  CHANGE-CAUSE
# 2         <none>
# 3         <none>

kubectl get replicaset
# NAME                          DESIRED   CURRENT   READY   AGE
# nginx-deployment-7cd9b6bb76   0         0         0       4m12s
# nginx-deployment-bd78d5dc6    3         3         3       6m16s

kubectl get pod # select one 'Running' Pod

kubectl describe pod nginx-deployment-xxx-xxx | grep -i image # should be nginx:1.20 - need to update !!

```

</p></details> 

<br />

### Do an on purpose update of the deployment with a wrong image `nginx:1.202.333`

<br />

<details><summary>show</summary><p>

```bash
kubectl set image deploy nginx-deployment nginx=nginx:1.202.333
```

OR 

#### Update the `nginx-deployment.yaml` file and `kubectl apply -f nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.202.333 # Update the image
        name: nginx
```

</p></details> 

<br />

### Verify that something's wrong with the rollout

<br />

<details><summary>show</summary><p>

```bash
kubectl rollout status deploy nginx-deployment # would show 'Waiting for deployment "nginx-deployment" rollout to finish: 1 out of 3 new replicas have been updated...'

kubectl get pod # would show status as 'ErrImagePull' or 'ImagePullBackOff'
# NAME                                READY   STATUS         RESTARTS   AGE
# nginx-deployment-68b88f4dcf-8drvq   0/1     ErrImagePull   0          71s
# nginx-deployment-bd78d5dc6-59x4r    1/1     Running        0          7m16s
# nginx-deployment-bd78d5dc6-cxg7l    1/1     Running        0          7m19s
# nginx-deployment-bd78d5dc6-xxkdj    1/1     Running        0          7m14s
```

</p></details> 

<br />

### Return the deployment to the second revision (number 2) and verify the image is nginx:1.19.8

<br />

<details><summary>show</summary><p>

```bash
kubectl rollout undo deploy nginx-deployment --to-revision=2

# verify 
kubectl rollout history deploy nginx-deployment
# deployment.apps/nginx-deployment 
# REVISION  CHANGE-CAUSE
# 3         <none>
# 4         <none>
# 5         <none>

kubectl describe deploy nginx-deployment | grep Image: # should show nginx:1.20.2

kubectl rollout status deploy nginx-deployment # Everything should be OK

```

</p></details> 

<br />

### Check the details of the fourth revision (number 4)

<br />

<details><summary>show</summary><p>

```bash
kubectl rollout history deploy nginx-deployment --revision=4 # check the wrong image displayed here
# deployment.apps/nginx-deployment with revision #4
# Pod Template:
#   Labels:       app=nginx-deployment
#         pod-template-hash=68b88f4dcf
#   Containers:
#    nginx:
#     Image:      nginx:1.202.333
#     Port:       <none>
#     Host Port:  <none>
#     Environment:        <none>
#     Mounts:     <none>
#   Volumes:      <none> 
```

</p></details> 

<br />

## Deployment Deletion

<br />

### Delete the `nginx-deployment` deployment

<br />

<details><summary>show</summary><p>

```bash
kubectl delete deployment nginx-deployment
# OR
kubectl delete -f nginx-deployment.yaml
```

</p></details>

<br />

### As a Kubernetes application developer you will often find yourself needing to update a running application. Please complete the following using the following specs:
- Update the web1 deployment with a maxSurge of 5% and a maxUnavailable of 2%
- Perform a rolling update of the web1 deployment, changing the nginx image version to 1.21
- Roll back the web1 deployment to the previous version

```yaml
cat << EOF > web1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web1
  name: web1
spec:
  replicas: 10
  selector:
    matchLabels:
      app: web1
  template:
    metadata:
      labels:
        app: web1
    spec:
      containers:
      - image: nginx:1.12-alpine
        name: web1
EOF

kubectl apply -f web1.yaml
```

<details><summary>show</summary><p>

#### Edit the deployment to update the rolling update strategy for maxSurge & maxUnavailable

```yaml
cat << EOF > web1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web1
  name: web1
spec:
  replicas: 10
  selector:
    matchLabels:
      app: web1
  strategy:
    rollingUpdate: # update the rolling update strategy for maxSurge & maxUnavailable
      maxSurge: 5% 
      maxUnavailable: 2%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: web1
    spec:
      containers:
      - image: nginx:1.20-alpine
        name: web1
EOF

kubectl apply -f web1.yaml
```

#### Update the image to 1.21-alpine

```bash
kubectl set image deployment web1 web1=nginx:1.21-alpine
```

#### Check rollout history and undo rollout

```bash
kubectl rollout history deployment web1
# deployment.apps/web1 
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>
# 3         <none>

kubectl rollout history deploy web1 --revision=3
# deployment.apps/web1 with revision #3
# Pod Template:
#   Labels:       app=web1
#         pod-template-hash=848b67cbfc
#   Containers:
#    web1:
#     Image:      nginx:1.21-alpine
#     Port:       <none>
#     Host Port:  <none>
#     Environment:        <none>
#     Mounts:     <none>
#   Volumes:      <none>

kubectl rollout undo deploy web1 --to-revision=2
# deployment.apps/web1 rolled back

kubectl rollout history deployment web1
# deployment.apps/web1 
# REVISION  CHANGE-CAUSE
# 1         <none>
# 3         <none>
# 4         <none>
```

</p></details>

<br />

### Create a deployment as follows:
 - Name: nginx-app
 - Using container nginx with version 1.20-alpine
 - The deployment should contain 3 replicas
 - Next, deploy the application with new version 1.21.4-alpine, by performing a rolling update.
 - Finally, rollback that update to the previous version 1.11.10-alpine.

<br />

<details><summary>show</summary><p></p></details>

```bash
kubectl create deployment nginx-app --image=1.20-alpine --replicas=3
kubectl set image deployment nginx-app 1-20-alpine-2v92q=1.21.4-alpine # use the container name
deployment.apps/nginx-app image updated
kubectl rollout history deployment nginx-app
# deployment.apps/nginx-app 
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>
kubectl rollout undo deploy nginx-app
# deployment.apps/nginx-app rolled back
kubectl rollout history deployment nginx-app
# deployment.apps/nginx-app 
# REVISION  CHANGE-CAUSE
# 2         <none>
# 3         <none>
```

</p></details>

<br />

## Troubleshooting

<br />

### A deployment is falling on the cluster. Identify the issue and fix the problem.

```yaml
cat << EOF > nginx-fix.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-fix
  name: nginx-fix
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nqinx
        name: nginx
EOF

kubectl apply -f nginx-fix.yaml
```

<details><summary>show</summary><p>

#### The image nquix is invalid. Change the image to nginx.

```bash
kubectl get deploy nginx-fix
# NAME        READY   UP-TO-DATE   AVAILABLE   AGE
# nginx-fix   0/3     3            0           16s

kubectl get pods -l app=nginx
# NAME                         READY   STATUS         RESTARTS   AGE
# nginx-fix-7cf9964fc7-9bkln   0/1     ErrImagePull   0          38s
# nginx-fix-7cf9964fc7-jcz6p   0/1     ErrImagePull   0          38s
# nginx-fix-7cf9964fc7-n5dqh   0/1     ErrImagePull   0          38s

kubectl describe pod nginx-fix-7cf9964fc7-9bkln
# Warning  Failed     1s (x4 over 97s)   kubelet, node01    Failed to pull image "nqinx": rpc error: code = Unknown desc = Error response from daemon: pull access denied for nqinx, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
# Warning  Failed     1s (x4 over 97s)   kubelet, node01    Error: ErrImagePull

# fix the image 
kubectl set image deployment.v1.apps/nginx-fix nqinx=nginx

kubectl get pods -l app=nginx
# NAME                        READY   STATUS    RESTARTS   AGE
# nginx-fix-f89759699-gn8q9   1/1     Running   0          27s
# nginx-fix-f89759699-lmwpc   1/1     Running   0          30s
# nginx-fix-f89759699-vbpln   1/1     Running   0          38s

```

</p></details>

### Clean up 

<br />

```bash
rm nginx-deployment.yaml web1.yaml dnsutils.yaml
kubectl delete pod dnsutils
kubectl delete deploy nginx-deployment nginx-random web1 nginx-app
```
