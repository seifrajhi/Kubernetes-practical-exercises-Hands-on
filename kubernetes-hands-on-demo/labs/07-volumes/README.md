# Persistent Volumes with k3d/k3s

With k3d we can mount the host to container path, and with persistent volumes we can set a hostPath for our persistent volumes. With k3d, all the nodes will be using the same volume mapping which maps back to the host.

Create the cluster:

```
> mkdir -p /tmp/k3dvol
> k3d create --name "k3d-cluster" --volume /tmp/k3dvol:/tmp/k3dvol --publish "80:80" --workers 2
> export KUBECONFIG="$(k3d get-kubeconfig --name='k3d-cluster')"
```

Our `00-hostpath-with-app.yml`

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/k3dvol"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo
spec:
  selector:
    matchLabels:
      app: echo
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: echo
    spec:
      volumes:
        - name: task-pv-storage
          persistentVolumeClaim:
            claimName: task-pv-claim
      containers:
      - image: busybox
        name: echo
        volumeMounts:
          - mountPath: "/data"
            name: task-pv-storage
        command: ["ping", "127.0.0.1"]
```

Deploy:

```
> kubectl apply -f 00-hostpath-with-app.yml
persistentvolume/task-pv-volume created
persistentvolumeclaim/task-pv-claim created
deployment.apps/echo created
```

View the persistent volumes:

```
> kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
task-pv-volume                             1Gi        RWO            Retain           Bound    default/task-pv-claim    manual                  6s
```

View the Persistent Volume Claims:

```
> kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
task-pv-claim    Bound    task-pv-volume                             1Gi        RWO            manual         11s
```

View the pods:

```
> kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
echo-58fd7d9b6-x4rxj   1/1     Running   0          16s
```

Exec into the pod:

```
> kubectl exec -it echo-58fd7d9b6-x4rxj sh
/ # df -h
Filesystem                Size      Used Available Use% Mounted on
overlay                  58.4G     36.1G     19.3G  65% /
osxfs                   233.6G    139.7G     86.3G  62% /data
/dev/sda1                58.4G     36.1G     19.3G  65% /etc/hosts
/dev/sda1                58.4G     36.1G     19.3G  65% /dev/termination-log
/dev/sda1                58.4G     36.1G     19.3G  65% /etc/hostname
/dev/sda1                58.4G     36.1G     19.3G  65% /etc/resolv.conf
```

Write the hostname of the current pod to the persistent volume path:

```
/ # echo $(hostname)
echo-58fd7d9b6-x4rxj
/ # echo $(hostname) > /data/hostname.txt
/ # exit
```

Exit the pod and read the content from the host (workstation/laptop):

```
> cat /tmp/k3dvol/hostname.txt
echo-58fd7d9b6-x4rxj
```

Look at the host where the pod is running on:

```
> kubectl get nodes -o wide
NAME                       STATUS   ROLES    AGE   VERSION        INTERNAL-IP    EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION     CONTAINER-RUNTIME
k3d-k3d-cluster-server     Ready    master   13m   v1.17.2+k3s1   192.168.32.2   <none>        Unknown    4.9.184-linuxkit   containerd://1.3.3-k3s1
k3d-k3d-cluster-worker-1   Ready    <none>   13m   v1.17.2+k3s1   192.168.32.4   <none>        Unknown    4.9.184-linuxkit   containerd://1.3.3-k3s1
k3d-k3d-cluster-worker-0   Ready    <none>   13m   v1.17.2+k3s1   192.168.32.3   <none>        Unknown    4.9.184-linuxkit   containerd://1.3.3-k3s1
```

Delete the pod:

```
> kubectl delete pod/echo-58fd7d9b6-x4rxj
pod "echo-58fd7d9b6-x4rxj" deleted
```

Wait until the pod is rescheduled again and verify if the pod is running on a different node:

```
> kubectl get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE   IP          NODE                       NOMINATED NODE   READINESS GATES
echo-58fd7d9b6-fkvbs   1/1     Running   0          35s   10.42.2.9   k3d-k3d-cluster-worker-1   <none>           <none>
```

Exec into the new pod:

```
> kubectl exec -it echo-58fd7d9b6-fkvbs sh
```

View if the data is persisted:

```
/ # hostname
echo-58fd7d9b6-fkvbs

/ # cat /data/hostname.txt
echo-58fd7d9b6-x4rxj
```
