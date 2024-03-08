# Rolling Updates

## Learning Goals

- Learn about how to update deployments
- Learn about how to test resiliency of your deployment
- Learn about how to control the rollout process with `maxSurge` and `maxUnavailable`

## Introduction

In this exercise you'll learn about how to update a deployment.

### maxSurge and maxUnavailable parameters

The `maxSurge` and `maxUnavailable` parameters control how many pods can be created above the desired number of pods and how many pods can be unavailable during the update.

- `maxSurge` is the maximum number of pods that can be created above the desired number of pods. It can be a number or a percentage. The default value is 25%.

- `maxUnavailable` is the maximum number of pods that can be unavailable during the update. It can be a number or a percentage. The default value is 25%.

### Rolling update

A rolling update is a deployment strategy that allows you to update your application without downtime. It works by creating a new version of the application and then slowly replacing the old version with the new one.

## Exercise

### Overview

- Roll out new version of either the frontend or backend and see the changes
- Roll out a new version that does not exist
- Change the `maxSurge` and `maxUnavailable` parameters and see how it affects the rollout

### Step by step instructions

<details>
<summary>
Step by step:
</summary>

- Create backend deployment

> :bulb: All files for the exercise are found in the `rolling-updates/start` folder.

- Look at the backend deployment files `backend-deployment.yaml` and `frontend-deployment.yaml`
- Look at the service files in `backend-svc.yaml` and `frontend-svc.yaml`

Now go ahead and `apply` the deployments and the services:

- `kubectl apply -f .`. This will apply all the files in the current directory

* Access the frontend by the NodePort service

<details>
<summary>:bulb: How is it that you do that?</summary>

- Find the service with `kubectl get services` command.

- Note down the port number for the frontend service. In this case it is `31941`

- Get the nodes EXTERNAL-IP address. Run `kubectl get nodes -o wide`.

Copy the external IP address of any one of the nodes, for example, `34.244.123.152` and paste it in your browser.

Copy the port from your frontend service that looks something like `31941` and paste it next to your IP in the browser, for example, `34.244.123.152:31941` and hit it.

</details>

## Update Deployment

Now we will try to roll out an update to the backend image.

- Change the image tag from `release` to `2.0.0`:

```yaml
    ...
    spec:
      containers:
      - image: ghcr.io/eficode-academy/quotes-flask-backend:2.0.0
```

- Apply the new version of your deployment.

- Check the rollout status: `kubectl rollout status deployment backend`

Expected output:

```
Waiting for deployment "backend" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "backend" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "backend" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "backend" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "backend" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "backend" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "backend" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "backend" rollout to finish: 1 old replicas are pending termination...
deployment "backend" successfully rolled out
```

It might be that you only see the last line, as the rollout is very fast.

- Check the version of the backend image in the browser

- Try rolling out other image version while looking at the frontend. You can do it by repeating the commands from above. Suggested image versions are `1.0.0` and `3.0.0`.

- Try also rolling out a version that does not exist:

```yaml
spec:
  containers:
    - image: ghcr.io/eficode-academy/quotes-flask-backend:not-a-version
      name: backend
```

What happened - do the frontend still work? And are you able to see the backend version in the browser?

- Investigate the running pods with: `kubectl get pods`

What happens to the pods that are running the old version?

- Reset back to a version that exists.

## maxSurge and maxUnavailable

We will now try to control the rollout process a bit more by setting `maxSurge` and `maxUnavailable` parameters.

- open up two terminals and run `kubectl get pods --watch` in one of them

- Add the `maxSurge` and `maxUnavailable` parameters in the deployment file `backend-deployment.yaml`:

```yaml
spec:
  replicas: 3
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

- Change the image tag to `3.0.0` and apply the changes

- Check the rollout process in the first terminal

- Change the `maxSurge` and `maxUnavailable` parameters and see how it affects the rollout. Try to set `maxSurge` and `maxUnavailable` both to 100%. What happens?

</details>

## Clean up

Delete deployments and services as follow:

- `kubectl delete -f .`

Congratulations! You have now learned how to update a deployment and how to control the rollout process with `maxSurge` and `maxUnavailable` parameters.
