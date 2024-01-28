## Pre-req - if you use Docker Desktop

- docker desktop fix

```
# on Docker Desktop for Mac:
kubectl patch clusterrolebinding docker-for-desktop-binding --type=json --patch $'[{"op":"replace", "path":"/subjects/0/name", "value":"system:serviceaccounts:kube-system"}]'

# OR on Docker Desktop for Windows - PowerShell:
kubectl patch clusterrolebinding docker-for-desktop-binding --type=json --patch '[{\"op\":\"replace\", \"path\":\"/subjects/0/name\", \"value\":\"system:serviceaccounts:kube-system\"}]'
```