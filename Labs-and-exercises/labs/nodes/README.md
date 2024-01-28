# Examining Nodes with Kubectl

[Kubectl](https://kubectl.docs.kubernetes.io/references/kubectl/) is the command line to work with a Kubernetes cluster.

It has commands to deploy applications and work with objects in the cluster. 


## Working with Nodes

Two of the most common Kubectl commands are `get` and `describe`.

You can use them with different objects; try finding information about the nodes in your cluster:

```
kubectl get nodes
```

> Nodes are the servers in the cluster. The `get` command prints a table with basic information.

``` 
kubectl describe nodes
```

> There's a lot more information to see and `describe` gives it to you in a readable format.

## Getting help

Kubectl has built-in help, you can use it to list all commands or list the details of one command:

```
kubectl --help

kubectl get --help
```

And you can learn about resources by asking Kubectl to explain them:

```
kubectl explain node
```

## Querying and formatting

You will spend **a lot** of time with Kubectl. You'll want to get familiar with some features early on, like querying.

Kubectl can print information in different formats, try showing your node details in JSON:

```
kubectl get node <your-node> -o json
```

Check the help to see what other output formats you can use.

One is [JSON Path](https://kubernetes.io/docs/reference/kubectl/jsonpath/), which is a query language you can use to print specific fields:

```
kubectl get node <your-node> -o jsonpath='{.status.capacity.cpu}'
```

> This tells you the number of CPU cores Kubernetes sees for that node.

What happens if you try the same command without specifying a node name?

## Lab

Every object in Kubernetes can have **labels** - they are key-value pairs used to record additional information about the object.

Use Kubectl to find labels for you node, which will confirm the CPU architecture and operating system it's using.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

