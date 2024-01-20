# Configuration

Kubernetes has an integrated pattern for decoupling configuration from application or container.

This pattern makes use of two Kubernetes components: ConfigMaps and Secrets.

Both types of objects hold key-value pairs that can be injected into Pods through a variety of means.

# Index

* [ConfigMaps](#configmaps)
  * [Exercise: Creating ConfigMaps](#exercise-creating-configmaps)
  * [Exercise: Using ConfigMaps with Environment Variables](#exercise-using-configmaps-with-environment-variables)
  * [Exercise: Using ConfigMaps with Volumes](#exercise-using-configmaps-with-volumes)
* [Secrets](#secrets)
  * [Exercise: Creating Secrets](#exercise-creating-secrets)
  * [Exercise: Using Secrets with Environment Variables](#exercise-using-secrets-with-environment-variables)
  * [Exercise: Using Secrets with Volumes](#exercise-using-secrets-with-volumes)
* [Cleaning Up](#cleaning-up)
* [Helpful Resources](#helpful-resources)


----

# ConfigMaps

A ConfigMap is externalized data stored within Kubernetes that can be referenced through several different means:
* Environment variable
* A command line argument (via env var)
* Injected as a file into a volume mount

ConfigMaps can be created from a manifest, literals, a directory, or from the files the directly.

---

### Exercise: Creating ConfigMaps
**Objective:** Go over the four methods of creating ConfigMaps.

---

#### **From Manifest**
Create ConfigMap `manifest-example` from the manifest `manifests/cm-manifest.yaml` or use the yaml below.

**manifests/cm-manifest.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: manifest-example
data:
  city: Ann Arbor
  state: Michigan
```

**Command**
```
kubectl create -f manifests/cm-manifest.yaml
```

View the created ConfigMap.
```
kubectl get configmap manifest-example -o yaml
```

#### **From Literal**

Create ConfigMap `literal-example` using the `--from-literal` flag and `city=Ann Arbor` along with `state=Michigan` for the values.
```
kubectl create cm literal-example --from-literal="city=Ann Arbor" --from-literal=state=Michigan
```

View the created ConfigMap.
```
kubectl get cm literal-example -o yaml
```

#### **From Directory**

Create ConfigMap `dir-example` by using the `manifests/cm` directory as the source.
```
kubectl create cm dir-example --from-file=manifests/cm/
```

View the created ConfigMap.
```
kubectl get cm dir-example -o yaml
```

#### **From File**

Create ConfigMap `file-example` by using the `city` and `state` files in the `manifests/cm` directory.
```
kubectl create cm file-example --from-file=manifests/cm/city --from-file=manifests/cm/state
```

View the created ConfigMap.
```
kubectl get cm file-example -o yaml
```

**Note:** When creating a ConfigMap from a file or directory the content will assume to be multiline as signified by the pipe symbol (`|`) in the yaml.

---

**Summary:** 

There are four primary methods of creating ConfigMaps with `kubectl`. 

From a manifest, passing literals on the command-line, supplying a path to a directory, or to the individual files themselves. 

These ConfigMaps are stored within etcd, and may be used in a multitude of ways.

---

### **Exercise: Using ConfigMaps with Environment Variables**

**Objective:**  Dive into how ConfigMap items may be referenced as Environment Variables and how this method may be extended to use them as command-line arguments.

**Note:** This exercise builds off the previous exercise: [Creating ConfigMaps](#exercise-creating-configmaps). If you have not, complete it first before continuing.

---

1) Create Job `cm-env-example` using the manifest `manifests/cm-env-example.yaml` or the yaml below.

**manifests/cm-env-example.yaml**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: cm-env-example
spec:
  template:
    spec:
      containers:
      - name: env
        image: alpine:latest
        command: ["/bin/sh", "-c"]
        args: ["printenv CITY"]
        env:
        - name: CITY
          valueFrom:
            configMapKeyRef:
              name: manifest-example
              key: city
      restartPolicy: Never
```

**Command:**
```
kubectl create -f manifests/cm-env-example.yaml
```

Note how the Environment Variable is injected using `valueFrom` and `configMapKeyRef`. This queries a specific key
from the ConfigMap and injects it as an Environment Variable.

2) List the Pods.
```
kubectl get pods
```

3) Copy the pod name and view the output of the Job.
```
kubectl logs cm-env-example-<pod-id>
```

It should echo the value from the `manifest-example` ConfigMap `city` key-value pair.

This same technique can be used to inject the value for use in a Command.

4) Create another Job `cm-cmd-example` from the manifest `manifests/cm-cmd-example.yaml` or use the yaml below.

**manifests/cm-cmd-example.yaml**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: cm-cmd-example
spec:
  template:
    spec:
      containers:
      - name: env
        image: alpine:latest
        command: ["/bin/sh", "-c"]
        args: ["echo Hello from ${CITY}!"]
        env:
        - name: CITY
          valueFrom:
            configMapKeyRef:
              name: manifest-example
              key: city
      restartPolicy: Never
```

**Command:**
```
kubectl create -f manifests/cm-cmd-example.yaml
```

5) List the Pods.
```
kubectl get pods
```

3) Copy the pod name of the `cm-cmd-example` job and view the output of the Pod.
```
kubectl logs cm-cmd-example-<pod-id>
```
It should echo the string "Hello from <data[city]>" referencing the value from the `manifest-example` ConfigMap.

---

**Summary:** 

Items within a ConfigMap can be injected into a Pod's Environment Variables at container creation. 

These items may be picked up by the application being run in the container directly, or referenced as a command-line argument.

Both methods are commonly used and enable a wide-variety of use-cases.

---

**Clean Up Command:**
```
kubectl delete job cm-env-example cm-cmd-example
```

---

### **Exercise: Using ConfigMaps with Volumes**
**Objective:** Learn how to mount a ConfigMap or specific items stored within a ConfigMap as a volume.

**Note:** This exercise builds off the previous exercise: [Creating ConfigMaps](#exercise-creating-configmaps). If you
have not, complete it first before continuing.

---

1) Create the Pod `cm-vol-example` using the manifest `manifests/cm-vol-example.yaml` or use the yaml below.

**manifests/cm-vol-example.yaml**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cm-vol-example
spec:
  containers:
  - name: mypod
    image: alpine:latest
    command: ["/bin/sh", "-c"]
    args:
    - while true; do
      sleep 10;
      done
    volumeMounts:
    - name: config-volume
      mountPath: /myconfig
    - name: city
      mountPath: /mycity
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: manifest-example
  - name: city
    configMap:
      name: manifest-example
      items:
      - key: city
        path: thisismycity
```

**Command:**
```
kubectl create -f manifests/cm-vol-example.yaml
```

Note the volumes and how they are being referenced. 

The volume `city`, has an array of `items` that contains a sub-set of the key-value pairs stored in the `manifest-example` ConfigMap. 

When working with the individual items, it is possible to override the name or path to the generated file by supplying an argument for the `path` parameter.

2) View the contents of the `/myconfig` volume mount.
```
kubectl exec cm-vol-example -- ls /myconfig
```
It will contain two files, matching the names of the keys stored in configMap `manifest-example`.

3) `cat` the contents of the files.
```
kubectl exec cm-vol-example -- /bin/sh -c "cat /myconfig/*"
```
It will match the values stored in the configMap `manifest-example` concatenated together.

4) View the contents of the other Volume Mount `mycity`.
```
kubectl exec cm-vol-example -- ls /mycity
```
A file will be present that represents the single item being referenced in the `city` volume. This file bears the
name `thisismycity` as specified by the `path` variable.

5) `cat` contents of the `thisismycity` file.
```
kubectl exec cm-vol-example -- cat /mycity/thisismycity
```
The contents should match the value of data[city].

---

**Summary:** 

In addition to being injected as Environment Variables it's possible to mount the contents of a ConfigMap as a volume. 

This same method may be augmented to mount specific items from a ConfigMap instead of the entire thing.

These items can be renamed or be made read-only to meet a variety of application needs providing an easy to use avenue to further decouple application from configuration.

---

**Clean Up Command:**
```
kubectl delete pod cm-vol-example
```

```
kubectl delete cm dir-example file-example literal-example manifest-example
```

---

[Back to Index](#index)

---
---

# Secrets

A Secret is externalized "private" base64 encoded data stored within Kubernetes that can be referenced through several different means:
* Environment variable
* A command line argument (via env var)
* Injected as a file into a volume mount

Like ConfigMaps, Secrets can be created from a manifest, literals, or from files directly.

**Note:** For all intents and purposes, Secrets are created and used just like ConfigMaps. If you have completed
the ConfigMap Exercises, the Secrets section may be skimmed over glossing a few of the minor syntax differences.

---

### **Exercise: Creating Secrets**
**Objective:** Learn to use the four different methods of creating Secrets, and how they different slightly from their ConfigMap counterparts.

---

#### **From Manifest**
Create Secret `manifest-example` from the manifest `manifests/secret-manifest.yaml` or use the yaml below.

**manifests/secret-manifest.yaml**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: manifest-example
type: Opaque
data:
  username: ZXhhbXBsZQ==
  password: bXlwYXNzd29yZA==
```

**Command:**
```
kubectl create -f manifests/secret-manifest.yaml
```

Note the Secret has the additional attribute `type` when compared to a ConfigMap. The `Opaque` value simply means the data is unstructured. Additionally, the content referenced in `data` itself is base64 encoded. Decoded, they are `username=example` and `password=mypassword`.

View the created Secret.
```
kubectl get secret manifest-example -o yaml
```

#### **From Literal**

Create Secret `literal-example` using the `--from-literal` flag and `username=example` along with `password=mypassword` for the values.
```
kubectl create secret generic literal-example --from-literal=username=example --from-literal=password=mypassword
```

**Note:** Unlike ConfigMaps you **must** also specify the type of Secret you are creating. There are 3 types:
* docker-registry - Credentials used to interact with a container registry.
* generic - Eeuivalent to `Opaque`. Used for unstructured data.
* tls - A TLS key pair (PEM Format) that accepts a cert (`--cert`) and key (`--key`).


View the created Secret.
```
kubectl get secret literal-example -o yaml
```

#### **From Directory**

Create Secret `dir-example` by using the `manifests/secret` directory as the source.
```
kubectl create secret generic dir-example --from-file=manifests/secret/
```

View the created Secret.
```
kubectl get secret dir-example -o yaml
```

#### **From File**

Create ConfigMap `file-example` by using the `username` and `password` files in the `manifests/secret` directory.
```
kubectl create secret generic  file-example --from-file=manifests/secret/username --from-file=manifests/secret/password
```

View the created Secret:
```
kubectl get secret file-example -o yaml
```

---

**Summary:** 

Just like ConfigMaps, there are four primary methods of creating Secrets with `kubectl`. From manifests and literals to directories and files; no one method is better than another. 

The fundamental difference when working with Secrets over ConfigMaps, is that they require a type such as `generic` or `opaque` and the contents itself is stored in a base64 encoded form.

---

### **Exercise: Using Secrets with Environment Variables**
**Objective:** Examine how Secrets may be referenced as Environment Variables and how this may be extended to use them in command-line arguments.

**Note:** This exercise builds off the previous exercise: [Creating Secrets](#exercise-creating-Secrets). If you have not, complete it first before continuing.

---

1) Create Job `secret-env-example` using the manifest `manifests/secret-env-example.yaml` or the yaml below.

**manifests/secret-env-example.yaml**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: cm-env-example
spec:
  template:
    spec:
      containers:
      - name: env
        image: alpine:latest
        command: ["/bin/sh", "-c"]
        args: ["printenv USERNAME"]
        env:
        - name: USERNAME
          valueFrom:
            secretKeyRef:
              name: manifest-example
              key: username
      restartPolicy: Never
```

**Command:**
```
kubectl create -f manifests/secret-env-example.yaml
```

Note how the Environment Variable is injected using `valueFrom` and `secretKeyRef`. 

This queries a specific key from the Secret and injects it as an Environment Variable.

2) List the Pods.
```
kubectl get pods
```

3) Copy the pod name and view the output of the Job.
```
kubectl logs secret-env-example-<pod-id>
```
It should echo the value from the `manifest-example` Secret `username` key-value pair.

This same technique can be used to inject the value for use in a Command.

4) Create another Job `secret-cmd-example` from the manifest `manifests/secret-cmd-example.yaml` or use the yaml below.

**manifests/secret-cmd-example.yaml**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: secret-cmd-example
spec:
  template:
    spec:
      containers:
      - name: env
        image: alpine:latest
        command: ["/bin/sh", "-c"]
        args: ["echo Hello there ${USERNAME}!"]
        env:
        - name: USERNAME
          valueFrom:
            secretKeyRef:
              name: manifest-example
              key: username
      restartPolicy: Never
```

**Command**
```
kubectl create -f manifests/secret-cmd-example.yaml
```

5) List the Pods.
```
kubectl get pods
```

3) Copy the pod name of the `secret-cmd-example` job and view the output of the Pod.
```
kubectl logs secret-cmd-example-<pod-id>
```
It should echo the string "Hello there <data[username]>!" referencing the value from the `manifest-example` Secret.

---

**Summary:** 

Secrets may be injected into a Pod's Environment Variables at container creation. 

These variables may be picked up by the application being run in the container directly, or referenced as a command-line argument.

Both methods are useful in a wide-variety of scenarios enabling further decoupling of application and configuration.

---

**Clean Up Command:**
```
kubectl delete job secret-env-example secret-cmd-example
```

---

### **Exercise: Using Secrets with Volumes**
**Objective:** Learn how to mount a Secret or specific items stored within a Secret as a volume.

**Note:** This exercise builds off the previous exercise: [Creating Secrets](#exercise-creating-secrets). If you have not, complete it first before continuing.

---

1) Create the Pod `secret-vol-example` using the manifest `manifests/secret-vol-example.yaml` or use the yaml below.

**manifests/secret-vol-example.yaml**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-vol-example
spec:
  containers:
  - name: mypod
    image: alpine:latest
    command: ["/bin/sh", "-c"]
    args:
    - while true; do
      sleep 10;
      done
    volumeMounts:
    - name: secret-volume
      mountPath: /mysecret
    - name: password
      mountPath: /mypass
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: manifest-example
  - name: password
    secret:
      secretName: manifest-example
      items:
      - key: password
        path: supersecretpass
```

**Command:**
```
kubectl create -f manifests/secret-vol-example.yaml
```

Note the volumes and how they are being referenced. The volume `password`, has an array of `items` that contains a sub-set of the key-value pairs stored in the `manifest-example` Secret. 

When working with the individual items, it is possible to override the name or path to the generated file by supplying an argument for the `path` parameter.

2) View the contents of the `/mysecret` volume mount.
```
kubectl exec secret-vol-example -- ls /mysecret
```
It will contain two files, matching the names of the keys stored in Secret `manifest-example`.

3) `cat` the contents of the files.
```
kubectl exec secret-vol-example -- /bin/sh -c "cat /mysecret/*"
```
It will match the values stored in the Secret `manifest-example` concatenated together.

4) View the contents of the other Volume Mount `mypass`.
```
kubectl exec secret-vol-example -- ls /mypass
```
A file will be present that represents the single item being referenced in the `password` volume. This file bears the
name `supersecretpass` as specified by the `path` variable.

5) `cat` contents of the `supersecretpass` file.
```
kubectl exec secret-vol-example -- cat /mypass/supersecretpass
```
The contents should match the value of data[password].

---

**Summary:** Secrets can be consumed in multiple ways. One of the more flexible (and secure) methods being mounting as a volume.

It's possible to mount the entire contents of a Secret as a volume, or alternatively mount specific
items stored in a Secret. 

These items can be renamed or be made read-only to meet a variety of application needs.

---

**Clean Up Command:**
```
kubectl delete pod secret-vol-example
```

```
kubectl delete secret dir-example file-example literal-example manifest-example
```

---

[Back to Index](#index)

---
---

# **Cleaning Up**

```
kubectl delete cm manifest-example literal-example dir-example file-example
```

```
kubectl delete secret manifest-example literal-example dir-example file-example
```

---

[Back to Index](#index)

---
---

# Helpful Resources

* [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
* [Secrets Overview](https://kubernetes.io/docs/concepts/configuration/secret/)
* [Storing and Using Docker Registry Credentials as a Secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
* [ConfigMaps and Secrets](https://github.com/AbstractInfrastructure/k8s-intro-tutorials/tree/master/configuration)


---

[Back to Index](#index)
