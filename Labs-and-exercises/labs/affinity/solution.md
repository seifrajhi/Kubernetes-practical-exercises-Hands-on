# Lab Solution

## Apply labels

We'll do this first, so the labels are in place when Pods are scheduled.

Add the `verified` label to agent-1:

```
# this label may already exist from the exercises
# if you see an error you can ignore it
kubectl label node k3d-labs-affinity-agent-1 cis-compliance=verified
```

Add the `in-progress` label to agent-0:

```
kubectl label node k3d-labs-affinity-agent-0 cis-compliance=in-progress
```

Print the labels to make sure the values are correct:

```
kubectl get nodes -L cis-compliance -l cis-compliance
```

## Deploy

My solution uses required rules to ensure Pods only run on valid nodes, and preferred rules to place more Pods on verified nodes:

- [whoami-compliance-preferred.yaml](.\solution\whoami-compliance-preferred.yaml) 

```
kubectl apply -f labs\affinity\solution

kubectl get po -o wide -l app=whoami
```

> You should see the majority of Pods scheduled on the verified node agent-1, up to the node's maximum of 5. The rest will be on agent 0. 

You can't gaurantee to get a 5-1 split because the rule is a soft preference - and there could be other Pods running on agent-1 (on my cluster the DNS Pod is running on agent-1 so I get a 4-2 split).

> Back to the [exercises](README.md).