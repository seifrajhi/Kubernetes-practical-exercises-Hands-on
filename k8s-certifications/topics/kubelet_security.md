# [Kubelet Security](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-authentication-authorization/)

<br />

### Check the Kubelet Security

<br />

#### Check Kubelet configuration

```bash
ps -ef | grep kubelet # check the --config parameter
# root      2600     1  3 05:21 ?        00:00:02 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf
```

#### Viewing the kubelet configuration file `/var/lib/kubelet/config.yaml` 

```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false # anonymous auth should be disabled - It should not be true
  webhook: # Authn mechanism set to webhook as certificate based auth instead of AlwaysAllow
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook # Authz mechanism set to webhook, instead of AlwaysAllow
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
# additional lines omitted for brevity
```

#### Check the key and certificate in the `kube-apiserver.yaml` file

```bash
cat kube-apiserver.yaml | grep kubelet-client    
# - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
# - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
```    

#### Verify the authentication using the above cert and key

```bash
curl -sk https://localhost:10250/pods/
# Unauthorized

curl -sk https://localhost:10250/pods/ --key /etc/kubernetes/pki/apiserver-kubelet-client.key --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt
# {"kind":"PodList","apiVersion":"v1","metadata":{},"items":[{"metadata":{"name":"etcd-controlplane","namespace": ...
```