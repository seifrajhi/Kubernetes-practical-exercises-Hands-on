# Lab Solution

To get access to the node's disk, create a new Pod with a `HostPath` volume targeting the root path `/`.

## Create a Pod with a HostPath volume

[sleep-with-hostpath.yaml](solution/sleep-with-hostpath.yaml) uses a HostPath volume in the Pod spec.

Deploy the Pod:

```
kubectl apply -f labs/persistentvolumes/solution
```

The Pod container mounts the root of the node's disk to `/node-root` inside the container, and it runs as root.

That means you can do pretty much anything on the disk:

```
kubectl exec pod/sleep -- ls /node-root

kubectl exec pod/sleep -- mkdir -p /node-root/secret/hacker/tools

kubectl exec pod/sleep -- ls -l /node-root/secret/hacker
```

> That's why its not secure :) If you do need access to the node's disk you should use a hostPath with a more restrictive scope, not the entire root drive.

> Back to the [exercises](README.md).