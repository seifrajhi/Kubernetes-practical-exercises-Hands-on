# [Kube-bench](https://github.com/aquasecurity/kube-bench)

Aqua Security Kube-bench is a tool that checks whether Kubernetes is deployed securely by running the checks documented in the [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes/).

<br />

### Installation

```bash
curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.6.5/kube-bench_0.6.5_linux_amd64.tar.gz -o kube-bench_0.6.5_linux_amd64.tar.gz
tar -xvf kube-bench_0.6.5_linux_amd64.tar.gz
```

<br />

### Execute Kubebench on the cluster

<br />

```bash
./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml 
# .....
# == Summary total ==
# 71 checks PASS
# 11 checks FAIL
# 40 checks WARN
# 0 checks INFO
```

<br />

### Check the failed tests on the cluster 

<br />

```bash
./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml | grep "\[FAIL\] "
# [FAIL] 1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)
# [FAIL] 1.2.6 Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)
# [FAIL] 1.2.16 Ensure that the admission control plugin PodSecurityPolicy is set (Automated)
# [FAIL] 1.2.21 Ensure that the --profiling argument is set to false (Automated)
# [FAIL] 1.2.22 Ensure that the --audit-log-path argument is set (Automated)
# [FAIL] 1.2.23 Ensure that the --audit-log-maxage argument is set to 30 or as appropriate (Automated)
# [FAIL] 1.2.24 Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate (Automated)
# [FAIL] 1.2.25 Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate (Automated)
# [FAIL] 1.3.2 Ensure that the --profiling argument is set to false (Automated)
# [FAIL] 1.4.1 Ensure that the --profiling argument is set to false (Automated)
# [FAIL] 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true (Automated)
```

<br />

### Fix the failing test `Fix this failed test 1.4.1: Ensure that the --profiling argument is set to false` 

<br />

#### Check the remediation for 1.4.1 which is as below. Edit `/etc/kubernetes/manifests/kube-scheduler.yaml` to add `--profiling=false`

```
1.4.1 Edit the Scheduler pod specification file /etc/kubernetes/manifests/kube-scheduler.yaml file
on the master node and set the below parameter.
--profiling=false
```

#### Rerun the kubebench and verify 1.4.1 is remediated.

```bash
./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml | grep "\[FAIL\] "
# [FAIL] 1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)
# [FAIL] 1.2.6 Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)
# [FAIL] 1.2.16 Ensure that the admission control plugin PodSecurityPolicy is set (Automated)
# [FAIL] 1.2.21 Ensure that the --profiling argument is set to false (Automated)
# [FAIL] 1.2.22 Ensure that the --audit-log-path argument is set (Automated)
# [FAIL] 1.2.23 Ensure that the --audit-log-maxage argument is set to 30 or as appropriate (Automated)
# [FAIL] 1.2.24 Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate (Automated)
# [FAIL] 1.2.25 Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate (Automated)
# [FAIL] 1.3.2 Ensure that the --profiling argument is set to false (Automated)
# [FAIL] 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true (Automated)
```

