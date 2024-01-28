# Lab Solution

My solution is here:

- [deployment.yaml](solution/deployment.yaml)
- [service.yaml](solution/service.yaml)

Deploy it and the app will work:

```
kubectl apply -f labs/troubleshooting/solution
```

> Browse to http://localhost:8020 OR http://localhost:30020

## Troubleshooting Deployments

Fixes:

1. Edited the labels in the Pod spec to match the Deployment selector.

2. Set the replica count to 1.  0 is perfectly valid, you may want to save compute power when an app's not in use, but it's not a great default :)

3. Reduced resource requests. Large numbers are valid, but if there are no nodes in the cluster which can provide the power, the Pod stays pending.

4. Fixed the image name. `ErrImagePull` tells you the image name is incorrect or your Pod doesn't have permission to pull a private image.

5. Fix typo in the container command. `RunContainerError` tells you Kubernetes can't get the container running - you'll see the error in the Pod logs or description, depending on the failure.

6. Fix readiness probe. It's set to check a TCP socket is listening, but it's using the wrong port. `8020` is the Service port, the app in the container uses port `80`.

7. Fix liveness probe. It's set to check an HTTP endpoint, but /healthy doesn't exist - a 404 response means a failed probe.

## Troubleshooting Services

Fixes:

1. Fixed the target port for the NodePort Service, 8020 is not valid.

2. Edited the Service selector to match the labels in the Pod spec. If there are no endpoints, that means there are no matching Pods.

3. Fixed the target port name in the Service spec to match the container spec. Using names instead of port numbers is more flexible, but if the names don't match you won't see an error - just an empty endpoint list.
