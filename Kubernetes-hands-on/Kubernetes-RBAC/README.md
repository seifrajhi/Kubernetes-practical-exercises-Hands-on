<div align=center>
  
## Role Based Access Control

![p1](https://user-images.githubusercontent.com/58173938/206911512-7762d088-22fe-483a-b1a7-ee63b5b021a3.png)

  </div>
  
Kubernetes does not have a concept of users, instead it relies on certificates and would `only` trust certificates signed by its `own CA`. In the above presentation the username Mohan is just a (string of alpha-numeric characters)

RBAC stands for "Role-Based Access Control" and is a method for managing `permissions` in a Kubernetes cluster. In simple terms, RBAC allows you to `define roles` for individual users and groups, and then `assign` those roles to `specific resources` within your cluster. This allows you to control which users and applications have access to `certain parts` of your cluster, and can help to `ensure` that your cluster is secure and `well-organized`.


### Create Kubernetes cluster

  ```yaml
  kind create cluster --name rbac --image kindest/node:v1.20.2
  ```
  
### Kubernetes CA Certificate

To get the `CA certificates` for our cluster, easiest way is to access the `master node`.
Because we run on `kind`, our master node is a docker container.
The CA certificates exists in the /etc/kubernetes/pki folder by default.
If you are using `minikube` you may find it under ~/.minikube/.

Access the master node:

```s
docker exec -it rbac-control-plane bash

ls -l /etc/kubernetes/pki
total 60
-rw-r--r-- 1 root root 1135 Sep 10 01:38 apiserver-etcd-client.crt
-rw------- 1 root root 1675 Sep 10 01:38 apiserver-etcd-client.key
-rw-r--r-- 1 root root 1143 Sep 10 01:38 apiserver-kubelet-client.crt
-rw------- 1 root root 1679 Sep 10 01:38 apiserver-kubelet-client.key
-rw-r--r-- 1 root root 1306 Sep 10 01:38 apiserver.crt
-rw------- 1 root root 1675 Sep 10 01:38 apiserver.key
-rw-r--r-- 1 root root 1066 Sep 10 01:38 ca.crt
-rw------- 1 root root 1675 Sep 10 01:38 ca.key
drwxr-xr-x 2 root root 4096 Sep 10 01:38 etcd
-rw-r--r-- 1 root root 1078 Sep 10 01:38 front-proxy-ca.crt
-rw------- 1 root root 1679 Sep 10 01:38 front-proxy-ca.key
-rw-r--r-- 1 root root 1103 Sep 10 01:38 front-proxy-client.crt
-rw------- 1 root root 1675 Sep 10 01:38 front-proxy-client.key
-rw------- 1 root root 1679 Sep 10 01:38 sa.key
-rw------- 1 root root  451 Sep 10 01:38 sa.pub

exit the container
```

Copy the certs out of our master node:

```yaml
cd kubernetes/rbac
docker cp rbac-control-plane:/etc/kubernetes/pki/ca.crt ca.crt
docker cp rbac-control-plane:/etc/kubernetes/pki/ca.key ca.key
```

### User Certificates

First thing we need to do is create a certificate signed by our Kubernetes CA.
We have the CA, let's make a certificate.

Easy way to create a cert is use openssl and the easiest way to get openssl is to simply run a container:

> Usig kind

```
docker run -it -v ${PWD}:/work -w /work -v ${HOME}:/root/ --net host alpine sh

apk add openssl
```

Let's create a certificate for Mohan:

```yaml
#start with a private key
openssl genrsa -out mohan.key 2048
```

Now we have a `key`, we need a certificate signing request (CSR).

We also need to specify the groups that `mohan` belongs to.

Let's pretend Mohan is part of the `marketing` team and will be developing applications for the `marketing`.


```yaml
openssl req -new -key mohan.key -out mohan.csr -subj "/CN=mohan/O=Marketing"
```

Use the CA to generate our certificate by signing our CSR.
We may set an expiry on our certificate as well

```
openssl x509 -req -in mohan.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out mohan.crt -days 1
```

### Building a kube config

Let's install kubectl in our container to make things easier:

```s
apk add curl nano
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
```

We'll be trying to avoid messing with our current kubernetes config.
So lets tell kubectl to look at a new config that does not yet exists

```s
export KUBECONFIG=~/.kube/new-config
```

Create a cluster entry which points to the cluster and contains the details of the CA certificate:

```s
kubectl config set-cluster dev-cluster --server=https://134.183.96.27:52807 \
--certificate-authority=ca.crt \
--embed-certs=true

#see changes 
nano ~/.kube/new-config
```s
kubectl config set-credentials mohan --client-certificate=mohan.crt --client-key=mohan.key --embed-certs=true

kubectl config set-context dev --cluster=dev-cluster --namespace=marketing --user=mohan

kubectl config use-context dev

kubectl get pods Error from server (Forbidden): pods is forbidden: User "Mohan" cannot list resource "pods" in API group "" in the namespace "marketing"

### Give Mohan Access

```s
cd kubernetes/rbac
kubectl create ns shopping

kubectl -n shopping apply -f .\role.yaml
kubectl -n shopping apply -f .\rolebinding.yaml
```
Test Access as Mohan
kubectl get pods No resources found in shopping namespace.

Kubernetes Service Accounts
So we've covered users, but what about applications or services running in our cluster ?
Most business apps will not need to connect to the kubernetes API unless you are building something that integrates with your cluster, like a CI/CD tool, an autoscaler or a custom webhook.

Generally applications will use a service account to connect.
You can read more about [Kubernetes Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).

Let's deploy a service account

```s
kubectl -n shopping apply -f serviceaccount.yaml

```
Now we can deploy a pod that uses the service account

```s
kubectl -n shopping apply -f pod.yaml
```

Now we can test the access from within that pod by trying to list pods:

```s
kubectl -n marketing exec -it marketing-api -- bash

# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# List pods through the API
curl --cacert ${CACERT} --header "Authorization: Bearer $TOKEN" -s ${APISERVER}/api/v1/namespaces/marketing/pods/ 

# we should see an error not having access
```

Now we can allow this pod to list pods in the shopping namespace

```s
kubectl -n shopping apply -f serviceaccount-role.yaml
kubectl -n shopping apply -f serviceaccount-rolebinding.yaml
```

## ❤ Show your support

Give a ⭐️ if this project helped you, Happy learning!
