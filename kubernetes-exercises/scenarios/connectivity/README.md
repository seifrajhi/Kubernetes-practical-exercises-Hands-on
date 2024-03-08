### Service Connectivity Issues


#### Overview
Services in Kubernetes provide a way for pods to communicate with each other. Misconfigurations or network policies can lead to connectivity issues.

In this scenario, we have an `nginx` deployment that has a service assosiated with it. The goal is to get connectivity between the `probe` pod and the `nginx` pod through the service.

#### Tasks
- **Creating the Problem**:
  1. run `bash setup.sh`
  1. Execute into the `probe` pod and see that you can connect to the nginx deployment through the service with a curl call: `curl nginx-service:80`

- **Fixing the Problem**:

<details>
<summary> Hint </summary>
It is clear that the connection is not working.
Try to describe the service and see if you can find the problem.
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