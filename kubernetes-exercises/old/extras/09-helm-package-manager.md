# The Kubernetes package manager

## Learning goal

- Try the Helm cli to spin up a chart

## Introduction

[Enter Helm](https://github.com/helm/helm) - the
answer to how to package multi-container
applications, and how to easily install packages
on Kubernetes.

Helm helps you to:

- Achieve a simple (one command) and repeatable
  deployment
- Manage application dependency, using specific
  versions of other application and services
- Manage multiple deployment configurations: test,
  staging, production and others
- Execute post/pre deployment jobs during
  application deployment
- Update/rollback and test application deployments

## Using helm charts

Helm uses a packaging format called charts. A
Chart is a collection of files that describe k8s
resources.

 <details>
      <summary>More details</summary>
Charts can be simple, describing something like a
standalone web server but they can also be more
complex, for example, a chart that represents a
full web application stack included web servers,
databases, proxies, etc.

Instead of installing k8s resources manually via
kubectl, we can use Helm to install pre-defined
Charts faster, with less chance of typos or other
operator errors.

When you install Helm, it does not have a
connection to any default repositories. This is
because Helm wants to decouple the application to
the repository in use.

One of the largest Chart Repositories is the
[BitNami Chart Repository](https://charts.bitnami.com/bitnami)
is however going to be used in these exercises.

The chart repository are very dynamic due to
updates and new additions. To keep Helm's local
list updated with all these changes, we need to
occasionally run the
[repository update](https://docs.helm.sh/helm/#helm-repo-update)
command.

</details>

## Exercise

### Overview

- Add a chart repository to your helm cli
- Install Nginx chart
- Access the Nginx load balanced service
- Look at the status of the deployment with
  `helm ls`
- Clean up the chart deployment

### Step by step

<details>
      <summary>More details</summary>

**Add a chart repository to your helm cli**

To install the Bitnami Helm Repo and update Helm's
local list of Charts, run:

- `helm repo add bitnami https://charts.bitnami.com/bitnami`
- `helm repo update`

**Install Nginx Chart**

To get something installed fasted and easy we have
chosen the Nginx chart.

- `helm install my-release bitnami/nginx`

This command creates a release called `my-release`
with the bitnami/nginx chart.

The command will output information about your
newly deployed mysql setup similar to this:

```
NAME: my-release
LAST DEPLOYED: Tue Apr 20 12:46:10 2021
NAMESPACE: user1
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

NGINX can be accessed through the following DNS name from within your cluster:

    my-release-nginx.user1.svc.cluster.local (port 80)

To access NGINX from outside the cluster, follow the steps below:

1. Get the NGINX URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace user1 -w my-release-nginx'

    export SERVICE_PORT=$(kubectl get --namespace user1 -o jsonpath="{.spec.ports[0].port}" services my-release-nginx)
    export SERVICE_IP=$(kubectl get svc --namespace user1 my-release-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "http://${SERVICE_IP}:${SERVICE_PORT}"
```

**Access the Nginx load balanced service**

Get the external IP and port with the following
three commands.

- `export SERVICE_PORT=$(kubectl get --namespace user1 -o jsonpath="{.spec.ports[0].port}" services my-release-nginx)`
- `export SERVICE_IP=$(kubectl get svc --namespace user1 my-release-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')`
- `echo "http://${SERVICE_IP}:${SERVICE_PORT}"`
- Navigate your browser to the url printed out by
  the last command

**Look at the status of the deployment with `helm`
and `kubectl`**

Running `helm ls` will show all current
deployments.

- Run `helm ls` and observe that you have a
  release named `my-release`
- Run `kubectl get pods,deployments,svc` and look
  at a few of the kubernetes objects the release
  created.

> :bulb: As said before Helm deals with the
> concept of
> [charts](https://github.com/kubernetes/charts)
> for its deployment logic. bitnami/nginx was a
> chart,
> [found here](https://github.com/bitnami/charts/tree/master/bitnami/nginx)
> that describes how helm should deploy it. It
> interpolates values into the deployment, which
> for nginx looks
> [like this](https://github.com/bitnami/charts/blob/master/bitnami/nginx/templates/deployment.yaml).
> The charts describe which values can be given
> for overwriting default behavior, and there is
> an active community around it.

**Clean up the chart deployment**

To remove the `my-release` release run:

- `helm uninstall my-release`

</details>
