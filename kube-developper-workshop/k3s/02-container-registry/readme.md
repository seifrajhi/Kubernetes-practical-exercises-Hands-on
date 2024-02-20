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

> 📝 NOTE: When you pick a name for the resource with $ACR_NAME, this has to be **globally unique**,
> and not contain no underscores, dots, or hyphens.

## 📥 Importing Images

For the sake of speed and maintaining the focus on Kubernetes we will import pre-built images from
another public registry (GitHub Container Registry), rather than build them from source.

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

If you wish to check and see imported images, you can go over to the ACR resource in the Azure portal,
and into the 'Repositories' section.

> 📝 NOTE: we are not using the tag `latest` which is a common mistake when working with Kubernetes
> and containers in general.

## 🔌 Connect K3s to ACR

Kuberenetes requires a way to authenticate and access images stored in private registries. There are
a number of ways to enable Kubernetes to pull images from a private registry, however K3S provides a
simple way to configure this through the `registries.yaml`. The downside is this requires you to
manually add the file to your device/VM.

On your VM create the `registries.yaml` with the following content:

> 📝 NOTE: The password is retrieved with Azure CLI, if you don't have Azure CLI on the VM, you can
> just retrieve your ACR password from the portal and replace that section your ACR password

```sh
# Copy the ACR name from the .env file created earlier or from Azure
ACR_NAME=<your_acr_value>
cat <<EOT > /etc/rancher/k3s/registries.yaml
configs:
  "$ACR_NAME.azurecr.io":
    auth:
      username: $ACR_NAME
      password: $(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
EOT
# Verify the file was created with the right values
cat /etc/rancher/k3s/registries.yaml

# Restart K3s for the change to take effect
sudo systemctl restart k3s;
```

> To read more about how `registries.yaml` works, you can checkout [Rancher Docs: Private Registry Configuration](https://rancher.com/docs/k3s/latest/en/installation/private-registry/).

## Navigation

[Return to Main Index 🏠](../../readme.md)
[Previous Section ⏪](../01-cluster/readme.md) ‖ [Next Section ⏩](../03-the-application/readme.md)
