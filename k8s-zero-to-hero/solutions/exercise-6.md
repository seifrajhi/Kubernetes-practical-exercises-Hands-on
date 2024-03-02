## Exercise 6

Create your job template as follow:
```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
  namespace: banana
  labels:
    eatyour: bananas
spec:
  completions: 5
  parallelism: 3
  template:
    spec:
      containers:
      - name: banana-bin
        image: busybox:1.31.0
        command: ["/bin/sh",  "-c", "sleep 2 && echo done"]
      restartPolicy: Never


```

Apply this template and check that it's working properly:
```
kubectl create -f bananajob.yaml

```

```
kubectl get jobs -A

NAMESPACE   NAME   COMPLETIONS   DURATION   AGE
banana      pi     5/5           9s         12s

```

