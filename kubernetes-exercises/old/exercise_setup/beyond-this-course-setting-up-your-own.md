# Setting up multiple nodes in a cluster
We will be using a tool called [KubeAdm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) to set up a multi node cluster. 

KubeAdm is built for setting up and provisioning a cluster on bare metal, especially when having to interact with existing environments set up by puppet, ansible and etc. 

For Microsoft Azure the [Azure Container Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes) does this for you. 

Similarly on Google Cloud Platform there is the [Google Container Engine (GCE)](https://cloud.google.com/container-engine/). 

For Amazon Web Services [Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/). Also [Kubernetes Operations (KOPS)](https://github.com/kubernetes/kops) is used quite often to have more control over the cluster.

Going back to kubeadm, you will have to select a master and a given amount of nodes.

Run ssh to get onto the master, and verify that kubeadm is there: 
```
kubeadm --help
```

On the machine you have chosen as master, run: 
```
sudo kubeadm init
```

This process takes about a minute or so, while the master sets up. 

Copy the kubeadm join command output in the terminal (similar to the one below) before continuing, as you will need it for the nodes to join.

```
kubeadm join --token 2731ee.bb0be06012dbac00 172.31.18.205:6443 --discovery-token-ca-cert-hash sha256:fe634423c08ba596351dffd610503b4311f7160efcd49e343de83949ff4df610
```

KubeAdm will tell you to copy some files for configurations, but in case you missed it run: 

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

This will set up the configurations needed to allow the other machines to join the cluster. 

To allow the pods on each node to talk, we will need to apply a pod network. For this exercise the choice is on Weave Net, but other options are Calico, Canal, Flannel, Kube-Router and Romana. 

```
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
```

We can verify that the pod network is correctly installed by running : 
```
kubectl get pods --all-namespaces
```
The relevant pod is kube-dns, which needs to have 3/3 running before continuing to join nodes to the cluster.

Ssh to all nodes and run the kubeadm join command as root/sudo that you copied previously. 

```
sudo kubeadm join --token 2731ee.bb0be06012dbac00 172.31.18.205:6443 --discovery-token-ca-cert-hash sha256:fe634423c08ba596351dffd610503b4311f7160efcd49e343de83949ff4df610
```

This should allow the node to join the cluster ! Be mindful that for this to work port 6443 has to be open on master.

Now you can run commands on master by using kubectl!

## Optionally, execute commands on cluster from another machine than master
Optionally, having to ssh to master is not the best of things. This can be changed by handing over the config to another machine: 

```
scp root@<master ip>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
```

## Kubernetes yml
