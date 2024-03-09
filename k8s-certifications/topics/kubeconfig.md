# Kubeconfig

<br />

NOTE : use the [kubeconfig.yaml](../data/kubeconfig.yaml) for the exercise

### View the config file

<br />

<details><summary>show</summary><p>

```bash
kubectl config view --kubeconfig kubeconfig.yaml
```

</p></details>

<br />

### Get the clusters from the kubeconfig file

<br />

<details><summary>show</summary><p>

```bash
kubectl config get-clusters --kubeconfig kubeconfig.yaml
# NAME
# development
# qa
# production
# kubernetes
# labs
```

</p></details>

<br />

### Get the users from the kubeconfig file

<br />

<details><summary>show</summary><p>

```bash
kubectl config get-users --kubeconfig kubeconfig.yaml # will not work for older versions
# NAME
# dev-user
# kubernetes-admin
# labs-user
# prod-user
# qa-user
```

</p></details>

<br />

### Get the contexts from the kubeconfig file

<br />

<details><summary>show</summary><p>

```bash
kubectl config get-contexts --kubeconfig kubeconfig.yaml
# CURRENT   NAME                          CLUSTER       AUTHINFO           NAMESPACE
#           development-user@labs         development   development-user   
# *         kubernetes-admin@kubernetes   kubernetes    kubernetes-admin   
#           labs-user@labs                labs          labs-user          
#           prod-user@prod                prod          prod-user          
#           qa-user@qa                    qa            qa-user
```

</p></details>

<br />

### Get the current context

<br />

<details><summary>show</summary><p>

```bash
kubectl config current-context --kubeconfig kubeconfig.yaml
# kubernetes-admin@kubernetes
```

</p></details>

<br />

### Switch to context `prod-user@prod` as the current context

<br />

<details><summary>show</summary><p>

```bash
kubectl config use-context prod-user@prod  --kubeconfig kubeconfig.yaml
# Switched to context "prod-user@prod".
kubectl config current-context --kubeconfig kubeconfig.yaml
# prod-user@prod
```

</p></details>