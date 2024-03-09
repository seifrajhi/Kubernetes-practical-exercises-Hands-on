# [AppArmor](https://kubernetes.io/docs/tutorials/clusters/apparmor/)

<br />

### Check if AppArmor is available on the cluster

<br />

```bash
systemctl status apparmor
# ● apparmor.service - AppArmor initialization
#    Loaded: loaded (/lib/systemd/system/apparmor.service; enabled; vendor preset: enabled)
#    Active: active (exited) since Thu 2021-12-16 02:19:57 UTC; 40s ago
#      Docs: man:apparmor(7)
#            http://wiki.apparmor.net/
#  Main PID: 312 (code=exited, status=0/SUCCESS)
#     Tasks: 0 (limit: 2336)
#    CGroup: /system.slice/apparmor.service

# Dec 16 02:19:57 controlplane systemd[1]: Starting AppArmor initialization...
# Dec 16 02:19:57 controlplane apparmor[312]:  * Starting AppArmor profiles
# Dec 16 02:19:57 controlplane apparmor[312]: Skipping profile in /etc/apparmor.d/disable: usr.sbin.rsyslogd
# Dec 16 02:19:57 controlplane apparmor[312]:    ...done.
# Dec 16 02:19:57 controlplane systemd[1]: Started AppArmor initialization.
```

<br />

### Check if the AppArmor module is loaded and the profiles loaded by AppArmor in different modes.

<br />

```bash
aa-status
# apparmor module is loaded.
# 12 profiles are loaded.
# 12 profiles are in enforce mode.
#    /sbin/dhclient
#    /usr/bin/man
#    /usr/lib/NetworkManager/nm-dhcp-client.action
#    /usr/lib/NetworkManager/nm-dhcp-helper
#    /usr/lib/connman/scripts/dhclient-script
#    /usr/lib/snapd/snap-confine
#    /usr/lib/snapd/snap-confine//mount-namespace-capture-helper
#    /usr/sbin/ntpd
#    /usr/sbin/tcpdump
#    docker-default
#    man_filter
#    man_groff
# 0 profiles are in complain mode.
# 9 processes have profiles defined.
# 9 processes are in enforce mode.
#    /sbin/dhclient (639) 
#    docker-default (2008) 
#    docker-default (2026) 
#    docker-default (2044) 
#    docker-default (2058) 
#    docker-default (2260) 
#    docker-default (2277) 
#    docker-default (2321) 
#    docker-default (2334) 
# 0 processes are in complain mode.
# 0 processes are unconfined but have a profile defined.
```

<br />

### Use the following `k8s-apparmor-example-deny-write` AppArmor profile with the `hello-apparmor` pod. 

<br />

```cpp
cat << EOF > k8s-apparmor-example-deny-write
#include <tunables/global>
profile k8s-apparmor-example-deny-write flags=(attach_disconnected) {
  #include <abstractions/base>
  file,
  # Deny all file writes.
  deny /** w,
}
EOF
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-apparmor
spec:
  containers:
  - name: hello
    image: busybox
    command: [ "sh", "-c", "echo 'Hello AppArmor!' && sleep 1h" ]
```

<details><summary>show</summary><p>

#### Load the AppArmor profile

**NOTE** : Profile needs to be loaded on all the nodes.

```bash
apparmor_parser -q k8s-apparmor-example-deny-write # load the apparmor profile

aa-status | grep k8s-apparmor-example-deny-write # verify its loaded
#    k8s-apparmor-example-deny-write
```

#### Enable AppArmor for the pod

```yaml
cat << EOF > hello-apparmor.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-apparmor
  annotations: # add apparmor annotations
    container.apparmor.security.beta.kubernetes.io/hello: localhost/k8s-apparmor-example-deny-write # add this
spec:
  containers:
  - name: hello
    image: busybox
    command: [ "sh", "-c", "echo 'Hello AppArmor!' && sleep 1h" ]
EOF

kubectl apply -f hello-apparmor.yaml
```

#### Verify

```bash
kubectl exec hello-apparmor -- cat /proc/1/attr/current
# k8s-apparmor-example-deny-write (enforce)
```

</p></details>