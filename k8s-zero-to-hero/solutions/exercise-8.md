## Exercise 8

Create the persistentVolume in file named *pv.yaml* :
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: strawberry-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: exam
  hostPath:
    path: /Data/Berry

```
Apply that file

```
kubectl create -f pv.yaml
```

Create the pvc yaml file

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: strawberry-pvc
  namespace: straw
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: exam

```
and apply that file
```
kubectl create -f pvc.yaml
```

Create deployment:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: strawberry-deploy
  name: strawberry-deploy
  namespace: straw
spec:
  replicas: 1
  selector:
    matchLabels:
      app: strawberry-deploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: strawberry-deploy
    spec:
      volumes:
        - name: strawberry-pv
          persistentVolumeClaim:
            claimName: strawberry-pvc
      containers:
      - image: nginx:1.7.9
        name: nginx
        volumeMounts:
          - mountPath: "/tmp/berry-data"
            name: strawberry-pv

```

Check that the strawberry pv is bound, the pvc is binded and the pod is running:

```
kubectl get pv strawberry-pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
strawberry-pv   2Gi        RWO            Retain           Bound    straw/strawberry-pvc   exam                    3m6s



kubectl get pvc -n straw
NAME             STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
strawberry-pvc   Pending                                      exam           14m


kubectl get pods -n straw
NAME                                 READY   STATUS    RESTARTS   AGE
strawberry-deploy-6494f99fcd-fv8nx   1/1     Running   0          5m40s


```







