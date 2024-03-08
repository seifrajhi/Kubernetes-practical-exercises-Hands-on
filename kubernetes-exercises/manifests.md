# Manifests

## Learning Goals

- Write your own declarative manifest to run a simple web application in a pod.

## Introduction

### Manifest files

A [manifest][manifest_def] describes the `desired state` of an object that you want Kubernetes to manage.

Manifests are described in `yaml` files and have the following general structure:

```yaml
apiVersion:
kind:
metadata:
  labels:
spec:
```

[manifest_def]: https://kubernetes.io/docs/reference/glossary/?all=true#term-manifest

<details>
<summary>:bulb: Extra: The general structure of a declarative manifest</summary>

The general structure of a manifest is like the following. This is not only for pods, but for all Kubernetes resources.

```yaml
apiVersion: # Version of the API used for the kind/resource
kind: # The kind/resource or "type" of the object
metadata: # Metadata about the object
  name: # The name of the object (must be unique within this kind)
  labels: # Labels for the object (used for grouping, key-value pairs)
spec:# The desired state of the object
  # The spec varies depending on the kind/resource
```

</details>

## Exercise

### Overview

- Write your own `pod` manifest.
- Apply the `pod` manifest.
- Verify the `pod` is created correctly.

<details>
<summary>
Step by step:
</summary>

### Write your own `pod` manifest.

- Go into the `manifests/start` directory.
- Open the `frontend-pod.yaml` file in a text editor.

It looks like this:

```yaml
apiVersion:
kind:
metadata:
  name:
spec:
  containers:
    - name:
      image:
      ports:
```

- Find the API version for the `pod` resource in the [Kubernetes API documentation][pod-api] and fill out the `apiVersion`

[pod-api]: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/

<details>
<summary>:bulb: Help me out!</summary>

The API version for the `pod` resource is `v1`

</details>

- the `kind` should be `Pod`
- the `name` should be `frontend` for both the metadata and the spec
- the `image` should be `ghcr.io/eficode-academy/quotes-flask-frontend:release`
- the `containerPort` section should have `5000`

<details>
<summary>:bulb: Help me out!</summary>

The entire manifest should look like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
    - name: frontend
      image: ghcr.io/eficode-academy/quotes-flask-frontend:release
      ports:
        - containerPort: 5000
```

</details>

### Apply the `pod` manifest.

Try to apply the manifest with `kubectl apply -f frontend-pod.yaml` command.

### Verify the `pod` is created correctly.

Check the status of the pod with `kubectl get pods` command.

Expected output:

```bash
NAME       READY   STATUS    RESTARTS   AGE
frontend   1/1     Running   0          1m
```

Congratulations! You have now learned how to make a manifest detailing our frontend pod, and applied it to the cluster.

</details>

### Clean up

Delete the pod with `kubectl delete pod frontend` command.

Congratulations! You have now learned how to make a manifest detailing our frontend pod.
