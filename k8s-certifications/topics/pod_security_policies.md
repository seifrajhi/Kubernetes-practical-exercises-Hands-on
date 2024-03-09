# [Pod Security Policies - DEPRECATED](https://kubernetes.io/docs/concepts/policy/pod-security-policy/)

 - Pod Security Policies enable fine-grained authorization of pod creation and updates.  
 - PodSecurityPolicy is deprecated as of Kubernetes v1.21, and will be removed in v1.25.

<br />

### Create the following
 - Pod Security Policy `psp-example` to prevent pods with `privileged` as true and 
 - Enable PodSecurityPolicy in Kubernetes API server
 - Try creating the nginx pod with following specs.

```yaml
cat << EOF > nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    securityContext:
      privileged: true
  restartPolicy: Always
EOF
```

<details><summary>show</summary><p>

#### Create Pod Security Policy

```yaml
cat << EOF > psp.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-example
spec:
  privileged: false
  seLinux:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
EOF

kubectl apply -f psp.yaml
```

#### Pods need to have access to use Pod Security Policies and the Service Account i.e. default needs to have access to the same.

```yaml
cat << EOF > role-psp.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: role-psp
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs:     ['use']
EOF

kubectl apply -f role-psp.yaml

cat << EOF > role-psp-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-psp-binding
roleRef:
  kind: ClusterRole
  name: role-psp
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
EOF

kubectl apply -f role-psp-binding.yaml
```

#### Update `/etc/kubernetes/manifests/kube-apiserver.yaml` to enable `PodSecurityPolicy`

```yaml
--enable-admission-plugins=NodeRestriction,PodSecurityPolicy # update the admission plugins
```

#### Verify
```bash
kubectl apply -f nginx.yaml
# Error from server (Forbidden): error when creating "nginx.yaml": pods "nginx" is forbidden: PodSecurityPolicy: unable to admit pod: [spec.volumes[0]: Invalid value: "secret": secret volumes are not allowed to be used spec.containers[0].securityContext.privileged: Invalid value: true: Privileged containers are not allowed]
``` 

</p></details>

<br />

### Update the `psp-example` Pod Security Policy to allow only `configMap` and `secret` volumes. Try creating the nginx pod with following specs.

```yaml
cat << EOF > nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
EOF
```

<details><summary>show</summary><p>

```yaml
cat << EOF > psp.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-example
spec:
  privileged: false
  seLinux:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes: # add the volumes
    - 'configMap'
    - 'secret'
EOF

kubectl apply -f psp.yaml
```

#### Verify

```bash
kubectl apply -f nginx.yaml
# Error from server (Forbidden): error when creating "nginx.yaml": pods "nginx" is forbidden: PodSecurityPolicy: unable to admit pod: [spec.volumes[0]: Invalid value: "emptyDir": emptyDir volumes are not allowed to be used]

# NOTE : If the pod is created check for other psp which allows the creation and delete the same.
``` 

</p></details>

<br />

### Update the following Pod Security Policy `psp-example` to allow only `/data` as host paths in `readOnly` mode. Try creating the nginx pod with following specs.

```yaml
cat << EOF > nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      path: /data
      type: Directory
EOF
```

<details><summary>show</summary><p>

```yaml
cat << EOF > psp.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-example
spec:
  privileged: false
  seLinux:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
    - 'configMap'
    - 'secret'
    - 'hostPath'
  allowedHostPaths: # add the allowed host paths
    - pathPrefix: "/data"
      readOnly: true
EOF

kubectl apply -f psp.yaml
```

#### Verify

```bash
kubectl apply -f nginx.yaml
# Error from server (Forbidden): error when creating "nginx.yaml": pods "nginx" is forbidden: PodSecurityPolicy: unable to admit pod: [spec.containers[0].volumeMounts[0].readOnly: Invalid value: false: must be read-only]
``` 

```yaml
cat << EOF > nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
      readOnly: true # add this
  volumes:
  - name: test-volume
    hostPath:
      path: /data
      type: Directory
EOF
```

#### Verify

```bash
kubectl apply -f nginx.yaml
# pod/nginx created
``` 

</p></details>