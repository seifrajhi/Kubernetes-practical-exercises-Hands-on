# Create static Pods

_Static Pods_ are managed directly by the kubelet daemon on a specific node, without the [API server](https://kubernetes.io/docs/concepts/overview/components/#kube-apiserver) observing them. 

Unlike Pods that are managed by the control plane (for example, a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)); instead, the kubelet watches each static Pod (and restarts it if it fails).

Static Pods are always bound to one [Kubelet](https://kubernetes.io/docs/reference/generated/kubelet) on a specific node.

> Note:
> If you are running clustered Kubernetes and are using static Pods to run a Pod on every node, you should probably be using a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset) instead.

For example, this is how to start a simple web server as a static Pod:

1.  Choose a node where you want to run the static Pod. In this example, it's `my-node1`.

```
ssh my-node1
```

2.  Choose a directory, say `/etc/kubernetes/manifests` and place a web server Pod definition there, for example `/etc/kubernetes/manifests/static-web.yaml`

3. After a few seconds, you will see the _static-web_ pod.


## How do you find the path of the the directory holding the static pod definition files?

Run below command:

```
ps -aux | grep kubelet
```

and identify the kubelet config file:

`--config=/var/lib/kubelet/config.yaml`

Then check in the config file for staticPodPath.

```
ps -aux | grep /usr/bin/kubelet
```

From the output we can see that the kubelet config file used is

`/var/lib/kubelet/config.yaml`  

Next, lookup the value assigned for `staticPodPath`:

```
grep -i staticpod /var/lib/kubelet/config.yaml


Output: staticPodPath: /etc/kubernetes/manifests
```

As you can see, the path configured is the `/etc/kubernetes/manifests` directory.

