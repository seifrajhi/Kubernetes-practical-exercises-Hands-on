# ToDo Demo APP

Please read this great post about the todo list demo app, it was tested on k3s 1.17.2, eks 1.14 and rke 1.15:

https://medium.com/better-programming/kubernetes-a-detailed-example-of-deployment-of-a-stateful-application-de3de33c8632

You should understand how the secrets, configmaps and deployment manifests was built and what they do!

<details><summary>Expand here to see the solution</summary>
<p>

```
k create -f db-credentials-secret.yaml
```

```
k create -f db-root-credentials-secret.yaml
```

```
k create -f mysql-configmap.yaml
```

```
k create -f mysql-deployment.yaml
```

```
k get all
```

```
k get pvc
```

```
k get pv
```

```
k create -f backend-deployment.yaml
```

```
k get pods
```

```
k get svc
```

#### provide the external IP of the backend deployment service in the backend-configmap.yaml

```
vi backend-configmap.yaml
```

```
k create -f backend-configmap.yaml
```

```
k create -f frontend-deployment.yaml
```

```
k get svc
```

</p>
</details>
