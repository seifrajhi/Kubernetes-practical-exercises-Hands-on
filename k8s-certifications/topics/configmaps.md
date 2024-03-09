# [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

 - A ConfigMap is an API object used to store non-confidential data in key-value pairs. 
 - Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.
 - A ConfigMap allows you to decouple environment-specific configuration from your container images, so that your applications are easily portable.

<br />

### Check the configmaps on the cluster in the default namespace

<br />

<details><summary>show</summary><p>

```bash
kubectl get configmaps
# OR 
kubectl get cm
```

</p></details> 

<br />

### Check the configmaps on the cluster in all the namespaces

<br />

<details><summary>show</summary><p>

```bash
kubectl get configmaps --all-namespaces
# OR
kubectl get configmaps -A
```
</p></details> 

<br />

### Create a new pod `nginx-1` with `nginx` image and add env variable for `DB_HOST=db.example.com`, `DB_USER=development`, `DB_PASSWD=password`

<br />

<details><summary>show</summary><p>

```bash
kubectl run nginx-1 --image=nginx --env="DB_HOST=db.example.com" --env="DB_USER=development" --env="DB_PASSWD=password"
```

```bash
# verify env variables
kubectl exec nginx-1 -- env | grep DB_  
# DB_HOST=db.example.com
# DB_USER=development
# DB_PASSWD=password
```

</p></details> 

<br />

### Create a configmap named `db-config-1` with data `DB_HOST=db.example.com`, `DB_USER=development`, `DB_PASSWD=password`

<br />

<details><summary>show</summary><p>

```bash
kubectl create configmap db-config-1 --from-literal=DB_HOST=db.example.com --from-literal=DB_USER=development --from-literal=DB_PASSWD=password
```

OR 

```yaml
cat << EOF > db-config-1.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config-1
data:
  DB_HOST: db.example.com
  DB_PASSWD: password
  DB_USER: development
EOF

kubectl apply -f db-config-1.yaml
```

```bash
# verify 
kubectl describe configmap db-config-1
# Name:         db-config-1
# Namespace:    default
# Labels:       <none>
# Annotations:  <none>

# Data
# ====
# DB_USER:
# ----
# development
# DB_HOST:
# ----
# db.example.com
# DB_PASSWD:
# ----
# password
```

</p></details> 

<br />

### Create a configmap named `db-config-2` with data from file `db.properties`

<br />

```bash
cat <<EOT >> db.properties
DB_HOST=db.example.com
DB_USER=development
DB_PASSWD=password
EOT
```

<details><summary>show</summary><p>

```bash
kubectl create configmap db-config-2 --from-file=db.properties
```

```bash
# verify 
kubectl describe configmap db-config-2 
# Name:         db-config-2
# Namespace:    default
# Labels:       <none>
# Annotations:  <none>

# Data
# ====
# db.properties:
# ----
# DB_HOST=db.example.com
# DB_USER=development
# DB_PASSWD=password
```

</p></details> 

<br />

### Create a new pod `nginx-2` with `nginx` image and add env variable for `DB_HOST` from configmap map `db-config-1`

<br />

<details><summary>show</summary><p>

```yaml
cat << EOF > nginx-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-2
spec:
  containers:
  - image: nginx
    name: nginx-2
    env:
    - name: DB_HOST
      valueFrom: 
        configMapKeyRef: 
          name: db-config-1
          key: DB_HOST
EOF

kubectl apply -f nginx-2.yaml

kubectl exec nginx-2 -- env | grep DB_HOST # verify env variables
# DB_HOST=db.example.com
```

</p></details> 

<br />

### Create a new pod `nginx-3` with `nginx` image and add all env variables from from configmap map `db-config-1`

<br />

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
    envFrom:
    - configMapRef:
        name: db-config-1
EOF

kubectl apply -f nginx-3.yaml

kubectl exec nginx-3 -- env | grep DB_ # verify env variables
# DB_HOST=db.example.com
# DB_PASSWD=password
# DB_USER=development
```

</p></details> 

<br />

### Create a new pod `nginx-4` with `nginx` image and mount the configmap `db-config-1` as a volume named `db-config` and mount path `/config`

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
      - name: db-config
        mountPath: "/config"
        readOnly: true
  volumes:
    - name: db-config
      configMap:
        name: db-config-1
EOF

kubectl apply -f nginx-4.yaml

kubectl exec nginx-4 -- cat /config/DB_HOST # verify env variables
# db.example.com
```

</p></details> 

<br />

### Clean up 

```bash
kubectl delete pod nginx-1 nginx-2 nginx-3 nginx-4 --force --grace-period=0
kubectl delete configmap db-config-1 db-config-2
rm db.properties nginx-2.yaml nginx-3.yaml nginx-4.yaml
```
