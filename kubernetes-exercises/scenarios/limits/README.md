### 3. Limits

#### Overview
Apps should have boundaries on what type of resources they can take up

#### Tasks
- **Creating the Problem**:
  1. run `bash setup.sh`
  1. Observe that the pod is failing to start.

- **Fixing the Problem**:

<details>
<summary> Hint </summary>

`kubectl get pods` will show you
</details>

<details>


### Clean up

Remove the pod by executing `kubectl delete -f .` in the folder