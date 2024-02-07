# Cheat Sheet for K8S

# Short resource names

| Full Resource Name         | Short Resource Name |
| -------------------------- | ------------------- |
| certificates               | cert, certs         |
| certificatesigningrequests | csr                 |
| certificiaterequests       | cr, crs             |
| componentstatuses          | cs                  |
| configmaps                 | cm                  |
| cronjobs                   | cj                  |
| customresourcedefinitions  | crd, crds           |
| daemonsets                 | ds                  |
| deployments                | deploy              |
| endpoints                  | ep                  |
| events                     | ev                  |
| horizontalpodautoscalers   | hpa                 |
| ingresses                  | ing                 |
| limitranges                | limits              |
| namespaces                 | ns                  |
| networkpolicies            | netpol              |
| nodes                      | no                  |
| persistentvolumeclaims     | pvc                 |
| persistentvolumes          | pv                  |
| pods                       | po                  |
| podsecuritypolicies        | psp                 |
| priorityclasses            | pc                  |
| replicasets                | rs                  |
| replicasets                | rs                  |
| replicationcontrollers     | rc                  |
| resourcequotas             | quota               |
| scheduledscalers           | ss                  |
| serviceaccounts            | sa                  |
| services                   | svc                 |
| statefulsets               | sts                 |
| storageclasses             | sc                  |

# Labels

- Add label to resources

```sh
# Add label to the desired resources
kubectl label <resource> <key>=<value>

# Example adding label to node
kubectl label node1 isProd=false

# Example adding label to node
kubectl label node1 isProd=false --overwrite

# remove a label
kubectl label node1 isProd- # The [-] sign will delete the label
```

# Set default namespace

```sh
kubectl     config \
            set-context $(kubectl config current-context) \
            --namespace=codewizard
```

# Get Unused ConfigMaps

```sh
volumesCM=$( kubectl get pods -o jsonpath='{.items[*].spec.volumes[*].configMap.name}' | xargs -n1)
volumesProjectedCM=$( kubectl get pods -o jsonpath='{.items[*].spec.volumes[*].projected.sources[*].configMap.name}' | xargs -n1)
envCM=$( kubectl get pods -o jsonpath='{.items[*].spec.containers[*].env[*].ValueFrom.configMapKeyRef.name}' | xargs -n1)
envFromCM=$( kubectl get pods -o jsonpath='{.items[*].spec.containers[*].envFrom[*].configMapKeyRef.name}' | xargs -n1)

diff \
<(echo "$volumesCM\n$volumesProjectedCM\n$envCM\n$envFromCM" | sort | uniq) \
<(kubectl get configmaps -o jsonpath='{.items[*].metadata.name}' | xargs -n1 | sort | uniq)
```
