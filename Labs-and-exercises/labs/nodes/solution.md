# Lab Solution

The easiest way to see labels for an object is with the `show-labels` option to the `get command`:

```
kubectl get nodes --show-labels
```

To see specific label values you can print the labels as columns:

```
kubectl get nodes --label-columns kubernetes.io/arch,kubernetes.io/os
```

Alternatively you can query the labels field in the metadata using JSONPath:

```
kubectl get node <your-node> -o jsonpath='{.metadata.labels}'
```

Or you can query for specific values with a Go template:

```
# with Bash:
kubectl get node <your-node> -o go-template=$'{{index .metadata.labels "kubernetes.io/arch"}}'

# or with PowerShell:
kubectl get node docker-desktop -o go-template='{{index 
.metadata.labels `"kubernetes.io/arch`"}}'
```

(JSONPath doesn't like the forward slash in the label key)

> Back to the [exercises](README.md).