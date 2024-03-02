## Exercise 3

First we get the deployment yaml
```
kubectl get deployment snooper -n starfruit -o yaml > snooper-new.yaml
```

Edit the deployment yaml as follow:
```
...

    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: snooper-con
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /tmp/snooper.log
          name: logsfile
      - name: kennylogger-con
        image: busybox:1.31.0
        args: [/bin/sh, -c, 'tail -n+1 -f /tmp/snooper.log']
        volumeMounts:
        - name: logsfile
          mountPath: /tmp/snooper.log
...



```
Apply the deployment:
```
kubectl create -f snooper-new.yaml
```


