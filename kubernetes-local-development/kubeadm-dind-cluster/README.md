# kubeadm-dind-cluster

## Install

```bash
KUBEADM_DIND_VERSION="v0.2.0"
K8S_VERSION="v1.14"
wget https://github.com/kubernetes-sigs/kubeadm-dind-cluster/releases/download/${KUBEADM_DIND_VERSION}/dind-cluster-${K8S_VERSION}.sh
chmod +x dind-cluster-v1.14.sh
```

## Run

```bash
sudo ./dind-cluster-v1.14.sh up
```

## Stop and clean

```bash
#sudo systemctl stop kubelet
sudo ./dind-cluster-v1.14.sh down
sudo ./dind-cluster-v1.14.sh clean
```
