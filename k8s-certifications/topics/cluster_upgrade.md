# [Cluster Upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

~~**NOTE** - This was performed on the [katacoda playground](https://www.katacoda.com/courses/kubernetes/playground) with two node cluster at v1.18.0 version. It was upgrade to 1.19.3 version. Version 1.19.4 was not used as it had issues upgrading on the worker node.~~

<br />

### Upgrade Control Panel nodes

<br />

#### Check current version

```bash
kubectl get nodes

# NAME           STATUS   ROLES    AGE     VERSION
# controlplane   Ready    master   4m53s   v1.18.0
# node01         Ready    <none>   4m25s   v1.18.0
```

#### Determine which version to upgrade to - Choosing 1.19.3

```bash
apt update
apt-cache madison kubeadm
# kubeadm |  1.19.3-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
```

#### Upgrading control plane nodes

```bash
# upgrade kubeadm
apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.19.3-00

# Setting up kubernetes-cni (0.8.7-00) ...
# Setting up kubeadm (1.19.3-00) ...
```

```bash
# Verify that the download works and has the expected version:
kubeadm version

# kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:47:53Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
```

```bash
sudo kubeadm upgrade plan

# [upgrade/config] Making sure the configuration is correct:
# [upgrade/config] Reading configuration from the cluster...
# [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
# [preflight] Running pre-flight checks.
# [upgrade] Running cluster health checks
# [upgrade] Fetching available versions to upgrade to
# [upgrade/versions] Cluster version: v1.18.0
# [upgrade/versions] kubeadm version: v1.19.3
# I1217 07:14:14.966727    9206 version.go:252] remote version is much newer: v1.23.1; falling back to: stable-1.19
# [upgrade/versions] Latest stable version: v1.19.16
# [upgrade/versions] Latest stable version: v1.19.16
# [upgrade/versions] Latest version in the v1.18 series: v1.18.20
# [upgrade/versions] Latest version in the v1.18 series: v1.18.20

# Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
# COMPONENT   CURRENT       AVAILABLE
# kubelet     2 x v1.18.0   v1.18.20

# Upgrade to the latest version in the v1.18 series:

# COMPONENT                 CURRENT   AVAILABLE
# kube-apiserver            v1.18.0   v1.18.20
# kube-controller-manager   v1.18.0   v1.18.20
# kube-scheduler            v1.18.0   v1.18.20
# kube-proxy                v1.18.0   v1.18.20
# CoreDNS                   1.6.7     1.7.0
# etcd                      3.4.3-0   3.4.3-0

# You can now apply the upgrade by executing the following command:

#         kubeadm upgrade apply v1.18.20

# _____________________________________________________________________

# Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
# COMPONENT   CURRENT       AVAILABLE
# kubelet     2 x v1.18.0   v1.19.16

# Upgrade to the latest stable version:

# COMPONENT                 CURRENT   AVAILABLE
# kube-apiserver            v1.18.0   v1.19.16
# kube-controller-manager   v1.18.0   v1.19.16
# kube-scheduler            v1.18.0   v1.19.16
# kube-proxy                v1.18.0   v1.19.16
# CoreDNS                   1.6.7     1.7.0
# etcd                      3.4.3-0   3.4.13-0

# You can now apply the upgrade by executing the following command:

#         kubeadm upgrade apply v1.19.16

# Note: Before you can perform this upgrade, you have to update kubeadm to v1.19.16.

# _____________________________________________________________________


# The table below shows the current state of component configs as understood by this version of kubeadm.
# Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
# resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
# upgrade to is denoted in the "PREFERRED VERSION" column.

# API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
# kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
# kubelet.config.k8s.io     v1beta1           v1beta1             no
# _____________________________________________________________________
```

```bash
sudo kubeadm upgrade apply v1.19.3

# [upgrade/config] Making sure the configuration is correct:
# [upgrade/config] Reading configuration from the cluster...
# [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
# [preflight] Running pre-flight checks.
# [upgrade] Running cluster health checks
# [upgrade/version] You have chosen to change the cluster version to "v1.19.3"
# [upgrade/versions] Cluster version: v1.18.0
# [upgrade/versions] kubeadm version: v1.19.3
# [upgrade/confirm] Are you sure you want to proceed with the upgrade? [y/N]: y
# [upgrade/prepull] Pulling images required for setting up a Kubernetes cluster
# [upgrade/prepull] This might take a minute or two, depending on the speed of your internet connection
# [upgrade/prepull] You can also perform this action in beforehand using 'kubeadm config images pull'
# [upgrade/apply] Upgrading your Static Pod-hosted control plane to version "v1.19.3"...
# Static pod: kube-apiserver-controlplane hash: 32d269b25126efaf2f4d5b79beada591
# Static pod: kube-controller-manager-controlplane hash: f9b9c6969be80756638e9cf4927b5881
# Static pod: kube-scheduler-controlplane hash: 5795d0c442cb997ff93c49feeb9f6386
# [upgrade/etcd] Upgrading to TLS for etcd
# Static pod: etcd-controlplane hash: 7831b536f3a79e96fe34049ff61c499b
# [upgrade/staticpods] Preparing for "etcd" upgrade
# [upgrade/staticpods] Renewing etcd-server certificate
# [upgrade/staticpods] Renewing etcd-peer certificate
# [upgrade/staticpods] Renewing etcd-healthcheck-client certificate
# [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/etcd.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2021-12-17-07-15-37/etcd.yaml"
# [upgrade/staticpods] Waiting for the kubelet to restart the component
# [upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
# Static pod: etcd-controlplane hash: 7831b536f3a79e96fe34049ff61c499b
# Static pod: etcd-controlplane hash: 7831b536f3a79e96fe34049ff61c499b
# Static pod: etcd-controlplane hash: f291ed490602f9995ce3fae0c7278fde
# [apiclient] Found 1 Pods for label selector component=etcd
# [upgrade/staticpods] Component "etcd" upgraded successfully!
# [upgrade/etcd] Waiting for etcd to become available
# [upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests684409789"
# [upgrade/staticpods] Preparing for "kube-apiserver" upgrade
# [upgrade/staticpods] Renewing apiserver certificate
# [upgrade/staticpods] Renewing apiserver-kubelet-client certificate
# [upgrade/staticpods] Renewing front-proxy-client certificate
# [upgrade/staticpods] Renewing apiserver-etcd-client certificate
# [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2021-12-17-07-15-37/kube-apiserver.yaml"
# [upgrade/staticpods] Waiting for the kubelet to restart the component
# [upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
# Static pod: kube-apiserver-controlplane hash: 32d269b25126efaf2f4d5b79beada591
# Static pod: kube-apiserver-controlplane hash: 5bd0c975123753bb782dc1caf5ae2380
# [apiclient] Found 1 Pods for label selector component=kube-apiserver
# [upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
# [upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
# [upgrade/staticpods] Renewing controller-manager.conf certificate
# [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2021-12-17-07-15-37/kube-controller-manager.yaml"
# [upgrade/staticpods] Waiting for the kubelet to restart the component
# [upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
# Static pod: kube-controller-manager-controlplane hash: f9b9c6969be80756638e9cf4927b5881
# Static pod: kube-controller-manager-controlplane hash: 27ef001ee9e1781a258a9c2a188cd888
# [apiclient] Found 1 Pods for label selector component=kube-controller-manager
# [upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
# [upgrade/staticpods] Preparing for "kube-scheduler" upgrade
# [upgrade/staticpods] Renewing scheduler.conf certificate
# [upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2021-12-17-07-15-37/kube-scheduler.yaml"
# [upgrade/staticpods] Waiting for the kubelet to restart the component
# [upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
# Static pod: kube-scheduler-controlplane hash: 5795d0c442cb997ff93c49feeb9f6386
# Static pod: kube-scheduler-controlplane hash: c4e7975f4329949f35219b973dfc69c5
# [apiclient] Found 1 Pods for label selector component=kube-scheduler
# [upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
# [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
# [kubelet] Creating a ConfigMap "kubelet-config-1.19" in namespace kube-system with the configuration for the kubelets in the cluster
# [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
# [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
# [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
# [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
# [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
# [addons] Applied essential addon: CoreDNS
# [addons] Applied essential addon: kube-proxy

# [upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.19.3". Enjoy!

# [upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
```

#### Upgrade additional control plane nodes

```bash
# for any additional control panel nodes (if any) - currently none
sudo kubeadm upgrade node
```

#### Drain the control plane node

```bash
kubectl drain controlplane --ignore-daemonsets

# node/controlplane cordoned
# WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-jjlnt, kube-system/kube-proxy-np9zl
# evicting pod kube-system/coredns-f9fd979d6-j6w5s
# pod/coredns-f9fd979d6-j6w5s evicted
# node/controlplane evicted
```

#### Upgrade kubelet and kubectl

```bash
apt-get update && \
apt-get install -y --allow-change-held-packages kubelet=1.19.3-00 kubectl=1.19.3-00

# Unpacking kubelet (1.19.3-00) over (1.18.0-00) ...
# Setting up kubelet (1.19.3-00) ...
# Setting up kubectl (1.19.3-00) ...

sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

#### Uncordon the control plane node

```bash
kubectl uncordon controlplane
# node/controlplane uncordoned
```

#### Check the nodes

```bash
kubectl get nodes
NAME           STATUS   ROLES    AGE   VERSION
# controlplane   Ready    master   15m   v1.19.3
# node01         Ready    <none>   14m   v1.18.0
```

<br />

### Upgrade worker nodes

<br />

#### Upgrade kubeadm
```bash
apt update
apt-cache madison kubeadm

apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.19.3-00
# Unpacking kubeadm (1.19.3-00) over (1.18.0-00) ...
# Setting up kubernetes-cni (0.8.7-00) ...
# Setting up kubeadm (1.19.3-00) ...
```

#### Upgrade the kubelet configuration

```bash
sudo kubeadm upgrade node

# [upgrade] Reading configuration from the cluster...
# [upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
# [preflight] Running pre-flight checks
# [preflight] Skipping prepull. Not a control plane node.
# [upgrade] Skipping phase. Not a control plane node.
# [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
# [upgrade] The configuration for this node was successfully updated!
# [upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
```

#### Drain the node - Execute this on the master/control panel node

```bash
kubectl drain node01 --ignore-daemonsets

# node/node01 cordoned
# WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-26gz5, kube-system/kube-keepalived-vip-dskqw, kube-system/kube-proxy-jwpgs
# evicting pod kube-system/coredns-f9fd979d6-gjfpn
# evicting pod kube-system/coredns-f9fd979d6-xvh8h
# evicting pod kube-system/katacoda-cloud-provider-5f5fc5786f-565r6
# pod/katacoda-cloud-provider-5f5fc5786f-565r6 evicted
# pod/coredns-f9fd979d6-gjfpn evicted
# pod/coredns-f9fd979d6-xvh8h evicted
# node/node01 evicted
```

#### Upgrade kubelet and kubectl

```bash
apt-get update && \
> apt-get install -y --allow-change-held-packages kubelet=1.19.3-00 kubectl=1.19.3-00

# ....
# kubectl is already the newest version (1.19.3-00).
# kubelet is already the newest version (1.19.3-00).
# The following packages were automatically installed and are no longer required:
#   libc-ares2 libhttp-parser2.7.1 libnetplan0 libuv1 nodejs-doc python3-netifaces
# Use 'apt autoremove' to remove them.
# 0 upgraded, 0 newly installed, 0 to remove and 201 not upgraded.

sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

#### Uncordon the node - Execute this on the master/control panel node

```bash
kubectl uncordon node01
# node/node01 uncordoned
```

#### Verify nodes are upgraded

```shell
kubectl get nodes
# NAME           STATUS   ROLES    AGE   VERSION
# controlplane   Ready    master   22m   v1.19.3
# node01         Ready    <none>   22m   v1.19.3
```