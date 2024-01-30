<div align=center>
  
# Orphaned object

</div>

An orphaned object in Kubernetes is an object that is not owned or managed by any other object in the cluster. This means that the object is not tied to the lifecycle of any other object, and it may not be deleted when other objects are deleted.

Orphaned objects can be created manually, or they may be left behind if the object that created them is deleted. For example, if you delete a Deployment that creates and manages a ReplicaSet and Pod objects, the ReplicaSet and Pod objects will be deleted along with the Deployment. However, if you delete the Deployment but leave the ReplicaSet and Pod objects behind, they will become orphaned.

Orphaned objects can be a problem in Kubernetes because they may consume resources (such as CPU and memory) without serving any purpose. It's a good idea to periodically check for orphaned objects and delete them if they are no longer needed.

objects are like little helpers that do things for us. Some objects create and manage other objects, kind of like a boss. These objects are called "owners," and the objects they create are called "dependents."

Sometimes, an object might not have an owner anymore. This is called being "orphaned." Orphaned objects are kind of like helpers who don't have a boss to tell them what to do. They might still be around and using up resources, but they aren't doing anything useful.

It's a good idea to clean up orphaned objects because they might be using up resources that we could use for something else. We can do this by deleting the orphaned objects.

Orphaned pods are pods that are not owned by any controller object in Kubernetes, such as a Deployment or ReplicaSet. These pods can be created manually, or they may be left behind if the controller object that created them is deleted.

Here are some common operations that you can perform on orphaned pods:

List orphaned pods: You can use the kubectl get pods command to list all the pods in your cluster, and then filter the output to show only orphaned pods. For example:

```s
kubectl get pods --field-selector='status.phase!=Running'
```

Delete orphaned pods: You can use the kubectl delete pod command to delete an orphaned pod. For example:

```s
kubectl delete pod my-orphaned-pod
```

Create a new controller object to adopt an orphaned pod: If you want to adopt an orphaned pod and add it to a new controller object (such as a Deployment), you can use the kubectl patch command to update the pod's metadata.ownerReferences field. For example:

```s
kubectl patch pod my-orphaned-pod -p '{"metadata":{"ownerReferences":[{"apiVersion":"apps/v1","kind":"Deployment","name":"my-new-deployment","uid":"abcdef01-2345-6789-0123-456789abcdef"}]}}'
```

To identify orphaned pods, you can use the kubectl get pods command and filter the output to show only pods that are not managed by a ReplicationController, Deployment, or other controller. For example:

```s
kubectl get pods --output=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.ownerReferences}{"\n"}{end}' | grep -v '\[\]'
```

This will list all pods that do not have any owner references, which indicates that they are not managed by a controller.

To delete orphaned pods, you can use the kubectl delete pod command followed by the name of the pod you want to delete. For example:

```s
kubectl delete pod <pod-name>
```

Keep in mind that deleting an orphaned pod will also delete any data stored in the pod's volumes, so you should only delete orphaned pods if you are sure that you no longer need the data they contain.