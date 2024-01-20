# Taints and Tolerations

_Taints_ allow a node to repel a set of pods.

_Tolerations_ are applied to pods. Tolerations allow the scheduler to schedule pods with matching taints.

Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. 

One or more taints are applied to a node; this marks that the node should not accept any pods that do not tolerate the taints.

To get the list if node is tainted or not:

```
kubectl describe node node01 | grep -i taint
```

To taint the node is below command:

```
kubectl taint node node01 bird=goose:NoSchedule
```
Here we have used key "bird" and value "goose".

To remove the taint added by the command above, you can run:

```
kubectl taint node node01 bird=goose:NoSchedule-
```

To get the list if node is tainted or not:

```
kubectl describe node node01 | grep -i taint
```


You specify a toleration for a pod in the PodSpec. Both of the following tolerations "match" the taint created by the `kubectl taint` line above, and thus a pod with either toleration would be able to schedule onto `node01`:

```
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
```

```
tolerations:
- key: "key1"
  operator: "Exists"
  effect: "NoSchedule"
```

