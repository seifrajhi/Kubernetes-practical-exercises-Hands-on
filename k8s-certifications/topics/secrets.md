# [Namespaces](https://kubernetes.io/docs/concepts/configuration/secret/)

 - A secret is an API object used to store non-confidential data in key-value pairs. 
 - Pods can consume secrets as environment variables, command-line arguments, or as configuration files in a volume.
 - A secret allows you to decouple environment-specific configuration from your container images, so that your applications are easily portable.

<br />

### Check the secrets on the cluster in the default namespace

<details><summary>show</summary><p>

```bash
kubectl get secrets
```

</p></details> 

<br />

### Check the secrets on the cluster in all the namespaces

<details><summary>show</summary><p>

```bash
kubectl get secrets --all-namespaces
# OR 
kubectl get secrets -A
```

</p></details> 

<br />

### Create a secret named `db-secret-1` with data `DB_HOST=db.example.com`, `DB_USER=development`, `DB_PASSWD=password`

<details><summary>show</summary><p>

```bash
kubectl create secret generic db-secret-1 --from-literal=DB_HOST=db.example.com --from-literal=DB_USER=development --from-literal=DB_PASSWD=password
```

OR 

```yaml
cat << EOF > db-secret-1.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret-1
data:
  DB_HOST: ZGIuZXhhbXBsZS5jb20=
  DB_PASSWD: cGFzc3dvcmQ=
  DB_USER: ZGV2ZWxvcG1lbnQ=
EOF

kubectl apply -f db-secret-1.yaml
```

```bash
kubectl describe secret db-secret-1 # verify
Name:         db-secret-1
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
DB_HOST:    14 bytes
DB_PASSWD:  8 bytes
DB_USER:    11 bytes 
```

</p></details> 

<br />

### Create a secret named `db-secret-2` with data from file `secret.properties`

```bash
cat <<EOT >> secret.properties
DB_HOST=db.example.com
DB_USER=development
DB_PASSWD=password
EOT
```

<details><summary>show</summary><p>

```bash
kubectl create secret generic db-secret-2 --from-file=secret.properties
```

```bash
kubectl describe secret db-secret-2 # verify
Name:         db-secret-2
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
secret.properties:  62 bytes
```

</p></details> 

<br />

### Create a new pod `nginx-2` with `nginx` image and add env variable for `DB_HOST` from secret `db-secret-1`

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
        secretKeyRef: 
          name: db-secret-1
          key: DB_HOST
EOF

kubectl apply -f nginx-2.yaml
```

```bash
kubectl exec nginx-2 -- env | grep DB_HOST # verify env variables
# DB_HOST=db.example.com 
```

</p></details> 

<br />

### You are tasked to create a secret and consume the secret in a pod using environment variables as follow:
- Create a secret named another-secret with a key/value pair; key1/value4
- Start an nginx pod named nginx-secret using container image nginx, and add an environment variable exposing the value of the secret key key 1, using COOL_VARIABLE as the name for the environment variable inside the pod

<details><summary>show</summary><p>

```bash
kubectl create secret generic another-secret --from-literal=key1=value4
```

```yaml
cat << EOF > nginx-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-secret
spec:
  containers:
  - image: nginx
    name: nginx-secret
    env:
    - name: COOL_VARIABLE
      valueFrom: 
        secretKeyRef: 
          name: another-secret
          key: key1
EOF

kubectl apply -f nginx-secret.yaml
```

```bash
kubectl exec nginx-2 -- env | grep DB_HOST # verify env variables
# DB_HOST=db.example.com 
```

</p></details> 

<br />

### Create a new pod `nginx-3` with `nginx` image and add all env variables from from secret map `db-secret-1`

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
    - secretRef:
        name: db-secret-1
EOF

kubectl apply -f nginx-3.yaml
```

```
kubectl exec nginx-3 -- env | grep DB_ # verify env variables
# DB_HOST=db.example.com
# DB_PASSWD=password
# DB_USER=development 
```

</p></details> 

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

### Create a tls secret using tls.crt and tls.key in the data folder.

<details><summary>show</summary><p>

```bash
kubectl create secret tls my-tls-secret --cert=../data/tls.crt --key=../data/tls.key
```

```bash
kubectl describe secret my-tls-secret #verify
Name:         my-tls-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1932 bytes
tls.key:  3273 bytes
```

</p></details> 

<br />

### Create a docker registry secret `regcred` with below details and create new pod `nginx-5` with `nginx` image and use the private docker registry.
 - docker-server : example.com
 - docker-username : user_name
 - docker-password : password
 - docker-email : user_name@example.com

<details><summary>show</summary><p>

```bash
kubectl create secret docker-registry regcred --docker-server=example.com --docker-username=user_name --docker-password=password --docker-email=user_name@example.com
```

```yaml
cat << EOF > nginx-5.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-5
spec:
  containers:
  - name: nginx-5
    image: nginx
  imagePullSecrets:
  - name: regcred
EOF

kubectl apply -f nginx-5.yaml
```

</p></details> 

<br />

### Clean up 

```bash
kubectl delete pod nginx-1 nginx-2 nginx-3 nginx-4 nginx-5 nginx-secret --force --grace-period=0
kubectl delete secret db-secret-1 db-secret-2 my-tls-secret regcred
rm secret.properties nginx-2.yaml nginx-3.yaml nginx-4.yaml nginx-5.yaml nginx-secret.yaml
```
