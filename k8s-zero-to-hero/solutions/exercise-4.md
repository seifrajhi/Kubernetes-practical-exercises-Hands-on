## Exercise 4

Create a sameple deployment yaml
```
kubectl create deployment watermelon -n coconut --image=nginx --replicas=5 --dry-run=client -o yaml > watermelon-deployment.yaml
```

Now we get the pod yaml to include this in our deployment
```
kubectl get pod watermelon -n coconut -o yaml
```

Copy the content and paste it in our deployment as follow:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: watermelon
  name: watermelon
  namespace: coconut
spec:
  replicas: 5
  selector:
    matchLabels:
      app: watermelon
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: watermelon
    spec:
      containers:
      - image: nginx
        name: watermelon

```
Apply the deployment file and check that it's working properly:

```
kubectl create -f watermelon-deployment.yaml
```
