# Role-Based Access Control

Kubernetes supports fine-grained access control, so you can decide who has permission to work with resources in your cluster, and what they can do with them.

There are two parts to [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), decoupling permissions and who has the permissions - that lets you model security with a managable number of objects:

- Roles define access permissions for resources (like Pods and Secrets), allowing specific actions (like create and delete)
- RoleBindings grant the permissions in a Role to a subject, which could be a Kubectl user or an app running in a Pod.

Roles and RoleBindings apply to objects in a specific namespace; there are also ClusterRole and ClusterRoleBindings which have a similar API and secure access to objects across all namespaces.

## API specs

- [Role](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#role-v1-rbac-authorization-k8s-io)
- [RoleBinding](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#rolebinding-v1-rbac-authorization-k8s-io)
- [ClusterRole](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#clusterrole-v1-rbac-authorization-k8s-io)
- [ClusterRoleBinding](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#clusterrolebinding-v1-rbac-authorization-k8s-io)

<details>
  <summary>YAML overview</summary>

## Role and RoleBinding API spec

Roles contain a set of permissions as **rules**:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-viewer
  namespace: default 
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Each rule secures access to one or more types of resource. For each rule:

- `apiGroups` - the namespace of the resource, which you use in the `apiVersion` in object metadata; Pods are just `v1` so the apiGroup is blank, Deployments are `apps/v1` so the apiGroup would be `apps`
- `resources` - the type of the resource, which you use as the `kind` in object metadata
- `verbs` - the actions the role allows to be performed on the resource

This role equates to Kubectl `get pods` and `describe pod` permissions in the `default` namespace.

RoleBindings apply a role to a set of **subjects**:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: student-pod-viewer
  namespace: default 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-viewer
subjects:
- kind: User
  name: student@courselabs.co
  namespace: default
```

- `namespace` needs to match the namespace in the Role
- `roleRef` refers to the Role by name
- `subjects` are the Users, Groups or ServiceAccounts having the role applied - they can be in different namespaces

</details><br/>

___

## * **Do this first if you use Docker Desktop** *

There's a [bug in the default RBAC setup](https://github.com/docker/for-mac/issues/4774) in older versions of Docker Desktop, which means permissions are not applied correctly. If you're using Kubernetes in Docker Desktop v4.2 or earlier, run this to fix the bug:

```
# on Docker Desktop for Mac (or WSL2 on Windows):
sudo chmod +x ./scripts/fix-rbac-docker-desktop.sh
./scripts/fix-rbac-docker-desktop.sh

# OR on Docker Desktop for Windows (PowerShell):
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
./scripts/fix-rbac-docker-desktop.ps1
```

> Docker Desktop 4.3.0 fixes the issue,so if you run the command and you see _Error from server (NotFound): clusterrolebindings.rbac.authorization.k8s.io "docker-for-desktop-binding" not found_ - that means your version doesn't have the bug and you're good to go. 
___

## Securing API access with Service Accounts

Authentication for end-user access is manged outside of Kubernetes, so we'll use RBAC for internal access to the cluster - apps running in Kubernetes.

We'll use a simple web app which connects to the Kubernetes API server to get a list of Pods, it displays them and lets you delete them.

Create a sleep Deployment so we'll have a Pod to see in the app:

```
kubectl apply -f labs/rbac/specs/sleep.yaml
```

The initial spec for the web app doesn't include any RBAC rules, but it does include a specific security account for the Pod:

- [kube-explorer/deployment.yaml](specs/kube-explorer/deployment.yaml) - creates a ServiceAccount and sets the Pod spec to use that ServiceAccount

📋 Deploy the resources in `labs/rbac/specs/kube-explorer`.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/rbac/specs/kube-explorer
```

</details><br />

> Browse to the app at http://localhost:8010 or http://localhost:30010

You'll see an error. The app is trying to connect to the Kubernetes REST API to get a list of Pods, but it's getting a 403 Forbidden error message.

Kubernetes automatically populates an authentication token in the Pod, which the app uses to connect to the API server:

📋 Print all the details about the kube-explorer Pod.

<details>
  <summary>Not sure how?</summary>

```
# you can get the Pod ID or use the label
kubectl describe pod -l app=kube-explorer
```

</details><br />

> You'll see a volume mounted at `/var/run/secrets/kubernetes.io/serviceaccount` - that's not in the Pod spec, it's a Kubernetes default to add it

```
kubectl exec deploy/kube-explorer -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

> That's the authentication token for the Service Account, so Kubernetes knows the identity of the API user

So the app is **authenticated** and it's allowed to use the API, but the account is not **authorized** to list Pods. Security principals - ServiceAccounts, Groups and Users - start off with no permissions and need to be granted acces to resources.

You can check the permissions of a user with the `auth can-i` command:

```
kubectl auth can-i get pods -n default --as system:serviceaccount:default:kube-explorer
```

> This command works for users and ServiceAccounts - the ServiceAccount ID includes the namespace and name

RBAC rules are applied when a request is made to the API server, so we can fix this app by deploying a Role and RoleBinding:

- [rbac-namespace/role-pod-manager.yaml](specs/kube-explorer/rbac-namespace/role-pod-manager.yaml) - creates a Role with permissions to list and delete Pods in the default namespace
- [rbac-namespace/rolebinding-pod-manager-sa.yaml](specs/kube-explorer/rbac-namespace/rolebinding-pod-manager-sa.yaml) - creates a RoleBinding applying the new Role to the app's Service Account

📋 Deploy the rules in `labs/rbac/specs/kube-explorer/rbac-namespace` and verify the Service Account now has permission.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/rbac/specs/kube-explorer/rbac-namespace

kubectl auth can-i get pods -n default --as system:serviceaccount:default:kube-explorer
```

</details><br />

Now the app has the permissions it needs. Refresh the site and you'll see a Pod list. You can delete the sleep Pod, then go back to the main page and you'll see a replacement Pod created by the ReplicaSet.

## Granting cluster-wide permissions

The role binding restricts access to the default namespace, the same ServiceAccount can't see Pods in the system namespace:

📋 Check if the `kube-explorer` account can get Pods in the `kube-system` namespace.

<details>
  <summary>Not sure how?</summary>

```
kubectl auth can-i get pods -n kube-system --as system:serviceaccount:default:kube-explorer
```
</details><br />

You can grant access to Pods in each namespace with more Roles and RoleBindings, but if you want permissions to apply across all namespaces you can use a ClusterRole and ClusterRoleBinding:

- [rbac-cluster/clusterrole-pod-reader.yaml](specs/kube-explorer/rbac-cluster/clusterrole-pod-reader.yaml) - sets Pod permissions for the cluster; note there is no namespace in the metadata
- [rbac-cluster/clusterrolebinding-pod-reader-sa.yaml](specs/kube-explorer/rbac-cluster/clusterrolebinding-pod-reader-sa.yaml) - applies the role to the app's ServiceAccount

📋 Deploy the cluster rules in `labs/rbac/specs/kube-explorer/rbac-cluster` and verify the SA can get Pods in the system namespace, but it can't delete them.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/rbac/specs/kube-explorer/rbac-cluster/

kubectl auth can-i get pods -n kube-system --as system:serviceaccount:default:kube-explorer

kubectl auth can-i delete pods -n kube-system --as system:serviceaccount:default:kube-explorer
```

</details><br />

> Browse to the app with a namespace in the querystring, e.g. http://localhost:8010/?ns=kube-system or http://localhost:30010/?ns=kube-system

The app can see Pods in other namespaces now.

RBAC permissions are finely controlled. The app only has access to Pod resources - if you click the _Service Accounts_ link the app shows the 403 Forbidden error again.

## Lab

You need to be familiar with RBAC. You'll certainly have restricted permissions in production clusters, and if you need new access you'll get it more quickly if you give the admin a Role and RoleBinding for what you need.

Get some practice by deploying new RBAC rules so the ServiceAccount view in the kube-explorer app works correctly, for objects in the default namespace.

Oh - one more thing :) Mounting the ServiceAccount token in the Pod is  default behaviour but most app don't use the Kubernetes API server. It's a potential security issue so can you amend the sleep Pod so it doesn't have a token mounted.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## **EXTRA** Managing end-user permissions

<details>
  <summary>RBAC for Kubectl users</summary>

Kubernetes integrates with other systems for end-user authentication, but in a dev setup you can create certificates for users and apply RBAC rules for them. This isn't day-to-day work, but if you're interested you can work through the exercises in [RBAC for Users](rbac-for-users.md).

</details><br />

___

## **EXTRA** Applying ClusterRoles to specific namespaces

<details>
  <summary>Using the standard Kubernetes roles</summary>

There are built-in ClusterRoles which give a good starting point for general access - including `view`, `edit` and `admin`.

ClusterRoles can be bound to subjects cluster-wide with a ClusterRoleBinding **or** to specific namespaces with a RoleBinding:

- [rolebinding-edit-default.yaml](specs/user/rolebinding-edit-default.yaml) - applies the `edit` ClusterRole to the new user, restricted to the `default` namespace

```
kubectl apply -f labs/rbac/specs/user/

kubectl auth can-i delete po/user-cert-generator --as reader@courselabs.co

kubectl delete pod user-cert-generator --context labreader
```
The user can now delete Pods in the default namespace. If there were other users in the same group then they wouldn't have this permission - it's specifically bound to the user.

But the ClusterRole is limited to the `default` namespace:

```
kubectl delete pod --all -n kube-system --context labreader
```

</details><br />

___

## Cleanup

```
kubectl delete pod,deploy,svc,serviceaccount,role,rolebinding,clusterrole,clusterrolebinding -A -l kubernetes.courselabs.co=rbac
```