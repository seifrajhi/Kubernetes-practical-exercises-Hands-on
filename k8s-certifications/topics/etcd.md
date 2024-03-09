# [ETCD](https://etcd.io/)

<br />

### Check the version of ETCD

<br />

```bash
kubectl get pod etcd-controlplane  -n kube-system -o yaml | grep image
# image: k8s.gcr.io/etcd:3.4.3-0
```

## Backup and Restore
Refer [Backing up ETCD Cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster) & [Restoring ETCD Cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster)

<br />

#### Create a snapshot of the etcd instance running at https://127.0.0.1:2379, saving the snapshot to the file path /opt/snapshot-pre-boot.db. Restore the snapshot. The following TLS certificates/key are supplied for connecting to the server with etcdctl:
 - CA certificate: /etc/kubernetes/pki/etcd/ca.crt
 - Client certificate: /etc/kubernetes/pki/etcd/server.crt
 - Client key: /etc/kubernetes/pki/etcd/server.key

<details><summary>show</summary><p>

#### Install ETCD Client

```bash
snap install etcd         # version 3.4.5, or
apt  install etcd-client
```

#### Create deployment before backup for testing

```bash
kubectl create deploy nginx --image=nginx --replicas=3
```

#### Backup ETCD

```bash
ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
          snapshot save /opt/snapshot-pre-boot.db
# Snapshot saved at /opt/snapshot-pre-boot.db
```

#### Delete the deployment 

```bash
kubectl delete deployment nginx
```

#### Restore ETCD Snapshot to a new folder

```bash
ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --name=master \
     --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
     --data-dir /var/lib/etcd-from-backup \
     --initial-cluster=master=https://127.0.0.1:2380 \
     --initial-cluster-token etcd-cluster-1 \
     --initial-advertise-peer-urls=https://127.0.0.1:2380 \
     snapshot restore /opt/snapshot-pre-boot.db
# 2021-12-21 13:56:56.460862 I | mvcc: restore compact to 1288
# 2021-12-21 13:56:56.716540 I | etcdserver/membership: added member e92d66acd89ecf29 [https://127.0.0.1:2380] to cluster 7581d6eb2d25405b
```

 #### Modify /etc/kubernetes/manifests/etcd.yaml

```bash
 # Update --data-dir to use new target location
 --data-dir=/var/lib/etcd-from-backup

# Update new initial-cluster-token to specify new cluster
 --initial-cluster-token=etcd-cluster-1

# Update volumes and volume mounts to point to new path
      volumeMounts:
          - mountPath: /var/lib/etcd-from-backup
            name: etcd-data
          - mountPath: /etc/kubernetes/pki/etcd
            name: etcd-certs
   volumes:
   - hostPath:
       path: /var/lib/etcd-from-backup
       type: DirectoryOrCreate
     name: etcd-data
```

#### Verify the deployment exists after restoration

```bash
kubectl get deployment nginx
```

</p></details>

<br />