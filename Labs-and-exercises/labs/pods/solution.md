# Lab Solution

Your Pod spec will look like this - you can use the sample in [solution/lab.yaml](./solution/lab.yaml):

```
apiVersion: v1
kind: Pod
metadata:
  name: sleep-lab
spec:
  containers:
    - name: app
      image: courselabs/bad-sleep
```

Deploy it in the usual way with Kubectl:

```
kubectl apply -f labs/pods/solution/lab.yaml
```

Now watch the Pod status:

```
kubectl get pod sleep-lab --watch
```

After around 30 seconds, the application in the container ends, so the container exits - then Kubernetes restarts the Pod. You'll see a new line in the watch output, with the restart count increased to 1:

```
NAME        READY   STATUS    RESTARTS   AGE
sleep-lab   1/1     Running   0          3s
sleep-lab   0/1     Completed   0          33s
sleep-lab   1/1     Running     1          35s
```

> Pods restart by creating a new container **not** by restarting the existing container

The new container runs until the app exits after 30 seconds. Kubernetes restarts the Pod - but if the Pod containers keep exiting, Kubernetes adds an increasing delay before restarting.

> The status changes to `Completed` then `Running` again, but eventually the Pod enters `CrashLoopBackOff` status:

```
NAME        READY   STATUS    RESTARTS   AGE
sleep-lab   1/1     Running   0          3s
sleep-lab   0/1     Completed   0          33s
sleep-lab   1/1     Running     1          35s
sleep-lab   0/1     Completed   1          64s
sleep-lab   0/1     CrashLoopBackOff   1          79s
sleep-lab   1/1     Running            2          80s
sleep-lab   0/1     Completed          2          110s
sleep-lab   0/1     CrashLoopBackOff   2          2m4s
sleep-lab   1/1     Running            3          2m17s
```

You can delete the Pod by name:

```
kubectl delete pod sleep-lab
```

Or by using the delete command with your YAML file:

```
kubectl delete -f labs/pods/solution/lab.yaml
```

> Back to the [exercises](README.md).