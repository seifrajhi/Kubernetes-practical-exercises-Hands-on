### 1. Pods Not Starting

#### Overview
Sometimes pods in Kubernetes fail to start due to various reasons such as image pull errors, resource constraints, or configuration issues. Identifying and resolving the root cause is crucial to ensure the smooth operation of your applications.

#### Tasks
- **Creating the Problem**:
  1. run `bash setup.sh`

- **Fixing the Problem**:
  1. Observe the pod status: `kubectl get pods`.
  1. Describe the pod to see the detailed error message: `kubectl describe pod <pod-name>`.
  1. Fix the problem

<details>
<summary> Hint </summary>
Try to see the avaliable tags for [Nginx](https://hub.docker.com/_/nginx). 
Correct the image in your pod definition.
</details>

  1. Apply the updated configuration: `kubectl apply -f pod-definition.yaml`.
  1. Check that the pod is now running: `kubectl get pods`.

### Clean up

Remove the pod by executing `kubectl delete -f .` in the folder