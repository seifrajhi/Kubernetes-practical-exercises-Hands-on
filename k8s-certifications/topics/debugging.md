# [Kubernetes Debugging](https://kubernetes.io/docs/tasks/debug/)

<br />

### Given deployment defination `nginx-deployment` does not work. Identify and fix the problems by updating the associated resources so that the Deployment works.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    kind: frontend
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      kind: frontend
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
```

<br />

<details><summary>show</summary><p>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    kind: frontend
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx # Update the selector label to app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
```

</p></details> 

<br />

### Given deployment defination `nginx-deployment` exposed using the Service `frontend-svc`. Identify and fix the problems by updating the associated resources so that the Service works.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    kind: frontend
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      kind: frontend
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    kind: frontend
  name: frontend-svc
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    kind: frontend
status:
  loadBalancer: {}     
```

<br />

<details><summary>show</summary><p>

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    kind: frontend
  name: frontend-svc
spec:
  ports:
  - port: 8080 # Update the port to 80
    protocol: TCP
    targetPort: 8080 # Update the port to 80
  selector:
    kind: frontend # Update the selector label to app: nginx
status:
  loadBalancer: {}   
```

</p></details> 

<br />

### A Deployment named `web` is exposed via Ingress `web-ingress`. The Deployment is supposed to be reachable at http://dk8s.local/web-ingress, but requesting this URL is currently returning an error. Identify and fix the problems by updating the associated resources so that the Deployment becomes externally reachable as planned.

```bash
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment web --name web-svc --port 80
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: web
            port:
              number: 80
        path: /
        pathType: Prefix
status:
  loadBalancer: {}
```

<br />

<details><summary>show</summary><p>

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: web
  name: web-svc
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080 # Update target port to 8080 as exposed by the deployment
  selector:
    app: web
  type: ClusterIP
status:
  loadBalancer: {}
```

**NOTE**: The ingress might not work if there are ingress controllers deployed on the cluster.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: hello-world.info # add host entry
    http:
      paths:
      - backend:
          service:
            name: web # update to web-svc
            port:
              number: 80
        path: /
        pathType: Prefix
status:
  loadBalancer: {}
``` 

</p></details> 

<br />

