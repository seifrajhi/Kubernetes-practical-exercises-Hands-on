# RBAC for Users

Kubernetes manages authorization with roles and bindings but it does not have an authentication system. It expects clients (e.g. Kubectl users) to be authenticated by a trusted system, and then it uses the authenticated identity to apply role permissions.

## Creating a new end-user

Production Kubernetes systems integrate with third-party identity providers - Azure AD for AKS, OpenID Connect and LDAP are other options. For a dev cluster you can use Kubernetes to create a client certificate which users can authenticate with.

The steps for that are wrapped up in the user-cert-generator app:

- [01_service-account.yaml](specs/user-cert-generator/01_service-account.yaml)  - ServiceAccount for the app, needs to be created before clusterrolebinding
- [02_rbac.yaml](specs/user-cert-generator/02_rbac.yaml) - roles and bindings so the app can request a cert from Kubernetes 
- [03_pod.yaml](specs/user-cert-generator/03_pod.yaml) - the application Pod

> ℹ If you're interested in how the cert is created, it's all in this [shell script](https://github.com/sixeyed/kiamol/blob/master/ch17/docker-images/user-cert-generator/start.sh)

📋 Run the app to create a client certificate, and check the logs once it has completed.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/rbac/specs/user-cert-generator/

kubectl wait --for=condition=Ready pod user-cert-generator

kubectl logs user-cert-generator
```

</details><br />

The new user's certificate and key are in the Pod container's filesystem. You can copy them out to your local machine:

```
kubectl cp user-cert-generator:/certs/user.key user.key
kubectl cp user-cert-generator:/certs/user.crt user.crt
```

Create a new context for Kubectl to use the new user's certificate:

```
# save the cert in Kubeconfig to authenticate the user:
kubectl config set-credentials labreader --client-key=./user.key --client-certificate=./user.crt --embed-certs=true

# set the cluster for the new context to the same as the current context:
kubectl config set-context labreader --user=labreader --cluster $(kubectl config view --minify -o jsonpath='{.clusters[0].name}')

# check your new context:
kubectl config get-contexts
```

You can use the new user directly with your context, and you'll see they're authenticated but they have no permissions:

```
kubectl apply -f labs/rbac/specs/sleep.yaml --context labreader

kubectl get pods --as reader@courselabs.co
```


## Granting end-user and group permissions

Just like Service Accounts, new client users start with zero permissions.

You apply permissions in the same way, with RoleBindings and ClusterRoleBindings. The subject of the binding can either be the name of the user, or the group they belong to.

Different authentication systems represent that in different ways; the certificate we're using includes the user name and group:

```
openssl x509 -in user.crt -noout -subject

# if you don't have OpenSSL installed, this is what you would have seen:
# subject=C = UK, ST = LONDON, L = London, O = courselabs, CN = reader@courselabs.co
```

- CN is the Common Name - in Kubernetes that's the user name
- O is the Organization - Kubernetes uses it as the group name

We can create a group permission, so all courselabs users can list Pods, show Pod details and print logs:

- [group/clusterrole-podviewer.yaml](specs/group/clusterrole-podviewer.yaml) - role with Pod and log permissions
- [group/clusterrolebinding-podviewer-courselabs.yaml](specs/group/clusterrolebinding-podviewer-courselabs.yaml) - binding for the role to the group

📋 Apply the new group rules and check the reader user can get Pod details and logs, but can't delete Pods or work with Secrets.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/rbac/specs/group

kubectl get pods --context labreader

kubectl get pods -n kube-system --context labreader
```

The new permissions also allow the reader to get Pod details and print logs, but that's all:

```
kubectl describe pods -l app=sleep --context labreader

kubectl logs user-cert-generator --tail=3 --context labreader

kubectl delete pod user-cert-generator --context labreader

kubectl get secrets --context labreader
```

</details><br />

___

## Cleanup

```
kubectl delete pod,deploy,svc,serviceaccount,role,rolebinding,clusterrole,clusterrolebinding -A -l kubernetes.courselabs.co=rbac
```