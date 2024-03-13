# [Kubesec](https://kubesec.io/)

Security risk analysis for Kubernetes resources

<br />

### Installation

<br />

```bash
wget https://github.com/controlplaneio/kubesec/releases/download/v2.11.0/kubesec_linux_amd64.tar.gz
tar -xvf  kubesec_linux_amd64.tar.gz
mv kubesec /usr/bin/
```

<br />

### Scan the following specs, identify the issues, fix and rescan

<br />

```yaml
cat << EOF > unsecured.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
    securityContext:
      privileged: true # security issue
      readOnlyRootFilesystem: false # security issue
  dnsPolicy: ClusterFirst
  restartPolicy: Never
EOF
```

<details><summary>show</summary><p>

```bash
kubesec scan unsecured.yaml

# [
#   {
#     "object": "Pod/nginx.default",
#     "valid": true,
#     "fileName": "unsecured.yaml",
#     "message": "Failed with a score of -30 points",
#     "score": -30,
#     "scoring": {
#       "critical": [
#         {
#           "id": "Privileged",
#           "selector": "containers[] .securityContext .privileged == true",
#           "reason": "Privileged containers can allow almost completely unrestricted host access",
#           "points": -30
#         }
#       ],
#       "advise": [
#         {
#           "id": "ApparmorAny",
#           "selector": ".metadata .annotations .\"container.apparmor.security.beta.kubernetes.io/nginx\"",
#           "reason": "Well defined AppArmor policies may provide greater protection from unknown threats. WARNING: NOT PRODUCTION READY",
#           "points": 3
#         },
#         {
#           "id": "ServiceAccountName",
#           "selector": ".spec .serviceAccountName",
#           "reason": "Service accounts restrict Kubernetes API access and should be configured with least privilege",
#           "points": 3
#         },
#         {
#           "id": "SeccompAny",
#           "selector": ".metadata .annotations .\"container.seccomp.security.alpha.kubernetes.io/pod\"",
#           "reason": "Seccomp profiles set minimum privilege and secure against unknown threats",
#           "points": 1
#         },
#         {
#           "id": "LimitsCPU",
#           "selector": "containers[] .resources .limits .cpu",
#           "reason": "Enforcing CPU limits prevents DOS via resource exhaustion",
#           "points": 1
#         },
#         {
#           "id": "RequestsMemory",
#           "selector": "containers[] .resources .limits .memory",
#           "reason": "Enforcing memory limits prevents DOS via resource exhaustion",
#           "points": 1
#         },
#         {
#           "id": "RequestsCPU",
#           "selector": "containers[] .resources .requests .cpu",
#           "reason": "Enforcing CPU requests aids a fair balancing of resources across the cluster",
#           "points": 1
#         },
#         {
#           "id": "RequestsMemory",
#           "selector": "containers[] .resources .requests .memory",
#           "reason": "Enforcing memory requests aids a fair balancing of resources across the cluster",
#           "points": 1
#         },
#         {
#           "id": "CapDropAny",
#           "selector": "containers[] .securityContext .capabilities .drop",
#           "reason": "Reducing kernel capabilities available to a container limits its attack surface",
#           "points": 1
#         },
#         {
#           "id": "CapDropAll",
#           "selector": "containers[] .securityContext .capabilities .drop | index(\"ALL\")",
#           "reason": "Drop all capabilities and add only those required to reduce syscall attack surface",
#           "points": 1
#         },
#         {
#           "id": "ReadOnlyRootFilesystem",
#           "selector": "containers[] .securityContext .readOnlyRootFilesystem == true",
#           "reason": "An immutable root filesystem can prevent malicious binaries being added to PATH and increase attack cost",
#           "points": 1
#         },
#         {
#           "id": "RunAsNonRoot",
#           "selector": "containers[] .securityContext .runAsNonRoot == true",
#           "reason": "Force the running image to run as a non-root user to ensure least privilege",
#           "points": 1
#         },
#         {
#           "id": "RunAsUser",
#           "selector": "containers[] .securityContext .runAsUser -gt 10000",
#           "reason": "Run as a high-UID user to avoid conflicts with the host's user table",
#           "points": 1
#         }
#       ]
#     }
#   }
# ]

```

#### Edit the specs to remove the below

```yaml
    securityContext:
      privileged: true # security issue
      readOnlyRootFilesystem: false # security issue
```

```yaml
cat << EOF > unsecured.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
EOF
```

```bash
kubesec scan unsecured.yaml

# [
#   {
#     "object": "Pod/nginx.default",
#     "valid": true,
#     "fileName": "unsecured.yaml",
#     "message": "Passed with a score of 0 points",
#     "score": 0,
#     "scoring": {
#       "advise": [
#         {
#           "id": "ApparmorAny",
#           "selector": ".metadata .annotations .\"container.apparmor.security.beta.kubernetes.io/nginx\"",
#           "reason": "Well defined AppArmor policies may provide greater protection from unknown threats. WARNING: NOT PRODUCTION READY",
#           "points": 3
#         },
#         {
#           "id": "ServiceAccountName",
#           "selector": ".spec .serviceAccountName",
#           "reason": "Service accounts restrict Kubernetes API access and should be configured with least privilege",
#           "points": 3
#         },
#         {
#           "id": "SeccompAny",
#           "selector": ".metadata .annotations .\"container.seccomp.security.alpha.kubernetes.io/pod\"",
#           "reason": "Seccomp profiles set minimum privilege and secure against unknown threats",
#           "points": 1
#         },
#         {
#           "id": "LimitsCPU",
#           "selector": "containers[] .resources .limits .cpu",
#           "reason": "Enforcing CPU limits prevents DOS via resource exhaustion",
#           "points": 1
#         },
#         {
#           "id": "RequestsMemory",
#           "selector": "containers[] .resources .limits .memory",
#           "reason": "Enforcing memory limits prevents DOS via resource exhaustion",
#           "points": 1
#         },
#         {
#           "id": "RequestsCPU",
#           "selector": "containers[] .resources .requests .cpu",
#           "reason": "Enforcing CPU requests aids a fair balancing of resources across the cluster",
#           "points": 1
#         },
#         {
#           "id": "RequestsMemory",
#           "selector": "containers[] .resources .requests .memory",
#           "reason": "Enforcing memory requests aids a fair balancing of resources across the cluster",
#           "points": 1
#         },
#         {
#           "id": "CapDropAny",
#           "selector": "containers[] .securityContext .capabilities .drop",
#           "reason": "Reducing kernel capabilities available to a container limits its attack surface",
#           "points": 1
#         },
#         {
#           "id": "CapDropAll",
#           "selector": "containers[] .securityContext .capabilities .drop | index(\"ALL\")",
#           "reason": "Drop all capabilities and add only those required to reduce syscall attack surface",
#           "points": 1
#         },
#         {
#           "id": "ReadOnlyRootFilesystem",
#           "selector": "containers[] .securityContext .readOnlyRootFilesystem == true",
#           "reason": "An immutable root filesystem can prevent malicious binaries being added to PATH and increase attack cost",
#           "points": 1
#         },
#         {
#           "id": "RunAsNonRoot",
#           "selector": "containers[] .securityContext .runAsNonRoot == true",
#           "reason": "Force the running image to run as a non-root user to ensure least privilege",
#           "points": 1
#         },
#         {
#           "id": "RunAsUser",
#           "selector": "containers[] .securityContext .runAsUser -gt 10000",
#           "reason": "Run as a high-UID user to avoid conflicts with the host's user table",
#           "points": 1
#         }
#       ]
#     }
#   }
# ]
```

</p></details>