

# K8S Hands-on


---

# Kustomization - `kubectl kustomize`

## Declarative Configuration in Kubernetes

- `Kustomize` is a very powerful too for customizing and building Kubernetes resources.
- `Kustomize` started at 2017. Added to `kubectl` since version 1.14.
- `Kustomize` has many useful features for managing and deploying resource.
- When you execute a Kustomization beside using the build-in features it will also re-order the resources in a logical way for the K8S to be deployed.

### Re-order the resources for

- `Kustomization` re-order the `Kind` for optimization, for example we will need an existing `namespace` before using it.

- The order of the resources is defined in the source code:
  Source: https://github.com/kubernetes-sigs/kustomize/blob/master/api/resid/gvk.go

```go
// An attempt to order things to help k8s, e.g.
// - Namespace should be first.
// - Service should come before things that refer to it.
// In some cases order just specified to provide determinism.
var orderFirst = []string{
	"Namespace",
	"ResourceQuota",
	"StorageClass",
	"CustomResourceDefinition",
	"ServiceAccount",
	"PodSecurityPolicy",
	"Role",
	"ClusterRole",
	"RoleBinding",
	"ClusterRoleBinding",
	"ConfigMap",
	"Secret",
	"Endpoints",
	"Service",
	"LimitRange",
	"PriorityClass",
	"PersistentVolume",
	"PersistentVolumeClaim",
	"Deployment",
	"StatefulSet",
	"CronJob",
	"PodDisruptionBudget",
}

var orderLast = []string{
	"MutatingWebhookConfiguration",
	"ValidatingWebhookConfiguration",
}
```

---

### Base resource for our demo
- In the following samples we will refer to the following `base.yaml` file

```yaml
# base.yaml
# This is the base file for all the demos in this folder
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: __image__
```

---
## Common Features

- [commonAnnotation](#commonannotation)
- [commonLabels](#commonlabels)
- [Generators](#Generators)
  - [ConfigMapGenerator](#configMapGenerator)
    - [FromEnv](#fromenv)
    - [FromFile](#fromfile)
    - [FromLiteral](#fromliteral)
  - [SecretGenerator](#secret-generator)
- [images](#images)
- [Namespaces](#Namespaces)
- [Prefix / Suffix](#prefix-suffix)
- [Replicas](#replicas)
- [Patches](#Patches)
  - [Patch Add/Update](#patch-addupdate)
  - [Patch Delete](#Patch-Delete)
  - [Patch Replace](#Patch-Replace)

---

## `commonAnnotation`

```sh
kubectl kustomize samples/01-commonAnnotation
```

```yaml
### FileName: kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# This will add annotation under every metadata entry
# ex: main metadata, spec.metadata etc
commonAnnotations:
  author: nirgeier@gmail.com
```

- Output:

  ```yaml
  ### commonAnnotation output
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    annotations:
      ### Annotation added here
      author: nirgeier@gmail.com
      name: myapp
  spec:
    selector:
      matchLabels:
        app: myapp
    template:
      metadata:
        ### Annotation added here
        annotations:
          author: nirgeier@gmail.com
        labels:
          app: myapp
      spec:
        containers:
          - image: __image__
            name: myapp
  ```

## `commonLabels`

```sh
kubectl kustomize samples/02-commonLabels
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# This will add annotation under every metadata entry
# ex: main metadata, spec.metadata etc
commonLabels:
  author: nirgeier@gmail.com
  env: codeWizard-cluster

bases:
  - ../_base
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
      # Labels added ....
      labels:
      author: nirgeier@gmail.com
      env: codeWizard-cluster
    name: myapp
  spec:
    selector:
      matchLabels:
        app: myapp
        # Labels added ....
        author: nirgeier@gmail.com
        env: codeWizard-cluster
    template:
      metadata:
        labels:
          app: myapp
          # Labels added ....
          author: nirgeier@gmail.com
          env: codeWizard-cluster
      spec:
        containers:
        - image: __image__
          name: myapp
  ```

## Generators
- Kustomization also support generate `ConfigMap` / `Secret` in several ways.
- The default behavior is adding the output hash value as suffix to the name, 
  ex: `secretMapFromFile-495dtcb64g`
    ```yaml
    apiVersion: v1
    data:
      APP_ENV: ZGV2ZWxvcG1lbnQ=
      LOG_DEBUG: dHJ1ZQ==
      NODE_ENV: ZGV2
      REGION: d2V1
    kind: Secret
    metadata:
      name: secretMapFromFile-495dtcb64g # <--------------------------
    type: Opaque
    ```
- We can disable the suffix with the following addition to the `kustomization.yaml`
  ```yaml
  generatorOptions:
    disableNameSuffixHash: true
  ```
### `configMapGenerator`

  - #### FromEnv
    - `.env`
      ```sh
      key1=value1
      env=qa
      ```
    - `kustomization.yaml`
      ```yaml
      # Generate config file from env file
      configMapGenerator:
        - name: configMapFromEnv
          env: .env
      ```

    - The output of `configMapFromEnv`:
      ```yaml
      apiVersion: v1
      data:
        env: qa
        key1: value1
      kind: ConfigMap
      metadata:
        name: configMapFromEnv-c9655hf97k
      ```
  - #### FromFile
    - `.env`
      ```sh
      key1=value1
      env=qa
      ```
    - `kustomization.yaml`
      ```yaml
      # Generate config file from env file
      configMapGenerator:
        - name: configMapFromEnv
          files: 
          - .env
      ```

    - The output of `configMapFromEnv`:
      ```yaml
      apiVersion: v1
      data:
        .env: "key1=value1\r\nenv=qa" # <--------------------------
      kind: ConfigMap
      metadata:
        name: configFromFile-dfhmctd84d
      ```
  - #### FromLiteral
    - `.env`
      ```sh
      key1=value1
      env=qa
      ```
    - `kustomization.yaml`
      ```yaml
      configMapGenerator:
        - name: configFromLiterals
          literals:
            - Key1=value1
            - Key2=value2
      ```

    - The output of `configMapFromEnv`:
      ```yaml
      apiVersion: v1
      data:
        Key1: value1
        Key2: value2
      kind: ConfigMap
      metadata:
        name: configFromLiterals-h777b4gdf5
      ```
---

## `Secret` Generator
```yaml
# Similar to configMap but wit additional type field
secretGenerator:
  # Generate secret from env file
  - name: secretMapFromFile
    env: .env
    type: Opaque
generatorOptions:
  disableNameSuffixHash: true
```
## `images`

- Modify the name, tags and/or digest for images.

```sh
kubectl kustomize samples/04-images
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./base.yaml

images:
  # The image as its defined in the Deployment file
  - name: __image__
    # The new name to set
    newName: my-registry/my-image
    # optional: image tag
    newTag: v1
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: myapp
  spec:
    selector:
      matchLabels:
        app: myapp
    template:
      metadata:
        labels:
          app: myapp
      spec:
        containers:
          # --- This image was updated
          - image: my-registry/my-image:v1
            name: myapp
  ```

---

## `Namespaces`

```sh
kubectl kustomize samples/05-Namespace
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Add the desired namespace to all resources
namespace: kustomize-namespace

bases:
  - ../_base
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: myapp
    # Namespace added here
    namespace: kustomize-namespace
  ```

---

### `Prefix-suffix`

```sh
kubectl kustomize samples/06-Prefix-Suffix
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Add the desired Prefix to all resources
namePrefix: prefix-codeWizard-
nameSuffix: -suffix-codeWizard

bases:
  - ../_base
```

- Output:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: prefix-codeWizard-myapp-suffix-codeWizard
  ```

---

## `Replicas`

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
spec:
  replicas: 5
  selector:
    name: deployment
  template:
    containers:
      - name: container
        image: registry/conatiner:latest
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

replicas:
  - name: deployment
    count: 10

resources:
  - deployment.yaml
```

- Output:

**Note**: There is a bug with the `replicas` entries which return error for some reason.

```sh
$ kubectl kustomize .

# For some reason we get this error:
Error: json: unknown field "replicas"

# Workaround for this error for now is:
$ kustomize build .
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment
spec:
  replicas: 10
  selector:
    name: deployment
  template:
    containers:
      - image: registry/conatiner:latest
        name: container
```

---

## Patches
- There are several types of patches like [`replace`, `delete`, `patchesStrategicMerge`]
- For this demo we will demonstrate `patchesStrategicMerge`

### Patch Add/Update

```sh
kubectl kustomize samples/08-Patches/patch-add-update
```

```yaml
# File: patch-memory.yaml
# -----------------------
# Patch limits.memory
apiVersion: apps/v1
kind: Deployment
# Set the desired deployment to patch
metadata:
  name: myapp
spec:
  # patch the memory limit
  template:
    spec:
      containers:
        - name: patch-name
          resources:
            limits:
              memory: 512Mi
```

```yaml
# File: patch-replicas.yaml
# -------------------------
apiVersion: apps/v1
kind: Deployment
# Set the desired deployment to patch
metadata:
  name: myapp
spec:
  # This is the patch for this demo
  replicas: 3
```  

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../_base
  
patchesStrategicMerge:
- patch-memory.yaml
- patch-replicas.yaml
```

- Output:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  # This is the first patch
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      # This is the second patch
      containers:
      - name: patch-name
        resources:
          limits:
            memory: 512Mi
      - image: __image__
        name: myapp
```

### Patch-Delete
```sh
kubectl kustomize samples/08-Patches/patch-delete
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../_base
  
patchesStrategicMerge:
- patch-delete.yaml
```

```yaml
# patch-delete.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        # Remove this section, in this demo it will remove the 
        # image with the `name: myapp` 
        - $patch: delete
          name: myapp
          image: __image__
```

- Output:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - image: nginx
        name: nginx
```

### Patch Replace
```sh
kubectl kustomize samples/08-Patches/patch-replace/
```

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../_base
  
patchesStrategicMerge:
- patch-replace.yaml
```

```yaml
# patch-replace.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
        # Remove this section, in this demo it will remove the 
        # image with the `name: myapp` 
        - $patch: replace
        - name: myapp
          image: nginx:latest
          args:
          - one
          - two
```

- Output:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - args:
        - one
        - two
        image: nginx:latest
        name: myapp
```
<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../07-nginx-Ingress">07-nginx-Ingress</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../09-StatefulSet">09-StatefulSet</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->