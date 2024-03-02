apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: apple-deploy
  name: apple-deploy
spec:
  replicas: 4
  selector:
    matchLabels:
      app: apple-deploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: apple-deploy
    spec:
      containers:
      - image: nginx:1.7.9
        name: apple-bin
        resources:
          limits:
            memory: "30Mi"
          requests:
            memory: "15Mi"
