# Local Development with Kubernetes :wheel_of_dharma:

Presentation of useful tools to develop with Kubernetes locally

## Local cluster

- [Minikube](https://github.com/kubernetes/minikube) : Run Kubernetes locally on Windows, Mac or Linux.
  - [demo](./minikube)

- [MicroK8S](https://microk8s.io/) : A single package of k8s that installs on 42 flavours of Linux.

- [Kind](https://kind.sigs.k8s.io/) : A tool for running local Kubernetes clusters using Docker container “nodes”.
  - [demo](./kind)

- [kubeadm-dind-cluster](https://github.com/kubernetes-sigs/kubeadm-dind-cluster) : A Kubernetes multi-node test cluster based on kubeadm. *DEPRECATED*

- [K3S](https://k3s.io/) / [K3D](https://k3d.io/) : lightweight Kubernetes distribution by Rancher


## Remote cluster

### Improve K8S command line UX
  
- [kubectx+kubens](https://github.com/ahmetb/kubectx) : Fast way to switch between clusters and namespaces
```
# Tip : easy merge kube config files and switch contexts
export KUBECONFIG=~/.kube/k1_config:~/.kube/k2_config:~/.kube/k3_config
kubectx
<3 contexts>
```
- [kube-shell](https://github.com/cloudnativelabs/kube-shell) : An integrated shell for working with the Kubernetes CLI
- [kube-prompt](https://github.com/c-bata/kube-prompt) : An interactive kubernetes client featuring auto-complete 
- [K9S](https://github.com/derailed/k9s) : A terminal UI to interact with your Kubernetes clusters
- [kube-ps1](https://github.com/jonmosco/kube-ps1) : Kubernetes prompt info for bash and zsh
- [Stern](https://github.com/wercker/stern) : Multi pod and container log tailing
- [Kail](https://github.com/boz/kail) : Kubernetes log viewer
- [KubeSpy](https://github.com/pulumi/kubespy) : Tools for observing Kubernetes resources in real time
```
kubectl create ns gd
kubens gd

# In one shell (keep it displayed)
kubespy trace deploy gd/nginx-deployment
# In another shell
kubectl create -f https://k8s.io/examples/controllers/nginx-deployment.yaml 

# Pod
kubespy status v1 Pod gd/nginx
kubectl create -f https://github.com/pulumi/kubespy/raw/master/examples/trivial-pulumi-example/yaml/nginx.yaml

# Service
kubespy trace service  gd/nginx
kubectl create -f https://github.com/pulumi/kubespy/raw/master/examples/trivial-service-trace-example/yaml/nginx.yaml
```
- [Kubectl plugins](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/)  
  - [Krew](https://github.com/GoogleContainerTools/krew) : Package manager for "kubectl plugins" 
  - [Plugins index](https://github.com/GoogleContainerTools/krew-index/tree/master/plugins)
 ```
 kubectl krew {search,info,install,upgrade,remove} 
 ```
  - Examples : 
    - `kubectl view-utilization -h`
    - `kubectl get-all --only-scope=namespace --namespace=default`

- [Arkade](https://github.com/alexellis/arkade) : helps you install kubernetes application with a single install command

### Development

- [kubefwd](https://github.com/txn2/kubefwd) : Bulk port forwarding Kubernetes services for local development
- [Skaffolfd](https://github.com/GoogleContainerTools/skaffold) : Easy and Repeatable Kubernetes Development
- [KSync](https://github.com/ksync/ksync)
- [Telepresence](https://www.telepresence.io/) : Debug your Kubernetes service locally
- [Tilt](https://tilt.dev/) : Manages local development instances for teams that deploy to Kubernetes
- [KubeSquash](https://github.com/solo-io/kubesquash/blob/master/README.md)
- [Kompose](http://kompose.io/) ([Conversion Matrix](https://github.com/kubernetes/kompose/blob/master/docs/conversion.md))

### GUI/TUI

- [K8S Dashboard](https://github.com/kubernetes/dashboard)
- [Kube-ops-view](https://github.com/hjacobs/kube-ops-view) : Read-only system dashboard for multiple K8s clusters
- [K9S](https://github.com/derailed/k9s)
- [Octant](https://octant.dev/docs/master/)
- [Kubernetic](https://kubernetic.com/)
- [k3x for k3d](https://github.com/inercia/k3x)
- [Portainer](https://www.portainer.io/) : [Beta version](https://github.com/portainer/portainer-k8s) for Kubernetes
- [KubeNav](https://github.com/kubenav/kubenav)
- [Lens](https://github.com/lensapp/lens)
- [Okteto](https://okteto.com/)

## Other tools

- [Dive](https://github.com/wagoodman/dive)

## Chaos gaming tools 🕹

- [Kube Invaders](https://github.com/lucky-sideburn/KubeInvaders)
- [Wild West Kubernetes](https://github.com/gshipley/wild-west-kubernetes)
- [Kube Doom](https://github.com/storax/kubedoom)
- [Kube Thanos](https://github.com/berkay-dincer/kubethanos)
- [Kube Chaos](https://github.com/Shogan/kube-chaos)

## Costing

- [Kube Resource Report](https://github.com/hjacobs/kube-resource-report)
```
kubereport () {
	mkdir -p /tmp/kubereport-output
	echo ""
	echo "----------------------------------------------------------"
	echo "Merging config files found in KUBECONFIG var..."
	echo "----------------------------------------------------------"
	echo $KUBECONFIG | sed 's/:/\n/g'
	echo ""
	echo "----------------------------------------------------------"
	kubectl config view --flatten > ~/.kube/config
	echo "Generating report..."
	echo "----------------------------------------------------------"
	docker pull hjacobs/kube-resource-report
	docker run -it --net=host -v ~/.kube/:/root/.kube/ -v /tmp/output:/output hjacobs/kube-resource-report /output
	echo ""
	echo "----------------------------------------------------------"
	echo "Opening report..."
	echo "----------------------------------------------------------"
	xdg-open /tmp/output/index.html &
}
```
- [KubeCost](https://kubecost.com/)

## Learning

- [Tutorials](https://kubernetes.io/docs/tutorials/)
- [Playground](https://labs.play-with-k8s.com/)
- [Katacoda](https://www.katacoda.com/courses/kubernetes)
- [Official doc](https://kubernetes.io/docs/home/)
- Comics
  - https://www.cncf.io/phippy/
  - https://cloud.google.com/kubernetes-engine/kubernetes-comic/
  - https://www.cncf.io/the-childrens-illustrated-guide-to-kubernetes/
  - https://brennerm.github.io/posts/kubernetes-overview-diagrams.html
  - Zines 
  
  ![SceneFromK8S1](https://drawings.jvns.ca/drawings/scenes-from-kubernetes-page1.svg)![SceneFromK8S2](https://drawings.jvns.ca/drawings/scenes-from-kubernetes-page2.svg)
  
  ![K8SComponents](https://pbs.twimg.com/media/DBzjTTKUIAA1OvE.jpg:small)

## Useful links

https://cloud.google.com/blog/products/containers-kubernetes/easier-kubernetes-development-from-your-laptop

https://medium.com/@wso2tech/multi-node-kubernetes-cluster-with-vagrant-virtualbox-and-kubeadm-9d3eaac28b98

https://garden.slides.com/ellenkorbes/k8sdevtools?token=t3egVfZS#/38

https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0

https://ostechnix.com/kubernetes-features/

https://github.com/medmouine/Kubernetes-autoscaling-poster/blob/main/k8s-auto-scaling-poster.pdf
