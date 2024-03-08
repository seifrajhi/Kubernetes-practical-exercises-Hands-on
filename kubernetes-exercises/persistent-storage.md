# Persistent Storage

In this exercise you will learn how to persist the filesystem state of your containers using dynamic volume provisioning.

## Learning Goals

- How to attach a volume to container in a pod
- How to use dynamic volume provisioning to create persistent block storage to save the state of your applications
- How to create PersistentVolumes and use them with PersistentVolumeClaims

## Introduction

Kubernetes, a persistent volume claim (PVC) is a request for storage by a user.
It is a way for a pod to request a specific amount of storage from the cluster. When a PVC is created, it is automatically bound to a persistant volume (PV) that satisfies the PVC's requirements.

A storage class (SC) is a way to define the properties of a PV. It is a blueprint for creating PVs, and it specifies things like the type of storage, the amount of storage, and the access modes for the PV.
The cluster then uses the storage class to find or create a PV that matches the PVC's requirements.

In summary:

- PVs are the actual storage resources in the cluster
- PVCs are requests for storage made by users
- SCs are the specifications for creating PVs.

## Exercise

### Overview

- Observe that the state of the postgres database is not persisted between pod lifecycles
- Inspect the Available StorageClasses (sc) of the cluster
- Create a PersistentVolume (pv) using dynamic volume provisioning
- Consume the PersistentVolume using a PersistentVolumeClaim (pvc) and mounting the volume to a pod
- Delete pod with volume attached and observe that state is persisted when a new pod is created

### Step by step instructions:

<details>
<summary>
Step by step:
</summary>

### Observe that the state of the postgres database is not persisted between pod lifecycles

Deploy the manifests located in `persistent-storage/start`

> :bulb: If you have resources already deployed from a previous exercise, you might want to clean them up first.

- Open the frontend webpage in your browser.
- Observe that the frontend reports that it is connected to the database.
- Add some quotes. We will need them later to test persistency
- Retrieve all of the quotes, observe that your quotes are part of the retrieved quotes.
- Now delete the postgres pod using `kubectl delete pod <pod-name>`
- In the frontend webpage, retrieve quotes, and observe that you now only get the default 5 quotes from the database.

What we have observed here is that the state of our database is not persisted between pod lifecycles!
In order to fix this, we need to persist the filesystem state of our database container to a `volume`.

### Inspect the Available StorageClasses (sc) of the cluster

Use `kubectl` to get the available `StorageClasses` in the cluster, the shortname for `StorageClass` is `sc`:

```
kubectl get StorageClasses
```

Expected output:

```
AME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  54m
```

We see that we indeed have a `StorageClass` available and ready for use!

<details>

<summary>:bulb: What do the columns mean?</summary>

The output of the `kubectl get sc` command provides some useful information about the StorageClass:

- `PROVISIONNER` what is the underlying storage provider, in this case `AWS EBS` (Elastic Block Storage)
- `RECLAIMPOLICY` what will happen with the volume when the `PersistentVolume` resource is deleted, in this case `Delete` will delete the block storage.
- `VOLUMEBINDINGMODE` specifies how to provision the actual volume, `WaitForFirstConsumer` will provision the actual volume object once there is a matching claim.
- `ALLOWVOLUMEEXPANSION` defines whether a volume can be expanded in size at a later point in time.

</details>

### Create a PersistentVolume (pv) using dynamic volume provisioning

Let's create a `PersistentVolume` (pv)!

While we could create a manifest for a `PersistentVolume` manually we will not do that in this exercise.

In practice we will almost always create a `PersistentVolume` by creating `PersistentVolumeClaim`, which uses a `StorageClass` to create the actual volume.

Create a new file `persistent-storage/start/postgres-pvc.yaml`

Copy and paste the below boilerplate yaml to the new file:

```yaml
apiVersion:
kind:
metadata:
  name:
spec:
  storageClassName:
  accessModes:
    -
  resources:
    requests:
      storage:
```

Next we fill in the values:

- The `apiVersion` should be `v1`
- The `kind` is `PersistentVolumeClaim`
- The `metadata.name` should be `postgres-pvc`
- From the previous section we know that we have one available `StorageClass`, so the value of `spec.storageClassName` is the name of that, in this case `"gp2"` (with quotes)
- The `spec.accessModes` list should contain one item with the value `ReadWriteOnce`
- the `spec.resources.requests.storage` is the size of the volume in Gibibytes (Gi), set it to `5Gi`

<details>
<summary>The finished manifest should look like this</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  storageClassName: "gp2"
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

</details>

Apply your new `PersistenVolumeClaim` with `kubectl apply`:

```
kubectl apply -f persistent-storage/start/postgres-pvc.yaml
```

Expected output:

```
persistentvolumeclaim/postgres-pvc created
```

Check that the `PersistenVolumeClaim` was created using `kubectl get`:

```
kubectl get persistentvolumeclaim
```

Expected output:

```
NAME           STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-pvc   Pending                                      gp2            3m19s
```

Check if a `PersistentVolume` was created using `kubectl get`:

```
kubectl get persistentvolume
```

Expected output

```
No resources found
```

> :bulb: `PersistentVolumes` objects are `cluster-wide`, ie. "not-namespaced", so you might see `PersistentVolumes` belonging to other users.

We expect that a PersistentVolume has not been created _yet._

As we can see in the `kubectl get persistentvolumeclaim` output above, our `PersistenVolumeClaim` is in the `Pending` status.

This is because the `VOLUMEBINDINGMODE` of the StorageClass is set to `WaitForFirstConsumer`, as we saw in the previous section.

`WaitForFirstConsumer` will not create the actual volume object until it is used by a pod.

> :bulb: The reason you might not want to not always create volumes as soon as `pvc` objects are created is to reduce costs, by not creating resources that are not used before they are attached to a pod.

Let's attach the PersistenVolumeClaim to our postgres pod!

### Consume the PersistentVolume using a PersistentVolumeClaim (pvc) and mounting the volume to a pod

Open the postgres deployment manifest in your text editor `persistent-storage/start/postgres-deployment.yaml`.

In the `spec.template.spec` add the following section:

```yaml
    ...
    spec:
      volumes:
        - name:
          persistentVolumeClaim:
            claimName:
      ...
```

Add the values to the snippet:

- `spec.template.spec.volumes[0].name` is the name we will reference when we mount the volume to a container in a moment.
  set it to `postgres-pvc`
- `spec.template.spec.volumes[0].persistentVolumeClaim.claimName` is the `name` of the `PersistenVolumeClaim` we have created above, set it to the name you used, e.g. `postgres-pvc`

> :bulb: In this case the volume name and reference to the `pvc` name are the same, this is coincidental, and they can be different.

<details>
<summary>How the finished manifest should look</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    metadata:
      ...
    spec:
      volumes:
        - name: postgres-pvc # name we can reference below in container
          persistentVolumeClaim:
            claimName: postgres-pvc # name of the actual pvc
      containers:
      ...
```

</details>

Next we mount the volume we have defined to the postgres container:

In the deployment manifest file, add the following section to the postgres container spec, e.g. `spec.template.spec.containers[0].volumeMounts`

```yaml
volumeMounts:
  - name:
    mountPath:
    subPath:
```

Fill in the values:

- `name` should be the name we specified above when we declared the available volumes.
  In this case this should be `postgres-pvc`
- `mountPath` is the path in container to mount the volume to. For postgres, the database state is stored to the path `/var/lib/postgresql/data`
- `subPath` should be `postgres`, and specifies a directory to be created within the volume, we need this because of a quirk with combining `AWS EBS` with Postgres.
  (If you are curios why: https://stackoverflow.com/a/51174380)

<details>
<summary>The finished manifest should look like this</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    metadata:
      ...
    spec:
      volumes:
        - name: postgres-pvc # name we can reference below in container
          persistentVolumeClaim:
            claimName: postgres-pvc # name of the actual pvc
      containers:
        - image: docker.io/library/postgres:14.3
          name: postgres
          ...
          env:
            ...
          volumeMounts:
            - name: postgres-pvc
              mountPath: /var/lib/postgresql/data
              subPath: postgres
```

</details>

Apply the changes to the postgres deployment using `kubectl apply`:

```
kubectl apply -f persistent-storage/start/postgres-deployment
```

Expected output:

```
deployment.apps/postgres configured
```

Observe that the `PersistentVolume` is now created:

```
kubectl get persistentvolumeclaims,persistentvolumes
```

Expected output:

```
NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/postgres-pvc   Bound    pvc-d60a8787-330e-4b34-96d9-c2ad4dc18dbc   5Gi        RWO            gp2            38m

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
persistentvolume/pvc-d60a8787-330e-4b34-96d9-c2ad4dc18dbc   5Gi        RWO            Delete           Bound    default/postgres-pvc   gp2                     4m10s
```

### Delete pod with volume attached and observe that state is persisted when a new pod is created

Now that the state of our postgres database is persisted to the volume, let's verify:

- Open the frontend webpage and add some quotes
- Retrieve quotes from the database, and observe that your quotes are among them
- Delete the database pod with `kubectl delete pod <postgres-pod-name>`
- Wait for the postgres pod to be recreated (you can watch for pod changes with `kubectl get pods --watch`)
- In the frontend webpage, retrieve quotes and obeserve that your quotes are among them

</details>

### Clean up

Delete all resources created using `kubectl delete -f <manifest-files>`

```
kubectl delete -f persistent-storage/start
```
