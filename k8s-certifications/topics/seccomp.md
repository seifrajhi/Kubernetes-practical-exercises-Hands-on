# [Seccomp - Secure Computing](https://kubernetes.io/docs/tutorials/clusters/seccomp/)

 - Seccomp stands for secure computing mode and has been a feature of the Linux kernel.  
 - It can be used to sandbox the privileges of a process, restricting the calls it is able to make from userspace into the kernel. 
 - Kubernetes lets you automatically apply seccomp profiles loaded onto a node to your Pods and containers.

 **NOTE** : Seccomp is available in kubernetes 1.19 and above only.

<br />

### Check the syscalls made by `ls` using the `strace` command

<br />

```bash
strace -c ls 

# % time     seconds  usecs/call     calls    errors syscall
# ------ ----------- ----------- --------- --------- ----------------
#  18.15    0.000051           4        12           mprotect
#  16.01    0.000045           5         9           openat
#   9.96    0.000028           3        11           close
#   9.96    0.000028          14         2           getdents
#   7.47    0.000021           3         7           read
#   6.41    0.000018           2        10           fstat
#   6.05    0.000017           9         2         2 statfs
#   4.98    0.000014          14         1           munmap
#   4.27    0.000012           6         2           ioctl
#   3.56    0.000010          10         1           write
#   3.20    0.000009           3         3           brk
#   2.14    0.000006           0        17           mmap
#   2.14    0.000006           1         8         8 access
#   1.78    0.000005           3         2           rt_sigaction
#   1.07    0.000003           3         1           set_tid_address
#   0.71    0.000002           2         1           rt_sigprocmask
#   0.71    0.000002           2         1           arch_prctl
#   0.71    0.000002           2         1           set_robust_list
#   0.71    0.000002           2         1           prlimit64
#   0.00    0.000000           0         1           execve
# ------ ----------- ----------- --------- --------- ----------------
# 100.00    0.000281                    93        10 total
```

<br />

### Check if the OS supports Seccomp

<br />

 ```bash
grep -i seccomp /boot/config-$(uname -r)
# CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
# CONFIG_SECCOMP_FILTER=y
# CONFIG_SECCOMP=y
 ```

 <br />

### Check the status of Seccomp on the Kubernetes cluster 

<br />

```bash
kubectl run amicontained --image jess/amicontained -- amicontained
kk logs amicontained
# Container Runtime: docker
# Has Namespaces:
#         pid: true
#         user: false
# AppArmor Profile: docker-default (enforce)
# Capabilities:
#         BOUNDING -> chown dac_override fowner fsetid kill setgid setuid setpcap net_bind_service net_raw sys_chroot mknod audit_write setfcap
# Seccomp: disabled
# Blocked Syscalls (22):
#         MSGRCV SYSLOG SETPGID SETSID VHANGUP PIVOT_ROOT ACCT SETTIMEOFDAY UMOUNT2 SWAPON SWAPOFF REBOOT SETHOSTNAME SETDOMAINNAME INIT_MODULE DELETE_MODULE LOOKUP_DCOOKIE KEXEC_LOAD FANOTIFY_INIT OPEN_BY_HANDLE_AT FINIT_MODULE KEXEC_FILE_LOAD
# Looking for Docker.sock
 ```

 <br />

### Enable Seccomp for the `amicontained` using following specs and Seccomp `type: RuntimeDefault`.

<br />

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: amicontained
spec:
  containers:
  - args:
    - amicontained
    image: jess/amicontained
    name: amicontained
  restartPolicy: Always
```

<details><summary>show</summary><p>

#### Apply Seccomp security context

 ```yaml
cat << EOF > amicontained.yaml
apiVersion: v1
kind: Pod
metadata:
  name: amicontained
spec:
  securityContext: # add the security context with seccomp profile
    seccompProfile:
      type: RuntimeDefault
  containers:
  - args:
    - amicontained
    image: jess/amicontained
    name: amicontained
  restartPolicy: Always
EOF

kubectl apply -f amicontained.yaml
```

#### Verify

```bash

kk logs amicontained
# Container Runtime: kube
# Has Namespaces:
#         pid: true
#         user: false
# AppArmor Profile: docker-default (enforce)
# Capabilities:
#         BOUNDING -> chown dac_override fowner fsetid kill setgid setuid setpcap net_bind_service net_raw sys_chroot mknod audit_write setfcap
# Seccomp: filtering
# Blocked Syscalls (62):
#         SYSLOG SETPGID SETSID USELIB USTAT SYSFS VHANGUP PIVOT_ROOT _SYSCTL ACCT SETTIMEOFDAY MOUNT UMOUNT2 SWAPON SWAPOFF REBOOT SETHOSTNAME SETDOMAINNAME IOPL IOPERM CREATE_MODULE INIT_MODULE DELETE_MODULE GET_KERNEL_SYMS QUERY_MODULE QUOTACTL NFSSERVCTL GETPMSG PUTPMSG AFS_SYSCALL TUXCALL SECURITY LOOKUP_DCOOKIE CLOCK_SETTIME VSERVER MBIND SET_MEMPOLICY GET_MEMPOLICY KEXEC_LOAD ADD_KEY REQUEST_KEY KEYCTL MIGRATE_PAGES UNSHARE MOVE_PAGES PERF_EVENT_OPEN FANOTIFY_INIT NAME_TO_HANDLE_AT OPEN_BY_HANDLE_AT CLOCK_ADJTIME SETNS PROCESS_VM_READV PROCESS_VM_WRITEV KCMP FINIT_MODULE KEXEC_FILE_LOAD BPF USERFAULTFD MEMBARRIER PKEY_MPROTECT PKEY_ALLOC PKEY_FREE
# Looking for Docker.sock
```

</p></details>

<br />

### Create a nginx pod named `audit-pod` using audit.json seccomp profile.

<br />

```bash
# file is also available in the [data/seccomp](../data/Seccomp/audit.json) folder
curl -L -o audit.json https://k8s.io/examples/pods/security/seccomp/profiles/audit.json
```

<details><summary>show</summary><p>

#### Copy the audit.json file to the default profiles location `/var/lib/kubelet/seccomp/`

```bash
mkdir -p /var/lib/kubelet/seccomp/profiles
cp audit.json /var/lib/kubelet/seccomp/profiles
```

#### Create nginx pod using the seccomp profile

```yaml
cat << EOF > audit-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: audit-pod
  labels:
    app: audit-pod
spec:
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: profiles/audit.json
  containers:
  - name: audit-pod
    image: nginx
EOF

kubectl apply -f audit-pod.yaml

```

#### Verify 

````bash
tail -f /var/log/syslog
# Dec 16 02:07:21 vagrant kernel: [ 2253.183862] audit: type=1326 audit(1639620441.516:20): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=20123 comm="runc:[2:INIT]" exe="/" sig=0 arch=c000003e syscall=233 compat=0 ip=0x55e57ef09bc8 code=0x7ffc0000
# Dec 16 02:07:21 vagrant kernel: [ 2253.183864] audit: type=1326 audit(1639620441.516:21): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=20123 comm="runc:[2:INIT]" exe="/" sig=0 arch=c000003e syscall=138 compat=0 ip=0x55e57ef5e230 code=0x7ffc0000
````

</p></details>

<br />

### Clean up 

```bash
kubectl delete pod audit-pod amicontained --force
rm audit-pod.yaml amicontained.yaml
```