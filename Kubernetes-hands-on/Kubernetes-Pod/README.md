<div align=center>

# What is a pod?

<a href="[https://github.com/alifiroozi80/CKA](https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on/edit/master/Kubernetes-Pod)">
    <img src="https://d33wubrfki0l68.cloudfront.net/aecab1f649bc640ebef1f05581bfcc91a48038c4/728d6/images/docs/pod.svg" alt="Logo" width="850" height="400">
</a>

</div>	
	
- A pod is like a smallest cookie_box in the kubernetes world

- A container is like a cookie which is stored inside the cookie_box(pod)

- It is the foundational concept in the k8's all other objects(cookie_box) models are based on the pod
		
# what is pod deployment?

- when we intially setup a pod, we give this specifications from a file called (manifest(a set of desired
 state which is wanted by the user))   
	
- step1: file handed from kubectl API to the Masternode(control plane) API server
	
- step2: file stored to etcd
	
- step3: schedular find nodes which are this pods suitable to fit in
	
- step4: schedular assign a pod to the node
	
- step5: the status of schedular assigned node will give back to the (Master node)API server from the schedular
	
- step6: now kubectl hand the instructions to over to the CRI(container runtime interface) 
	
- step7: image is pulled from the registry(OCI image spec) only if OCI req fulfilled
	
- step8: this transportaion of image will from the registry has also a OCI called (Open Container Intiative
 distribution spec) 
	
- step9: the pod is hosted inside worker node which holds (runtime+pod+container)
	
- step10: now runc(main runtime (OCI runtime spec)) holds 2 things one is image repo(collection of image 
layers) and second one is directory, which holds the image
	
- step 11: after a clone() system call has been performed by the runc that forward to the linux kernel
	
- kernel creates all new_name_spaces(they are 7 of them still counting) to form an individual isolated 
container(don't confuse with docker containers) all this container engines like (rkt,docker,crio) they just perform 
operations required to forward the manifest spec and other details to the kernel, real containers are created by only, 
only from linux

- This is just an overview of the whole container creation process, as you go forward I will state each detail 
what's happening inside
	
	
	
## Multi container

- A pod consists can consists of many contianers, if we do that then we're violating one process(container) 
for one pod, but we want to use in some cases like (what if we want to store logs, the second (helper)container is 
responsible to perform file synchronization, logging, and watcher capabilities and it also called as sidecar), we 
can deploy two containers from the manifest file



## Pod Networking

- Pod networking is happens, where when two pods want to talk to each other, this done by pod Networking, 
this is performed by individual pod IP, the pod networking takes place using this IP(back&forth) communication 
takes place 
	
	
	
	
## intra-pod networking  
	
- intially when pod was created the first container in the pod is called as pause container(which holds the 
cluster IP) for expose traffic to outside world 
	
- When helper container and main container want to talk to each other they use IPC(inter process communication
(name space) by through a message Queue) each containers communicate locally, they share same IP from the pod IP but 
with different ports
	
	
	
## pod-lifecycle

- as all objects on this earth has lifecycle, pod also has a lifecyle, If we see this from high level POV 
it has 3 stages
	
- pending, running, succeesful
	
- there also we have a stage called falied, when pod was at (pending, running) it has a chance it may also 
fails to create pod because of the invalid format, invalid image, maybe it doesn't full filling CRI runtime spec, and other reasons...
	
	


