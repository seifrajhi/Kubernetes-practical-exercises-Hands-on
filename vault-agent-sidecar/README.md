# Vault Agent Injector Example

## Prerequisites

This guide requires the [Kubernetes command-line interface
(CLI)](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and the [Helm
CLI](https://helm.sh/docs/helm/) installed,
[Minikube](https://minikube.sigs.k8s.io), and additional configuration to bring
it all together.

This guide was last tested 24 Mar 2020 on a macOS 10.15.3 using this configuration.
configuration:

```shell
$ docker version
Client: Docker Engine - Community
 Version:           19.03.8
 ...

$ minikube version
minikube version: v1.8.2
commit: eb13446e786c9ef70cb0a9f85a633194e62396a1

$ helm version
version.BuildInfo{Version:"v3.1.2", GitCommit:"d878d4d45863e42fd5cff6743294a11d28a9abce", GitTreeState:"clean", GoVersion:"go1.14"}
```

Although we recommend these software versions, the output you see may
vary depending on your environment and the software versions you use.

First, follow the directions for [installing
Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/), including
VirtualBox or similar.

Next, install [kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
and [helm CLI](https://github.com/helm/helm#install).

On Mac with [Homebrew](https://brew.sh).

```shell
$ brew install kubernetes-cli
$ brew install helm
```

On Windows with [Chocolatey](https://chocolatey.org/):

```shell
$ choco install kubernetes-cli
$ choco install kubernetes-hel
```

If you want to use the newest version of the files from Github.
Cloning the [hashicorp/vault-guides](https://github.com/hashicorp/vault-guides) repository from GitHub.
But we take no responsibility that there this course is broken. We suggest to go with files of these repo.

```shell
$ git clone https://github.com/hashicorp/vault-guides.git
```

This repository contains supporting content for all of the Vault learn guides.
The content specific to this guide can be found within a sub-directory.

Go into the
`vault-guides/operations/provision-vault/kubernetes/minikube/vault-agent-sidecar`
directory.

```shell
$ cd vault-guides/operations/provision-vault/kubernetes/minikube/vault-agent-sidecar
```

~> **Working directory:** This guide assumes that the remainder of commands are
executed within this directory.

## Start Minikube

Start a Kubernetes cluster with 4096 Megabytes (MB) of memory:

```shell
$ minikube start --memory 4096
😄  minikube v1.5.2 on Darwin 10.15.2
✨  Automatically selected the 'hyperkit' driver (alternates: [virtualbox])
🔥  Creating hyperkit VM (CPUs=2, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.16.2 on Docker '18.09.9' ...
🚜  Pulling images ...
🚀  Launching Kubernetes ...
⌛  Waiting for: apiserver
🏄  Done! kubectl is now configured to use "minikube"
```

Verify the status of the Minikube cluster:

```shell
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

In **another terminal**, launch the minikube dashboard:

```shell
$ minikube dashboard
```

## Initialize Helm

Initialize [Helm](https://helm.sh/docs/helm/) and start Tiller:

```shell
$ helm init
$HELM_HOME has been configured at $HOME/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
```

Verify that Tiller is running by getting all the pods within the `kube-system`
namespace:

```shell
$ kubectl get pods --namespace kube-system
NAME                                    READY   STATUS    RESTARTS   AGE
coredns-5c98db65d4-s8cdv                1/1     Running   1          7m17s
coredns-5c98db65d4-vh5tw                1/1     Running   1          7m17s
etcd-minikube                           1/1     Running   0          6m20s
kube-addon-manager-minikube             1/1     Running   0          6m19s
kube-apiserver-minikube                 1/1     Running   0          6m12s
kube-controller-manager-minikube        1/1     Running   0          6m9s
kube-proxy-llgmm                        1/1     Running   0          7m17s
kube-scheduler-minikube                 1/1     Running   0          6m12s
kubernetes-dashboard-7b8ddcb5d6-7gs2l   1/1     Running   0          7m16s
storage-provisioner                     1/1     Running   0          7m16s
tiller-deploy-75f6c87b87-n4db8          1/1     Running   0          21s
```


## Install the Vault Helm chart

Install the Vault Helm chart version 0.5.0 with pods prefixed with the name `vault`:

```shell
$ helm install --name vault \
    --set "server.dev.enabled=true" \
    https://github.com/hashicorp/vault-helm/archive/v0.5.0.tar.gz
NAME:   vault
LAST DEPLOYED: Fri Dec 20 11:56:33 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:

...

NOTES:

...

Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get vault

```

To verify, get all the pods within the `default` namespace:

```shell
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          80s
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          80s
```

The Helm chart creates a Vault server pod and Vault-Agent injector pod.

The vault-0 pod starts as a Vault service in development mode. The vault-agent-injector pod performs the injection based on the annotations present or patched on a deployment.

~> **Development mode**: Running a Vault server in development is automatically initialized and unsealed. This is ideal in a learning environment but NOT recommended for a production environment.

## Set a secret in Vault

The applications that you deploy in the Inject secrets into the pod section expect Vault to store a username and password stored at the path internal/database/config. To create this secret requires that a key-value secret engine is enabled and a username and password is put at the specified path.

Start an interactive shell session on the `vault-0` pod:

```shell
$ kubectl exec -it vault-0 /bin/sh
/ $
```

Your system prompt is replaced with a new prompt `/ $`. Commands issued at this
prompt are executed on the `vault-0` container.

Enable kv-v2 secrets at the path `internal`:

```shell
/ $ vault secrets enable -path=internal kv-v2
Success! Enabled the kv-v2 secrets engine at: internal/
```

~> **Learn more**: This guide focuses on Vault's integration with Kubernetes and not interacting the key-value secrets engine. For more information refer to the [Static Secrets: Key/Value Secret](https://learn.hashicorp.com/vault/developer/sm-static-secrets) guide.

Create a secret at path secret/webapp/config with a username and password:

```shell
$ vault kv put internal/database/config username="db-readonly-username" password="db-secret-password"
Key              Value
---              -----
created_time     2019-12-20T18:17:01.719862753Z
deletion_time    n/a
destroyed        false
version          1
```

Verify that the secret is defined at the path `internal/database/config`:

```shell
$ vault kv get internal/database/config
====== Metadata ======
Key              Value
---              -----
created_time     2019-12-20T18:17:50.930264759Z
deletion_time    n/a
destroyed        false
version          1

====== Data ======
Key         Value
---         -----
password    db-secret-password
username    db-readonly-username
```

Lastly, exit the vault-0 pod.

```shell
$ exit
```

## Configure Kubernetes authentication

Vault provides a Kubernetes authentication method that enables clients to authenticate with a Kubernetes Service Account Token. This token is provided to each pod when it is created.

Start an interactive shell session on the vault-0 pod.

```shell
$ kubectl exec -it vault-0 /bin/sh
/ $
```

Your system prompt is replaced with a new prompt / $. Commands issued at this prompt are executed on the vault-0 container.

Enable the Kubernetes authentication method:

```shell
/ $ vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/
```

Vault accepts this service token from any client within the Kubernetes cluster. During authentication, Vault verifies that the service account token is valid by querying a configured Kubernetes endpoint.

Configure the Kubernetes authentication method to use the service account
token, the location of the Kubernetes host, and its certificate:

```shell
/ $ vault write auth/kubernetes/config \
        token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
Success! Data written to: auth/kubernetes/config
```

The token_reviewer_jwt and kubernetes_ca_cert are mounted to the container by Kubernetes when it is created. The environment variable KUBERNETES_PORT_443_TCP_ADDR is defined and references the internal network address of the Kubernetes host.

For a client to read the secret data defined at internal/database/config, requires that the read capability be granted for the path internal/data/database/config. This is an example of a policy. A policy defines a set of capabilities.

Write out the policy named internal-app that enables the read capability for secrets at path internal/data/database/config.

```shell
/ $ vault policy write internal-app - <<EOH
path "internal/data/database/config" {
  capabilities = ["read"]
}
EOH
Success! Uploaded policy: internal-app
```

Create a Kubernetes authentication role named `internal-app`:

```shell
/ $ vault write auth/kubernetes/role/internal-app \
        bound_service_account_names=internal-app \
        bound_service_account_namespaces=default \
        policies=internal-app \
        ttl=24h
Success! Data written to: auth/kubernetes/role/internal-app
```

The role connects the Kubernetes service account, internal-app, and namespace, default, with the Vault policy, internal-app. The tokens returned after authentication are valid for 24 hours.

Lastly, exit the the `vault-0` pod:

```shell
/ $ exit
$
```

## Define a Kubernetes service account

The Vault Kubernetes authentication role defined a Kubernetes service account
named `internal-app`. This service acount does not yet exist.

Verify that the Kubernetes service account named `internal-app` does not exist:

```shell
$ kubectl get serviceaccounts
NAME                   SECRETS   AGE
default                1         43m
vault                  1         34m
vault-agent-injector   1         34m
```

This account does not exist but it is necessary for authentication.

View the service account defined in `service-account-internal-app.yml`:

```shell
$ cat service-account-internal-app.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: internal-app
```

This definition of the service account creates the account with the name internal-app.

Apply the service account definition to create it:

```shell
$ kubectl apply --filename service-account-internal-app.yml
serviceaccount/internal-app created
```

Verify that the service account has been created:

```shell
$ kubectl get serviceaccounts
NAME                   SECRETS   AGE
default                1         52m
internal-app           1         13s
vault                  1         43m
vault-agent-injector   1         43m
```

The name of the service account here aligns with the name assigned to the
`bound_service_account_names` field when creating the `internal-app` role
when configuring the Kubernetes authentication.

## Launch an application

We've created a sample application, published it to DockerHub, and created a Kubernetes deployment that launches this application.

View the deployment for the `orgchart` application:

```shell
$ cat deployment-orgchart.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orgchart
  labels:
    app: vault-agent-injector-demo
spec:
  selector:
    matchLabels:
      app: vault-agent-injector-demo
  replicas: 1
  template:
    metadata:
      annotations:
      labels:
        app: vault-agent-injector-demo
    spec:
      serviceAccountName: internal-app
      containers:
        - name: orgchart
          image: jweissig/app:0.0.1
```

The name of this deployment is orgchart. The spec.template.spec.serviceAccountName defines the service account internal-app to run this container.

Apply the deployment defined in `deployment-orgchart.yml`:

```shell
$ kubectl apply --filename deployment-orgchart.yml
deployment.apps/orgchart created
```

The application runs as a pod within the `default` namespace.

Get all the pods within the `default` namespace:

```shell
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
orgchart-69697d9598-l878s               1/1     Running   0          18s
vault-0                                 1/1     Running   0          58m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          58m
```

The orgchart deployment appears here as the pod named
`orgchart-69697d9598-l878s`.

The Vault-Agent injector looks for deployments that define specific annotations. None of these annotations exist within the current deployment. This means that no secrets are present on the orgchart container within the orgchart pod.

Verify that no secrets are written to the `orgchart` container in the
`orgchart-69697d9598-l878s` pod:

```shell
$ kubectl exec orgchart-69697d9598-l878s --container orgchart -- ls /vault/secrets
ls: /vault/secrets: No such file or directory
command terminated with exit code 1
```

## Inject secrets into the pod

View the deployment patch `patch-inject-secrets.yml`:

```shell
$ cat patch-inject-secrets.yml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "internal-app"
        vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
```

Patch the `orgchart` deployment defined in `patch-inject-secrets.yml`:

```shell
$ kubectl patch deployment orgchart --patch "$(cat patch-inject-secrets.yml)"
deployment.apps/orgchart patched
```

The original orgchart pod is terminated and a new orgchart pod is created.

Get all the pods within the `default` namespace:

```shell
$ kubectl get pods
NAME                                    READY   STATUS     RESTARTS   AGE
orgchart-599cb74d9c-s8hhm               0/2     Init:0/1   0          23s
orgchart-69697d9598-l878s               1/1     Running    0          20m
vault-0                                 1/1     Running    0          78m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running    0          78m
```

A new orgchart pod starts alongside the existing pod. When it is ready the original terminates and removes itself from the list of active pods. The redeployment is complete when the pod reports READY 2/2.

This new pod now launches two containers. The application container, named orgchart, and the Vault Agent container, named vault-agent.

View the logs of the vault-agent container in the new orgchart pod.

```shell
$ kubectl logs orgchart-599cb74d9c-s8hhm --container vault-agent
==> Vault server started! Log data will stream in below:

==> Vault agent configuration:

                     Cgo: disabled
               Log Level: info
                 Version: Vault v1.3.1

2019-12-20T19:52:36.658Z [INFO]  sink.file: creating file sink
2019-12-20T19:52:36.659Z [INFO]  sink.file: file sink configured: path=/home/vault/.token mode=-rw-r-----
2019-12-20T19:52:36.659Z [INFO]  template.server: starting template server
2019/12/20 19:52:36.659812 [INFO] (runner) creating new runner (dry: false, once: false)
2019/12/20 19:52:36.660237 [INFO] (runner) creating watcher
2019-12-20T19:52:36.660Z [INFO]  auth.handler: starting auth handler
2019-12-20T19:52:36.660Z [INFO]  auth.handler: authenticating
2019-12-20T19:52:36.660Z [INFO]  sink.server: starting sink server
2019-12-20T19:52:36.679Z [INFO]  auth.handler: authentication successful, sending token to sinks
2019-12-20T19:52:36.680Z [INFO]  auth.handler: starting renewal process
2019-12-20T19:52:36.681Z [INFO]  sink.file: token written: path=/home/vault/.token
2019-12-20T19:52:36.681Z [INFO]  template.server: template server received new token
2019/12/20 19:52:36.681133 [INFO] (runner) stopping
2019/12/20 19:52:36.681160 [INFO] (runner) creating new runner (dry: false, once: false)
2019/12/20 19:52:36.681285 [INFO] (runner) creating watcher
2019/12/20 19:52:36.681342 [INFO] (runner) starting
2019-12-20T19:52:36.692Z [INFO]  auth.handler: renewed auth token
```

Vault Agent manages the token lifecycle and the secret retrieval. The secret is
rendered in the `orgchart` container at the path
`/vault/secrets/database-config.txt`.

Finally, view the secret written to the `orgchart` container:

```shell
$ kubectl exec orgchart-599cb74d9c-s8hhm --container orgchart -- cat /vault/secrets/database-config.txt
data: map[password:db-secret-password username:db-readonly-user]
metadata: map[created_time:2019-12-20T18:17:50.930264759Z deletion_time: destroyed:false version:2]
```

The secret is present on the container. However, the structure is not in one
expected by the application.

## Apply a template to the injected secrets

The structure of the injected secrets may need to be structured in a way for an application to use. Before writing the secrets to the file system a template can structure the data. To apply this template a new set of annotations need to be applied.

View the annotations file that contains a template definition.

```shell
$ cat patch-inject-secrets-as-template.yml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-status: "update"
        vault.hashicorp.com/role: "internal-app"
        vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
        vault.hashicorp.com/agent-inject-template-database-config.txt: |
          {{- with secret "internal/data/database/config" -}}
          postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/wizard
          {{- end -}}
```

This patch contains two new annotations:

* agent-inject-status set to update informs the injector reinject these values.
* agent-inject-template-FILEPATH prefixes the file path. The value defines the Vault Agent template to apply to the secret's data.

The template formats the username and password as a PostgreSQL connection string.

Apply the updated annotations.

```shell
$ kubectl patch deployment orgchart --patch "$(cat patch-inject-secrets-as-template.yml)"
deployment.apps/exampleapp patched
```

Get all the pods within the `default` namespace:

```shell
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
orgchart-554db4579d-w6565               2/2     Running   0          16s
vault-0                                 1/1     Running   0          126m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          126m
```

Finally, display the secret written to the orgchart container in the orgchart pod.

```shell
$ kubectl exec \
    $(kubectl get pod -l app=orgchart -o jsonpath="{.items[0].metadata.name}") \
    -c orgchart -- cat /vault/secrets/database-config.txt
postgresql://db-readonly-user:db-secret-password@postgres:5432/wizard
```

The PostgreSQL connection string is present on the container.

## Pod with annotations

The annotations may patch these secrets into any deployment. Pods require that the annotations be included in their intitial definition.

View the deployment for the `payrole` application:

```shell
$ cat pod-payroll.yml
apiVersion: v1
kind: Pod
metadata:
  name: payroll
  labels:
    app: payroll
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "internal-app"
    vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
    vault.hashicorp.com/agent-inject-template-database-config.txt: |
      {{- with secret "internal/data/database/config" -}}
      postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/wizard
      {{- end -}}
spec:
  serviceAccountName: internal-app
  containers:
    - name: payroll
      image: jweissig/app:0.0.1
```

Apply the pod defined in `pod-payroll.yml`:

```shell
$ kubectl apply --filename pod-payroll.yml
pod/payroll created
```

Get all the pods within the `default` namespace:

```shell
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
orgchart-554db4579d-w6565               2/2     Running   0          29m
payrole-7dc758dc7b-9dc6t                2/2     Running   0          12s
vault-0                                 1/1     Running   0          155m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running   0          155m
```

Finally, display the secret written to the payroll container in the payroll pod.

```shell
kubectl exec \
    payroll \
    --container payroll -- cat /vault/secrets/database-config.txt
postgresql://db-readonly-user:db-secret-password@postgres:5432/wizard
```

The PostgreSQL connection string is present on the payroll container.

## Secrets are bound to the service account

Pods run with a Kubernetes service account other than the ones defined in the Vault Kubernetes authentication role are not able to access the secrets defined at that path.

View the deployment and service account for the website application.

```shell
 cat deployment-website.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: website
  labels:
    app: website
spec:
  selector:
    matchLabels:
      app: website
  replicas: 1
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "internal-app"
        vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
        vault.hashicorp.com/agent-inject-template-database-config.txt: |
          {{- with secret "internal/data/database/config" -}}
          postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/wizard
          {{- end -}}
      labels:
        app: website
    spec:
      # This service account does not have permission to request the secrets.
      serviceAccountName: website
      containers:
        - name: website
          image: jweissig/app:0.0.1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: website

```

Apply the deployment and service account defined in `deployment-website.yml`.

```shell
$ kubectl apply --filename deployment-website.yml
deployment.apps/website created
serviceaccount/website created
```

Get all the pods within the `default` namespace:

```shell
$ kubectl get pods
NAME                                    READY   STATUS     RESTARTS   AGE
orgchart-554db4579d-w6565               2/2     Running    0          29m
payroll                                 2/2     Running    0          12s
vault-0                                 1/1     Running    0          155m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running    0          155m
website-7fc8b69645-527rf                0/2     Init:0/1   0          76s
```

The website deployment creates a pod but it never is ready.

View the logs of the `vault-agent-init` container in the
`website-7fc8b69645-527rf` pod:

```shell
$ kubectl logs website-7fc8b69645-527rf --container vault-agent-init
...
2019-12-20T21:36:32.825Z [INFO]  auth.handler: authenticating
2019-12-20T21:36:32.830Z [ERROR] auth.handler: error authenticating: error="Error making API request.

URL: PUT http://vault.default.svc:8200/v1/auth/kubernetes/login
Code: 500. Errors:

* service account name not authorized" backoff=1.562132589
```

The initialization process is failing because the service account name is not
authorized. The service account, `external-app` is not assigned to any Vault
Kubernetes authentication role preventing the initialization to complete.

View the deployment patch patch-website.yml.

```shell
$ cat patch-website.yml
spec:
  template:
    spec:
      serviceAccountName: internal-app
```

The patch modifies the deployment definition to use the service account internal-app. This Kubernetes service account is authorized by the Vault Kubernetes authentication role.

Patch the website deployment defined in patch-website.yml.

```shell
$ kubectl patch deployment website --patch "$(cat patch-website.yml)"
```

Get all the pods within the default namespace.

```shell
$ kubectl get pods
NAME                                    READY   STATUS     RESTARTS   AGE
orgchart-554db4579d-w6565               2/2     Running    0          29m
payroll                                 2/2     Running    0          12s
vault-0                                 1/1     Running    0          155m
vault-agent-injector-5945fb98b5-tpglz   1/1     Running    0          155m
website-788d689b87-tll2r                2/2     Running    0          27s
```

The website pod displays that is ready.

Finally, display the secret written to the website container in the website pod.

```shell
$ kubectl exec \
    $(kubectl get pod -l app=website -o jsonpath="{.items[0].metadata.name}") \
    --container website -- cat /vault/secrets/database-config.txt; echo
postgresql://db-readonly-user:db-secret-password@postgres:5432/wizard
```

The PostgreSQL connection string is present on the website container.

~> Vault Kubernetes Roles: Alternatively, you can define a new Vault Kubernetes role, that enables the original service account access, and patch the deployment.

## Secrets are bound to the namespace

Similar to how the secrets are bound to a service account they are also bound
to a namespace.

Create the `offsite` namespace:

```shell
$ kubectl create namespace offsite
namespace/offsite created
```

Set the current context to the offsite namespace:

```shell
$ kubectl config set-context --current --namespace offsite
Context "minikube" modified.
```

Apply the internal-app service account definition to create it within the offsite namespace:

```shell
$ kubectl apply --filename service-account-internal-app.yml
serviceaccount/internal-app created
```

View the deployment for the issues application.

```shell
$ cat deployment-issues.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: issues
  labels:
    app: issues
spec:
  selector:
    matchLabels:
      app: issues
  replicas: 1
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "internal-app"
        vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
        vault.hashicorp.com/agent-inject-template-database-config.txt: |
          {{- with secret "internal/data/database/config" -}}
          postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/wizard
          {{- end -}}
      labels:
        app: issues
    spec:
      serviceAccountName: internal-app
      containers:
        - name: issues
          image: jweissig/app:0.0.1
```

Apply the deployment defined in deployment-issues.yml.

```shell
$ kubectl apply --filename deployment-issues.yml
deployment.apps/issues created
```

Get all the pods within the `offsite` namespace:

```shell
$ kubectl get pods
NAME                      READY   STATUS     RESTARTS   AGE
issues-7956fff46d-9kzv6   0/2     Init:0/1   0          40s
```

-> **Current context:** The same command is issued but the results are different
  because you are now in a different namespace.

The issues deployment creates a pod but it does not ever become ready.

View the logs of the `vault-agent-init` container in the
`issues-7956fff46d-9kzv6` pod:

```shell
$ kubectl logs issues-7956fff46d-9kzv6 --container vault-agent-init
...
2019-12-20T21:43:41.293Z [INFO]  auth.handler: authenticating
2019-12-20T21:43:41.296Z [ERROR] auth.handler: error authenticating: error="Error making API request.

URL: PUT http://vault.default.svc:8200/v1/auth/kubernetes/login
Code: 500. Errors:

* namespace not authorized" backoff=1.9882590740000001
```

The initialization process fails because the namespace is not authorized. The namespace, offsite is not assigned to any Vault Kubernetes authentication role. This failure to authenticate causes the deployment to fail initialization.

Start an interactive shell session on the vault-0 pod in the default namespace.

```shell
$ kubectl exec --namespace default -it vault-0 -- /bin/sh
/ $
```

Your system prompt is replaced with a new prompt / $. Commands issued at this prompt are executed on the vault-0 container.

Create a Kubernetes authentication role named offsite-app.

```shell
$ vault write auth/kubernetes/role/offsite-app \
    bound_service_account_names=internal-app \
    bound_service_account_namespaces=offsite \
    policies=internal-app \
    ttl=24h
Success! Data written to: auth/kubernetes/role/offsite-app
```

Exit the vault-0 pod.

```shell
$ exit
```

View the deployment patch patch-issues.yml.

```shell
$ cat patch-issues.yml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-status: "update"
        vault.hashicorp.com/role: "offsite-app"
        vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/data/database/config"
        vault.hashicorp.com/agent-inject-template-database-config.txt: |
          {{- with secret "internal/data/database/config" -}}
          postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/wizard
          {{- end -}}
```

The patch performs an update to set the vault.hashicorp.com/role to the Vault Kubernetes role offsite-app.

Patch the issues deployment defined in patch-issues.yml.

```shell
$ kubectl patch deployment issues --patch "$(cat patch-issues.yml)"
deployment.apps/issues patched
```

The original issues pod is terminated and a new issues pod is created.

Get all the pods within the offsite namespace.

```shell
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
issues-7fd66f98f6-ffzh7   2/2     Running   0          94s
```

The issues pod displays that is ready.

Finally, display the secret written to the issues container in the issues pod.

```shell
$ kubectl exec \
    $(kubectl get pod -l app=issues -o jsonpath="{.items[0].metadata.name}") \
    --container issues -- cat /vault/secrets/database-config.txt; echo
postgresql://db-readonly-user:db-secret-password@postgres:5432/wizard
```

The PostgreSQL connection string is present on the issues container.
