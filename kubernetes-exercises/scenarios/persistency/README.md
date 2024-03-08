### 3. Persistency Issues

#### Overview
Applications might face issues when trying to mount persistent volumes, which can be due to misconfigurations or underlying storage issues.

Note that this scenario only works on AWS clusters, as persistency is very cloud provider specific.

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
<summary> Hint </summary>

A service describes it's endpoints under the `Endpoints` section. Is there any there?

</details>

<summary> Hint </summary>

The service is not assosiated with any pods, because the selector does not match any labels. 
Make sure that the labels on both service and deployment/pod are the same.

</details>

### Clean up

Remove the pod by executing `kubectl delete -f .` in the folder