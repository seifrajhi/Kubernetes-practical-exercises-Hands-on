# [RBAC authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

- Role and Role bindings are namespace scoped for e.g. pods, deployments, configmaps, etc.
- Cluster Role and Cluster Role bindings are cluster scoped resources and not limited to namespaces for e.g. nodes, pv, etc.

## Table of Contents
1. [Role and Role Bindings](#role-and-role-bindings)
2. [Cluster Role and Cluster Role Bindings](#cluster-role-and-cluster-role-bindings)

<br />

### Check the current authorization used by the cluster 

<details><summary>show</summary><p>

Check the `/etc/kubernetes/manifests/kube-apiserver.yaml` for the `--authorization-mode=Node,RBAC` 

</p></details> 

<br />

## Role and Role Bindings

<br />

### Create the role `pods-read` to `get, create, list and delete` `pods` in the default namespace.

<details><summary>show</summary><p>

```bash
kubectl create role pods-read --verb=get,create,list,delete --resource=pods
```

OR 

```yaml
cat << EOF > pods-read.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pods-read
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - create
  - list
  - delete
EOF

kubectl apply -f pods-read.yaml
```

```bash
# verify
kubectl get role pods-read
# NAME        CREATED AT
# pods-read   2021-12-13T01:35:10Z
```

</p></details> 

<br />

### Create a service account `sample-sa`

<details><summary>show</summary><p>

```bash
kubectl create sa sample-sa
```

OR

```yaml
cat << EOF > sample-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: null
  name: sample-sa
EOF

kubectl apply -f sample-sa.yaml
```

```bash
# verify
kubectl get serviceaccount sample-sa
# NAME        SECRETS   AGE
# sample-sa   1         14s
```

</p></details> 

<br />

### Create a role binding `sample-sa-pods-read-role-binding` binding service account `sample-sa` and role `pods-read`

<details><summary>show</summary><p>

```bash
kubectl create rolebinding sample-sa-pods-read-role-binding --serviceaccount=default:sample-sa --role=pods-read
```

OR 

```yaml
cat << EOF > sample-sa-pods-read-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: sample-sa-pods-read-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pods-read
subjects:
- kind: ServiceAccount
  name: sample-sa
  namespace: default
EOF

kubectl apply -f sample-sa-pods-read-role-binding.yaml
```

```bash
# verify
kubectl get rolebinding sample-sa-pods-read-role-binding
# NAME                               ROLE             AGE
# sample-sa-pods-read-role-binding   Role/pods-read   18s
```

</p></details>

<br />

### Verify service account `sample-sa` can get pods using the `auth can-i` command.

<details><summary>show</summary><p>

```bash
# verify
kubectl auth can-i get pods --as system:serviceaccount:default:sample-sa
# yes
```
</p></details>

<br />

## Cluster Role and Cluster Role Bindings

<br />

### Create the following for a user `proxy-admin` (which does not exist)
 - Cluster role `proxy-admin-role` with permissions to `nodes` with `get, list,create, update` actions
 - Cluster role binding `proxy-admin-role-binding` to bind cluster role `proxy-admin-role` to user `proxy-admin`

<br />

<details><summary>show</summary><p>

```bash
kubectl create clusterrole proxy-admin-role --resource=nodes --verb=get,list,create,update
kubectl create clusterrolebinding proxy-admin-role-binding --user=proxy-admin --clusterrole=proxy-admin-role
```

```bash
# verify
kubectl auth can-i get nodes --as proxy-admin
# yes
```

</p></details>

<br />

### Create the following - PENDING
 - Create a new role named `deployent-role` which only allows to `create` the following resource types in the `finance` namespace.
 - Deployment
 - StatefuleSet
 - DaemonSet
- Create a new Service Account named `cicd-token` in the existing namespace `finance`
- Bind the new Role `deployment-role` to the new serviceaccount `cicd-token` using Role binding `deployent-role-binding` limited to the namespace `finance`

<br />

<details><summary>show</summary><p>

```bash
kubectl create serviceaccount cicd-token -n finance
kubectl create role deployent-role --resource=nodes --verb=get,list,create,update -n finance
kubectl create rolebinding deployent-role-binding --serviceaccount=finance/cicd-token  --role=deployent-role -n finance
```

```bash
# verify
kubectl auth can-i get nodes --as proxy-admin
# yes
```

</p></details>

<br />

## Clean up 

<br />

```bash
rm sample-sa-pods-read-role-binding.yaml pods-read.yaml
kubectl delete rolebinding sample-sa-pods-read-role-binding
kubectl delete serviceaccount sample-sa
kubectl delete role pods-read
kubectl delete clusterrolebinding proxy-admin-role-binding
kubectl delete clusterole proxy-admin-role
```