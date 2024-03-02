## Exercise 7

First we could start by listing the pods of the namespace showing the labels
```
kubectl get pods -n basket --show-labels
```
That give us an idea of the initial status before to apply the changes:

```
NAME         READY   STATUS    RESTARTS   AGE   LABELS
lemon        1/1     Running   0          26h   type=citrus
lime         1/1     Running   0          26h   type=citrus
pear         1/1     Running   0          26h   type=seedless
strawberry   1/1     Running   0          26h   type=seedless
watermelon   1/1     Running   0          26h   type=seeds

```

Then we can label the pods, we can do it tag by tag or all together, this is up to you

```
kubectl label pod --selector='type=citrus' safe=sound -n basket

pod/lemon labeled
pod/lime labeled
```
And
```
kubectl label pod --selector='type=seedless' safe=sound -n basket

pod/pear labeled
pod/strawberry labeled

```

Check that the label has been applied to the correct pods:

```
kubectl get pods -n basket --show-labels

NAME         READY   STATUS    RESTARTS   AGE   LABELS
lemon        1/1     Running   0          27h   safe=sound,type=citrus
lime         1/1     Running   0          27h   safe=sound,type=citrus
pear         1/1     Running   0          27h   safe=sound,type=seedless
strawberry   1/1     Running   0          27h   safe=sound,type=seedless
watermelon   1/1     Running   0          27h   type=seeds


```

Last step is to annotate the pods with the label `safe:sound`

```
kubectl annotate pod --selector='safe=sound' fruit='good for what ails ya' -n basket

pod/lemon annotated
pod/lime annotated
pod/pear annotated
pod/strawberry annotated

```
