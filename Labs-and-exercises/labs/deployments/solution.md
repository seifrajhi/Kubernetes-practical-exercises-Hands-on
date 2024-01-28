# Lab Solution

For blue-green updates you need two Deployment objects - each managing Pods for a different version of your app.

- [solution/whoami-deployments.yaml](./solution/whoami-deployments.yaml) has two Deployments defined in the same YAML, so you can easily compare them. 

Kubectl supports this too, using `---` to separate objects.

```
kubectl apply -f labs/deployments/solution/whoami-deployments.yaml

kubectl get pods -l app=whoami-lab,version=v1

kubectl get pods -l app=whoami-lab,version=v2
```

> Four Pods are running, but there are no Services targeting their labels

## Deploy the v1 Service

The blue-green switch is done by changing the label selector for the Service.

- [solution/whoami-service-v1.yaml](./solution/whoami-service-v1.yaml) has a LoadBalancer and NodePort Service defined - each uses the same selector to pick the v1 Pods.

Deploy and test v1:

```
kubectl apply -f labs/deployments/solution/whoami-service-v1.yaml

kubectl get endpoints whoami-lab-np whoami-lab-lb

curl localhost:8020 # OR curl localhost:30020
```

## Switch to v2

- [whoami-service-v2.yaml](./solution/whoami-service-v2.yaml) has the same Service definitions with just a change to the selector.

Kubernetes deploys this as an update to the existing Services, so the IP addresses don't change, only the endpoints the Services find:

```
kubectl apply -f labs/deployments/solution/whoami-service-v2.yaml

kubectl get endpoints whoami-lab-np whoami-lab-lb

curl localhost:8020 # OR curl localhost:30020
```

> You can flip between the deployments by changing the Service spec

> Back to the [exercises](README.md).