# 📦 Container Registry & Images

We will deploy & use a private registry to hold the application container images. This is not strictly
necessary as we could pull the images directly from the public, however using a private registry is
a more realistic approach.

[Azure Container Registry](https://docs.microsoft.com/azure/container-registry/) is what we will be
using.

## 🚀 ACR Deployment

Deploying a new ACR is very simple:

```bash
az acr create --name $ACR_NAME --resource-group $RES_GROUP \
--sku Standard \
--admin-enabled true
```

> 📝 NOTE: When you pick a name for the resource with $ACR_NAME, this has to be **globally unique**, and not contain any underscores, dots or hyphens.
> Name must also be in lowercase.

## 📥 Importing Images

For the sake of speed and maintaining the focus on Kubernetes we will import pre-built images from another public registry (GitHub Container Registry), rather than build them from source.

We will cover what the application does and what these containers are for in the next section, for
now we can just import them.

To do so we use the `az acr import` command:

```bash
# Import application frontend container image
az acr import --name $ACR_NAME --resource-group $RES_GROUP \
--source ghcr.io/benc-uk/smilr/frontend:stable \
--image smilr/frontend:stable

# Import application data API container image
az acr import --name $ACR_NAME --resource-group $RES_GROUP \
--source ghcr.io/benc-uk/smilr/data-api:stable \
--image smilr/data-api:stable
```

If you wish to check and see imported images, you can go over to the ACR resource in the Azure portal, and into the 'Repositories' section.

> 📝 NOTE: we are not using the tag `latest` which is a common mistake when working with Kubernetes
> and containers in general.

## 🔌 Connect AKS to ACR - as Azure Subscription Owner

Kuberenetes requires a way to authenticate and access images stored in private registries.
There are a number of ways to enable Kubernetes to pull images from a private registry, however AKS provides a simple way to configure this through the Azure CLI.
The downside is this requires you to have 'Owner' permission within the subscription, in order to assign the role.

```bash
az aks update --name $AKS_NAME --resource-group $RES_GROUP --attach-acr $ACR_NAME
```

If you are curious what this command does, it essentially is just assigning the "ACR Pull" role in Azure IAM to the managed identity used by AKS, on the ACR resource.

If you see the following error `Could not create a role assignment for ACR. Are you an Owner on this subscription?`, you will need to proceed to the alternative approach below.

## 🔌 Connect AKS to ACR - Alternative

If you do not have Azure Owner permissions, you will need to fall back to an alternative approach.
This involves two things:

- Adding an _Secret_ to the cluster containing the credentials to pull images from the ACR.
- Including a reference to this _Secret_ in every _Deployment_ you create or update the _ServiceAccount_
  used by the _Pods_ to reference this _Secret_.

Run these commands to create the _Secret_ with the ACR credentials, and patch the default _ServiceAccount_:

```bash
kubectl create secret docker-registry acr-creds \
  --docker-server=$ACR_NAME.azurecr.io \
  --docker-username=$ACR_NAME \
  --docker-password=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

kubectl patch serviceaccount default --patch '"imagePullSecrets": [{"name": "acr-creds" }]'
```

> 💥 IMPORTANT! Do NOT follow this approach of patching the default _ServiceAccount_ in production or a cluster running real workloads, treat this as a simplifying workaround.

These two commands introduce a lot of new Kubernetes concepts in one go! Don't worry about them for
now, some of this such as _Secrets_ we'll go into later. If the command is successful, move on.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../01-cluster/readme.md) ‖ [Next Section ⏩](../03-the-application/readme.md)
