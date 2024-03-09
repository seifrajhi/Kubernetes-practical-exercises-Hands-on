# [Kubernetes API deprecations policy](https://kubernetes.io/docs/reference/using-api/deprecation-policy/)

<br />

### Given deployment defination `nginx-deployment` for an older version of kubernetes. Fix any API depcreation issues in the manifest so that the application can be deployed on a recent version cluster k8s.

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 1
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

<br />

<details><summary>show</summary><p>

```yaml
apiVersion: apps/v1 # Update from apps/v1beta1 to apps/v1 and apply
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx-deployment
spec:
  replicas: 1
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


