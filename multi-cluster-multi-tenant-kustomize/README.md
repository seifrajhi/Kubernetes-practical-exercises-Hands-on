# Multi-cluster, Multi-tenant Kustomize Example

This repository shows an example of how to use Kustomize's bases and overlays to maintain manifests for an application that requires one instance of the application to be deployed per tenant and per environment.

Bases are configurations that inherit nothing. Overlays are configurations that inherit from somewhere. Overlays can inherit from bases or from other overlays.

Our example has just one base, the example app represented by a single nginx deployment.

In overlays, we have `clusters`, `plans` and `tenant-envs`.

 1. `clusters`: We have one directory per region. If a tenant-env should be in the us, you add it as a base to the `us/kustomization.yaml`. If a tenant-env should be in the eu, you add it to the `eu/kustomization.yaml` bases.

 1. `plans`: The plans overlay is where you'd put configuration that is different per plan. In our example trial tenants get less replicas then paying tenants.

 1. `tenant-envs`: Our example has a `test` and a `prod` environment per client. Both tenant environments go onto the same cluster. The tenant-env overlays are where you put configuration that is specific to an env. E.g. the database connection should be unique per tenant per env. The tenant envs would also be a good place to give a certain tenant a specific version of the app (e.g. a hotfix) by overwriting the image tags for that tenant and possibly in the tenants test env first.

Adopting a repository structure like this to manage multiple tenants makes it intuitive to understand where certain changes should be made while at the same time reducing the amount of duplicate manifests to a minimum.

Applying a configuration to a cluster ist just one `kustomize build overlays/clusters/eu | kubectl apply -f -` command.

Kustomize has recently been included into kubectl. Once that's released a simple `kubectl apply -f overlays/clusters/eu` is good enough.
