# 🚦 Deploying Kubernetes

Deploying AKS and Kubernetes can be extremely complex, with many networking, compute and other aspects to consider.
However for the purposes of this workshop, a default and basic cluster can be deployed very quickly.

## 🚀 AKS Cluster Deployment

The following commands can be used to quickly deploy an AKS cluster:

```bash
# Create Azure resource group
az group create --name $RES_GROUP --location $REGION

# Create cluster
az aks create --resource-group $RES_GROUP \
  --name $AKS_NAME \
  --location $REGION \
  --node-count 2 --node-vm-size Standard_B2ms \
  --kubernetes-version $KUBE_VERSION \
  --verbose \
  --no-ssh-key
```

In case you get an error when creating cluster, `Version x.xx.x is not supported in this region.`, run the following to get the supported kubernetes version

```sh
az aks get-versions --location $REGION -o table
```

And re-run the create cluster command with supported version number.

This should take around 5 minutes to complete, and creates a new AKS cluster with the following
characteristics:

- Two small B-Series _Nodes_ in a single node pool. _Nodes_ are what your workloads will be running on.
- Basic 'Kubenet' networking, which creates an Azure network and subnet etc for us. [See docs if you wish to learn more about this topic](https://docs.microsoft.com/azure/aks/operator-best-practices-network)
- Local cluster admin account, with RBAC enabled, this means we don't need to worry about setting up users or assigning roles etc.
- AKS provide a wide range of 'turn key' addons, e.g. monitoring, AAD integration, auto-scaling, GitOps etc, however we'll not require for any of these to be enabled.
- The use of SSH keys is skipped with `--no-ssh-key` as they won't be needed.

The `az aks create` command has [MANY options](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create)
however you shouldn't need to change or add any options, with some small exceptions:

- You may wish to change the size or number of nodes, however this clearly has cost implications.

## 🔌 Connect to the Cluster

To enable `kubectl` (and other tools) to access the cluster, run the following:

```bash
az aks get-credentials --name $AKS_NAME --resource-group $RES_GROUP
```

This will create Kubernetes config file in your home directory `~/.kube/config` which is the default location, used by `kubectl`.

Now you can run some simple `kubectl` commands to validate the health and status of your cluster:

```bash
# Get all nodes in the cluster
kubectl get nodes

# Get all pods in the cluster
kubectl get pods --all-namespaces
```

Don't be alarmed by all the pods you see running in the 'kube-system' namespace. These are deployed by default by AKS and perform management & system tasks we don't need to worry about.
You can still consider your cluster "empty" at this stage.

## ⏯️ Appendix - Stopping & Starting the Cluster

If you are concerned about the costs for running the cluster you can stop and start it at any time.
This essentially stops the node VMs in Azure, meaning the costs for the cluster are greatly reduced.

```bash
# Stop the cluster
az aks stop --resource-group $RES_GROUP --name $AKS_NAME

# Start the cluster
az aks start --resource-group $RES_GROUP --name $AKS_NAME
```

> 📝 NOTE: Start and stop operations do take several minutes to complete, so typically you would
> perform them only at the start or end of the day.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../00-pre-reqs/readme.md) ‖ [Next Section ⏩](../02-container-registry/readme.md)
