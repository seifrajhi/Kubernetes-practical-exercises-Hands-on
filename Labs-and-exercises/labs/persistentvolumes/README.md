# Storing Application Data with PersistentVolumes

Kubernetes creates the container filesystem and it can mount multiple sources. We've seen ConfigMaps and Secrets which are typically read-only mounts, now we'll use writeable [volumes](https://kubernetes.io/docs/concepts/storage/volumes/).

Storage in Kubernetes is pluggable so it supports different types - from local disks on the nodes to shared network filesystems. 

Those details are kept away from the application model using an abstraction - the [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#introduction), which an app uses to request storage.

## API specs

- [PersistentVolumeClaim](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#persistentvolumeclaim-v1-core)

<details>
  <summary>YAML overview</summary>


The simplest PersistentVolumeClaim (PVC) looks like this:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: small-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
```

As with ConfigMaps and Secrets, you use the PVC name to reference a volume in your Pod spec. The PVC spec defines its requirements:

* `accessModes` - describes if the storage is read-only or read-write, and whether it's exclusive to one node or can be accessed by many
* `resources` - the amount of storage the PVC needs

In the Pod spec you can include a PVC volume to mount in the container filesystem:

```
volumes:
  - name: cache-volume
    persistentVolumeClaim:
      claimName: small-pvc
```

</details><br />

## Data in the container's writeable layer

Before we get to PVCs, we'll look at other options for writing application data in Kubernetes.

Every container has a writeable layer which can be used to create and update files.

The demo app for this lab is a Pi-calculating website, which is fronted by an Nginx proxy. The proxy caches responses from the website to improve performance.

Deploy and try the app:

```
kubectl apply -f labs/persistentvolumes/specs/pi
```

> Browse to http://localhost:30010/pi?dp=30000 or http://localhost:8010/pi?dp=30000 you'll see it takes over a second to calculate the response and send it

📋 Refresh and the response will be instant - check the response cache in Nginx, you can see it in the `/tmp` folder.

<details>
  <summary>Not sure how?</summary>

```
kubectl exec deploy/pi-proxy -- ls /tmp
```

</details><br />

Now stop the container process, which forces a Pod restart:

```
kubectl exec deploy/pi-proxy -- kill 1

kubectl get po -l app=pi-proxy
```

Check the `/tmp` folder in the new container and you'll see it's empty. Refresh your Pi app and it will take another second to load, because the cache is empty so it gets calculated again.

> ℹ Data in the container writeable layer has the same lifecycle as the container. When the container is replaced, the data is lost.

## Pod storage in EmptyDir volumes

Volumes mount storage into the container filesystem from an outside source.The simplest type of volume is called `EmptyDir` - it creates an empty directory at the Pod level, which Pod containers can mount.

You can use it for data which is not permanent, but which you'd like to survive a restart. It's perfect for keeping a local cache of data.

- [caching-proxy-emptydir/nginx.yaml](specs/caching-proxy-emptydir/nginx.yaml) - uses an EmptyDir volume, mounting it to the `/tmp` directory

This is a change to the Pod spec, so you'll get a new Pod with a new empty directory volume:

```
kubectl apply -f labs/persistentvolumes/specs/caching-proxy-emptydir

kubectl wait --for=condition=Ready pod -l app=pi-proxy,storage=emptydir
```

Refresh your page to see the Pi calculation happen again - the result gets cached and you'll see the  `/tmp` folder filling up.

> The container sees the same filesystem structure, but now the /tmp folder is mounted from the EmptyDir volume

📋 Stop the Nginx process and the Pod will restart. Check the `tmp` folder in the new container to see if the old data is still available.

<details>
  <summary>Not sure how?</summary>

```
kubectl exec deploy/pi-proxy -- kill 1

kubectl get pods -l app=pi-proxy,storage=emptydir 

kubectl exec deploy/pi-proxy -- ls /tmp
```

</details><br />

Refresh the site with the new container and it loads instantly.

If you delete the Pod then the Deployment will create a replacement - with a new EmptyDir volume which will be empty.

> ℹ Data in EmptyDir volumes has the same lifecycle as the Pod. When the Pod is replaced, the data is lost.

## External storage with PersistentVolumeClaims

Persistent storage is about using volumes which have a separate lifecyle from the app - so the data persists when containers and Pods get replaced.

Storage in Kubernetes is pluggable, and production clusters will usually have multiple types on offer, defined as [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/):

```
kubectl get storageclass
```

You'll see a single StorageClass in Docker Desktop and k3d, but in a cloud service like AKS you'd see many, each with different properties (e.g. a fast SSD that can be attached to one node, or a shared network storage location which can be used by many nodes).

You can create a PersistentVolumeClaim with a named StorageClass, or omit the class to use the default.

- [caching-proxy-pvc/pvc.yaml](specs/caching-proxy-pvc/pvc.yaml) requests 100MB of storage, which a single node can mount for read-write access

```
kubectl apply -f labs/persistentvolumes/specs/caching-proxy-pvc/pvc.yaml
```

Each StorageClass has a provisioner which can create the storage unit on-demand.


📋 List the persistent volumes and claims.

<details>
  <summary>Not sure how?</summary>

```
kubectl get pvc

kubectl get persistentvolumes
```

> Some provisioners create storage as soon as the PVC is created - others wait for the PVC to be claimed by a Pod

</details><br />


This [Deployment spec](specs/caching-proxy-pvc/nginx.yaml) updates the Nginx proxy to use the PVC:

```
kubectl apply -f labs/persistentvolumes/specs/caching-proxy-pvc/

kubectl wait --for=condition=Ready pod -l app=pi-proxy,storage=pvc

kubectl get pvc,pv
```

> Now the PVC is bound and the PersistentVolume exists with the requested size and access mode in the PVC

The PVC starts off empty. Refresh the app and you'll see the `/tmp` folder getting filled. 

📋 Restart and then replace the Pod and confirm the data in the PVC survives both.

<details>
  <summary>Not sure how?</summary>

```
# force the container to exit
kubectl exec deploy/pi-proxy -- kill 1

kubectl get pods -l app=pi-proxy,storage=pvc

kubectl exec deploy/pi-proxy -- ls /tmp
```

```
# force a rollout to replace the Pod
kubectl rollout restart deploy/pi-proxy

kubectl get pods -l app=pi-proxy,storage=pvc

kubectl exec deploy/pi-proxy -- ls /tmp
```

Try the app again and the new Pod still serves the response from the cache, so it will be super fast.

</details><br />

> ℹ Data in PersistentVolumes has its own lifecycle. It survives until the PV is removed.


## Lab

There's an easier way to get persistent storage, but it's not as flexible as using a PVC, and it comes with some security concerns.

Run a simple sleep Pod with a different type of volume, that gives you access to the root drive on the host node where the Pod runs.

Can you use the sleep Pod to find the cache files from the Nginx Pod?

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___


## **EXTRA** Manual PVC management with PVs

<details>
  <summary>Take ownership of the PersistentVolumes lifecycle</summary>

Some provisioners delete a PV when the PVC using it gets deleted:

```
kubectl delete -f labs/persistentvolumes/specs/caching-proxy-pvc/

kubectl get pods -l app=pi-proxy

kubectl get pvc

kubectl get pv
```

> Depending on your storage provisioner, the PV may still exist with the data still in it, so it can be used in another PVC. Or it may have been deleted.

When you need more control you can manually manage the PV lifecycle:

- [persistentVolume.yaml](specs/caching-proxy-pv/persistentVolume.yaml) defines a PV which uses `local` storage, and attaches to a node which has a label `labs-pvc`
- [caching-proxy-pv/pvc.yaml](specs/caching-proxy-pv/pvc.yaml) requests a volume by name, instead of using a Storage Class
- [caching-proxy-pv/nginx.yaml](specs/caching-proxy-pv/nginx.yaml) updates the proxy deployment to use the new PVC 

The PV uses the `local` volume type, which means it gets created as a directory on the node's disk. It uses a `NodeSelector` to specify the node it should use.

```
kubectl apply -f labs/persistentvolumes/specs/caching-proxy-pv

kubectl get pvc,pv -l app=pi-proxy

kubectl get pod -l app=pi-proxy,storage=local
```

The PV and PVC exist - they may be Bound or Pending, depending on how fast you copy and paste, but the Pod will stay in the Pending state.

The events tell us why:

```
kubectl describe pod -l app=pi-proxy,storage=local
```

The PV can't find a node matching the label selector, and the unhelpul Pod message tells us that the Pod can't be scheduled because there's no node where it can follow the PV.

Add a label to a node and everything will flow through:

```
kubectl label node $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}') labs-pvc=1

kubectl get nodes --show-labels

kubectl describe pod -l app=pi-proxy,storage=local
```

Now the Pod is scheduled - but there's another error... That's one for you to think about (what you did in the lab will have helped) :)

</details><br/>

___

## Cleanup

```
kubectl delete all,cm,pvc,pv -l kubernetes.courselabs.co=persistentvolumes
```