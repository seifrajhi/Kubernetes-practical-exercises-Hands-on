# GitOps with ArgoCD

GitOps turns the CI/CD approach on its head - instead of an external automation server pushing changes into the cluster, a tool inside the cluster monitors a Git repo and pulls in any changes.

It means your cluster can be secured more cleanly, because you don't need a cluster admin user for the automation server. It also means your app definitions - and even the infrastructure setup for cloud services - can be definitively stored in Git repos. You can recreate your whole deployment from scratch.

## Reference

- [GitOps](https://www.gitops.tech) - describing the approach and its adoption

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) - the GitOps project in the CNCF

- [ArgoCD command line](https://argoproj.github.io/argo-cd/user-guide/commands/argocd/)

- [Application CRD spec](https://argoproj.github.io/argo-cd/operator-manual/application.yaml)

- [GitOps with Kubernetes and Argo](https://eltons.show/episodes/ecs-c3/) - my YouTube walkthrough

## Install ArgoCD

ArgoCD has a server-side component which runs in the cluster and watches the configured Git repos for your projects. There's also a command line tool which you can use to set up and manage projects.

Start by installing the CLI - use the [full install docs](https://argo-cd.readthedocs.io/en/stable/cli_installation/) or one of these quick options:

```
# Windows:
choco install argocd-cli

# Mac:
brew install argocd

# Linux:
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

Check your installation with:

```
argocd version
```

> You'll see the client version and then a server error - the CLI can't connect to the ArgoCD server, because we haven't deployed it yet.

There's a local copy of the Argo CD spec here:

- [argocd/2.1.2.yaml](./specs/argocd/2.1.2.yaml) - it installs a lot of resources, including CustomResourceDefinitions - CRDs - which extend the functionality of Kubernetes. ArgoCD adds an `Application` resource to the cluster.

Deploy the server components:

```
kubectl apply -n argocd -f labs/argo/specs/argocd
```

The CustomResourceDefinition is just like any object in Kubernetes - you can work with the definition in Kubectl:

```
kubectl get customresourcedefinitions -n argocd 

kubectl describe crd applications.argoproj.io -n argocd
```

> There's a lot of detail in the output - the CRD contains the object schema - but it ends with the kind, which is the name of the resource.

📋 List all of the application objects in the default namespace.

<details>
  <summary>Not sure how?</summary>

```
kubectl get applications -n default
```

</details><br/>

This installation of ArgoCD includes a web UI. The initial admin password is stored in a Secret - run this to view the password in plain text:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o go-template="{{.data.password | base64decode}}"
```

Open the UI at http://localhost:30018, log in with username `admin` and the password from your Secret.

> You'll be redirected to HTTPS with a self-signed certificate, so you'll need to accept the security warning in your browser.

Open https://localhost:30018/settings/clusters - ArgoCD is registered with the local cluster so it can manage applications, but there are no apps yet.

## Create an application

ArgoCD deploys apps as units which are configured with a source code repo to watch. The contents of the repo can be standard Kubernetes YAML, Helm charts or Kustomize. 

ArgoCD monitors the repo, and whenever there is a change - so the running app is out of sync with the specifications in the source repo - it fetches the changes and updates the app.

We'll run a local Git server to make the deployment simple:

- [gogs/gogs.yaml](./specs/gogs/gogs.yaml) is the same Gogs server we used in the [Jenkins lab](../../labs/jenkins/README.md)

Deploy the Git server:

```
kubectl apply -f labs/argo/specs/gogs
```

When the Pod is ready, add the new server as a remote and push a copy of this repo:

```
# add the local Git server:
git remote add labs-argo http://localhost:30030/kiamol/kiamol.git

# push to the expected branch name:
git push labs-argo main:master

# login with username kiamol and password kiamol
```

> This version of ArgoCD expects to find a branch named `master` in the Git repo. This repo uses `main` as the branch name, so the push command uses the expected name in the Git server.

Now connect the ArgoCD CLI to the ArgoCD server, using your password from the Secret:

```
argocd login localhost:30018 --insecure --username admin --password <your-password>

argocd cluster list
```

> You can add new clusters to deploy to a remote Kubernetes cluster. Apps can be managed with the CLI or with the UI.

Create an application for the whomi app in the `labs/argo/project/helm/whoami` folder - that folder contains a simple Helm chart for the app:

```
argocd app create whoami --repo http://gogs.infra.svc.cluster.local:3000/kiamol/kiamol.git --path labs/argo/project/helm/whoami --dest-server https://kubernetes.default.svc --dest-namespace whoami
```

> Creating the app doesn't deploy it.

📋 Check the details of the new application with the Argo CLI and with Kubectl.

<details>
  <summary>Not sure how?</summary>

The application is just a Kubernetes object - but it's created in the Argo namespace:

```
kubectl get applications -A

kubectl describe application whoami -n argocd
```

You get the key information in a more readable format from the Argo CLI:

```
argocd app list

argocd app get whoami
```

</details><br/>


Check the new application in the UI at https://localhost:30018/applications. You'll see the status is _OutOfSync_ which means the application in the cluster is not in sync with the definition in source.

Select the whoami app and you can see the resources it defines, even though it's not running yet. Click _App Details_ then _Paramaters_ - these are all read from the Helm chart, and can be edited here (which defies the point of GitOps really...)
 
## Deploy the app

ArgoCD deploys apps when you sync them.

Try this to deploy the whoami app - it will fail:

```
argocd app sync whoami
```

📋 Why does the deployment fail?

<details>
  <summary>Not sure?</summary>

The app is set to deploy to a namespace called whoami, but that namespace doesn't exist.

</details><br/>

Applications can be created with the CLI or the UI - but they're just Kubernetes objects and can be specified in YAML instead:

- [whoami/app.yaml](./specs/whoami/app.yaml) - updates the app spec to create the namespace and to use [self-healing](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-self-healing), so the app will automatically keep in sync with the repo even if an admin changes something in the cluster

Update the app spec:

```
kubectl apply -f labs/argo/specs/whoami
```

> You'll see a warning because the resource wasn't originally created with Kubectl, but the update does happen.

📋 Open a second terminal to watch the ReplicaSets for the app, then try syncing it again with the Argo CLI.

<details>
  <summary>Not sure how?</summary>

There won't be any ReplicaSets to start with:

```
kubectl get rs -o wide -n whoami --watch
```

Repeat the sync command and you'll see the ReplicaSet created and two Pods come online:

```
argocd app sync whoami
```

</details><br/>

ArgoCD has deployed the app from the Helm chart in the repo - with no pipeline or scripts to maintain. You can test the app at http://localhost:30028.


## Update the app

Now let's see GitOps in action, making a change to the image tag for the app

Edit the Helm [values.yaml](./project/helm/whoami/values.yaml) file and make two changes:

- set the image tag to `docker.io/courselabs/whoami-lab:21.09-4`
- set the replica count to 3

📋 Trigger the update by pushing your changes to the local Git server.

<details>
  <summary>Not sure how?</summary>

```
git add labs/argo/project/helm/whoami/values.yaml

git commit -m 'Bump to build -4'

git push labs-argo main:master
```

</details><br/>

You can watch the update happening in the UI at https://localhost:30018/applications/whoami

> ArgoCD updates the Deployment - in a minute or so you'll see a new ReplicaSet gets created with 3 Pods, and the old one scales down

Automatic sync with self-heal mode means ArgoCD will repair any drift in the environment. The spec in the Git repo is the golden source and if the cluster deployment is different, it gets updated.

📋 Prove that by deleting a resource which Kubernetes won't repair by itself, and watch ArgoCD fix it up.

<details>
  <summary>Not sure how?</summary>

You can delete Pods - but the ReplicaSet will recreate them, or you can delete the ReplicaSet - but the Deployment will recreate it.

Delete the Pod controller and normally it wouldn't get replaced:

```
kubectl delete deploy whoami-server -n whoami
```

</details><br/>

> You'll see a new Deployment and new ReplicaSet are created, scaled up to the 3 Pods set in the values file

## Lab

One of the great features of ArgoCD is that it can deploy all the main Kubernetes package types, without you needing to install tools or write deployment scripts.

We haven't used [Kustomize](https://kustomize.io/) in this course, but it's a nice alternative to Helm if you don't have complex templating requirements.

In this lab you'll use ArgoCD to deploy a Kustomize app without needing to understand what Kustomize does, or how to use it.

Create an ArgoCD app for the project in `labs/argo/project/kustomize/base`:

- it's in the same repo as the whoami app, so the Git URL can be the same
- set the app to deploy to the default namespace
- configure it for auto-sync

Trigger a deployment of the app, and browse to it.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup

Deleting apps in ArgoCD doesn't remove the running application - unless you use the cascade flag:

```
argocd app delete lab whoami --cascade
```

> ArgoCD asks you to confirm you really want to do this :)

Then delete the lab namespaces:

```
kubectl delete ns -l kubernetes.courselabs.co=argo

kubectl delete ns whoami
```

And remove your Git remote:

```
git remote rm labs-argo
```