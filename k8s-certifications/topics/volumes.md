# [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

Kubernetes supports many types of volumes. A Pod can use any number of volume types simultaneously. Ephemeral volume types have a lifetime of a pod, but persistent volumes exist beyond the lifetime of a pod. When a pod ceases to exist, Kubernetes destroys ephemeral volumes; however, Kubernetes does not destroy persistent volumes. For any kind of volume in a given pod, data is preserved across container restarts.

- [Config Volumes](#config-volumes)
- [Secret Volumes](#secret-volumes)
- [Ephemeral Volumes](#ephemeral-volumes)
- [Persistent Volumes](#persistent-volumes)

<br />

## Config Volumes

<br />

### Create a new pod `nginx-3` with `nginx` image and mount the configmap `db-config-1` as a volume named `db-config` and mount path `/config`

<details><summary>show</summary><p>

```yaml
cat << EOF > nginx-3.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-3
spec:
  containers:
  - image: nginx
    name: nginx-3
    volumeMounts:
      - name: db-config
        mountPath: "/config"
        readOnly: true
  volumes:
    - name: db-config
      configMap:
        name: db-config-1
EOF

kubectl apply -f nginx-3.yaml

kubectl exec nginx-4 -- cat /config/DB_HOST # verify env variables
# db.example.com
```

</p></details> 

<br />

## Secret Volumes

<br />

### Create a new pod `nginx-4` with `nginx` image and mount the secret `db-secret-1` as a volume named `db-secret` and mount path `/secret`

<details><summary>show</summary><p>

```yaml
cat << EOF > nginx-4.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-4
spec:
  containers:
  - image: nginx
    name: nginx-4
    volumeMounts:
      - name: db-secret
        mountPath: "/secret"
        readOnly: true
  volumes:
    - name: db-secret
      secret:
        secretName: db-secret-1
EOF

kubectl apply -f nginx-4.yaml
```

```bash
kubectl exec nginx-4 -- cat /secret/DB_HOST  # verify env variables
# db.example.com
```

</p></details>

<br />

## [Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/)

<br />

### Create the redis pod with `redis` image with volume `redis-storage` as ephemeral storage mounted at `/data/redis`.

<details><summary>show</summary><p>

```yaml
cat << EOF > redis.yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-storage
      mountPath: /data/redis
  volumes:
  - name: redis-storage
    emptyDir: {} # Ephemeral storage
EOF

kubectl apply -f redis.yaml
```

</p></details>

<br />

### Create a pod as follows: 
 - Name: non-persistent-redis
 - container Image:redis
 - Volume with name: cache-control
 - Mount path: /data/redis
 - The pod should launch in the staging namespace and the volume must not be persistent.

<details><summary>show</summary><p>

```yaml
kubectl create namespace staging

cat << EOF > non-persistent-redis.yaml
apiVersion: v1
kind: Pod
metadata:
  name: non-persistent-redis
  namespace: staging
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: cache-control
      mountPath: /data/redis
  volumes:
  - name: cache-control
    emptyDir: {}
EOF

kubectl apply -f non-persistent-redis.yaml
```

</p></details>

<br />

## [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

<br />

### Create a persistent volume with name `app-data`, of capacity `200Mi` and access mode `ReadWriteMany`. The type of volume is `hostPath` and its location is `/srv/app-data`.

<details><summary>show</summary><p>

```yaml
cat << EOF > app-data.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: app-data
spec:
  storageClassName: manual
  capacity:
    storage: 200Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/srv/app-data"
EOF

kubectl apply -f app-data.yaml

kubectl get pv
# NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
# app-data   200Mi      RWX            Retain           Available           manual
```

</p></details>

<br />

### Create the following
 - PV `task-pv-volume` with storage `10Mi`, Access Mode `ReadWriteOnce` on hostpath `/mnt/data`.   
 - PVC `task-pv-claim` to use the PV. 
 - Create a pod `task-pv-pod` with `nginx` image to use the PVC mounted on `/usr/share/nginx/html`

<details><summary>show</summary><p>

```yaml
cat << EOF > task-pv-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
spec:
  storageClassName: manual
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
EOF

kubectl apply -f task-pv-volume.yaml

kubectl get pv
# NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
# task-pv-volume   10Mi       RWO            Retain           Available           manual                  6s
```

```yaml
cat << EOF > task-pv-claim.yaml
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
      storage: 10Mi
EOF

kubectl apply -f task-pv-claim.yaml

kubectl get pvc
#NAME            STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   AGE
#task-pv-claim   Bound    task-pv-volume   10Mi       RWO            manual         12s
kubectl get pv # check status bound
#NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
#task-pv-volume   10Mi       RWO            Retain           Bound    default/task-pv-claim   manual                  64s
```

```yaml
cat << EOF > task-pv-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-pod
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
EOF

kubectl apply -f task-pv-pod.yaml
```

</p></details>

<br />

### Get the storage classes (Storage class does not belong to namespace)

<br />

<details><summary>show</summary><p>

```bash
kubectl get storageclass
# OR
kubectl get sc
```
</p></details> 

<br />

### Clean up

<details><summary>show</summary><p>

```bash
rm nginx-3.yaml nginx-4.yaml redis.yaml
kubectl delete pod task-pv-pod redis nginx-3 nginx-4 --force
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume
```

</p></details>

<br />

