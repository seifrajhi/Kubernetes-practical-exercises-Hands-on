[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)][gitpod]

# kubernetes-exercises

A selection of exercises for Kubernetes (k8s).

The exercises are ordered in the way we think it makes sense to introduce Kubernetes concepts.

You can find a summary of many of the commands used in the exercises in the
[cheatsheet.md](cheatsheet.md).

> :exclamation: The exercises expect that you have access to a kubernetes cluster.
> Please have a look at the [Setup](#setup) section if that is not the case.
> There are plenty of free and easy options.

## exercises in suggested order:

- [intro](intro.md)
- [desired-state](desired-state.md)
- [manifests](manifests.md)
- [accessing-your-application](accessing-your-application.md)
- [services](services.md)
- [deployments-loadbalancing](deployments-loadbalancing.md)
- [rolling-updates](rolling-updates.md)
- [configmaps-secrets](configmaps-secrets.md)
- [persistent-storage](persistent-storage.md)

## Setup

There are several ways to get a free Kubernetes cluster for running the exercises.

[Amazon][eks], [Google][gke], [Microsoft][aks] and [Oracle][oke] provide various degrees of free managed clusters.

Alternatively, you can set up a local cluster with [Docker
Desktop][docker-desktop] or [Kind][kind].

Once you have access to a cluster, the following exercises will help you get setup for running the exercises.

- [setup-kubectl-linux](old/exercise_setup/00-setup-kubectl-linux.md) - Skip if
  you've already installed `kubectl` and have access to a cluster.
- [setup-namespace](old/exercise_setup/00-setup-namespace.md) - Skip if you've
  already created a personal namespace and set it as your default.

### kubectl autocompletion

On Linux, using bash, run the following commands:

```shell
echo "source <(kubectl completion bash)" >> ~/.bashrc
. ~/.bashrc
```

The commands above will enable kubectl autocompletion when you start a new bash session and source (reload) bashrc i.e. enable kubectl autocompletion in your current session.

See: [Kubernetes.io - Enabling shell autocompletion][autocompletion] for more info.

# Cheatsheet

A collection of useful commands to use throughout the exercises:

```bash
kubectl api-resources         # List resource types


kubectl explain <resource>    # Show information about a resource
kubectl explain deployment


# List resources in cluster
kubectl get <resource>                    # In current namespace
kubectl get <resource> -n <namespace>     # In specific namespace
kubectl get <resource> --all-namespaces   # In all namespaces
kubectl get <resource> -o wide            # Add extended information
kubectl get <resource> -o yaml            # output in YAML format
kubectl get <resource> -o json            # output in JSON format

# Example
kubectl get pods [-n abc|--all-namespaces] [-o wide|yaml|json]
```

See:
[kubectl - Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
for a more extended overview of the `kubectl` command.

[eks]: https://aws.amazon.com/ecs/pricing/
[gke]: https://cloud.google.com/kubernetes-engine/pricing#cluster_management_fee_and_free_tier
[aks]: https://azure.microsoft.com/en-us/pricing/free-services/
[oke]: https://www.oracle.com/cloud/free/#free-cloud-trial
[docker-desktop]: https://docs.docker.com/desktop/
[kind]: https://kind.sigs.k8s.io/
[autocompletion]: https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion
