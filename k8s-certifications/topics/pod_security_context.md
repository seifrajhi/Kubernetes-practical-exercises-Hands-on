# [Pod Security Context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

A security context defines privilege and access control settings for a Pod or Container. Security context settings include, but are not limited to:
 - [`Discretionary Access Control`](#discretionary_access_control): Permission to access an object, like a file, is based on user ID (UID) and group ID (GID).
 - [`Security Enhanced Linux (SELinux)`](#selinux): Objects are assigned security labels.
 - Running as `privileged` or unprivileged.
 - [`Linux Capabilities`](#): Give a process some privileges, but not all the privileges of the root user.
 - [`AppArmor`](#apparmor): Use program profiles to restrict the capabilities of individual programs
 - [`Seccomp`](#seccomp): Filter a process's system calls.
 - [`AllowPrivilegeEscalation`]: Controls whether a process can gain more privileges than its parent process. This bool directly controls whether the no_new_privs flag gets set on the container process.
 - [`readOnlyRootFilesystem`](#immutability): Mounts the container's root filesystem as read-only.

<br >

## Discretionary Access Control

<br >

### Run as `busybox-user` pod immutable using the following settings
 - `user`: `1000`
 - `group`: `3000`

<details><summary>show</summary><p>

```yaml
cat << EOF > busybox-user.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-user
spec:
  securityContext: # add this 
    runAsUser: 1000 # add user 
    runAsGroup: 3000 # add group
  containers:
  - image: busybox
    name: busybox-user
    command: ["sh", "-c", "sleep 600"]
EOF

kubectl apply -f busybox-user.yaml
```

```bash
# verify - will have a proper user if the user exists
kk exec busybox-user -- whoami
# whoami: unknown uid 1000 
# command terminated with exit code 1
```

</p></details>

<br >

## SELinux

<br >

### Create a nginx pod with `SYS_TIME` & `NET_ADMIN` capabilities.

<details><summary>show</summary><p>

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
      capabilities:
        add: ["SYS_TIME", "NET_ADMIN"]
EOF

kubectl apply -f nginx.yaml
```

</p></details>

<br >

## App Armor

<br >

Refer [AppArmor](./apparmor.md)

<br >

## Seccomp 

Refer [Seccomp - Secure Computing](./seccomp.md)

<br >

## Immutability 

- Image Immutability: Containerized applications are meant to be immutable, and once built are not expected to change between different environments.

<br >

### Make the `busybox-immutable` pod immutable using the following settings
 - `readOnlyRootFilesystem`: `true`
 - `privileged`: `false`
 - `command` : `[ "sh", "-c", "sleep 600" ]` 

<details><summary>show</summary><p>

```yaml
cat << EOF > busybox-immutable.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-immutable
spec:
  containers:
  - image: busybox
    name: busybox-immutable
    command: ["sh", "-c", "sleep 600"]
    securityContext: # add this 
      readOnlyRootFilesystem: true # add this to make container immutable
      privileged: false # add this to prevent container making any node changes
EOF

kubectl apply -f busybox-immutable.yaml
```

```bash
# verify
kubectl exec busybox-immutable -- touch echo.txt
# touch: echo.txt: Read-only file system
# command terminated with exit code 1
```

</p></details>

## Clean up

```bash
rm busybox-immutable.yaml
kubectl delete pod busybox-immutable --force --grace-period=0
```