# [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

### Update the below specs for nginx pod with `/usr/share/nginx/html` directory mounted on volume `workdir`. 
 - Add an init container named `install` with image `busybox`. 
 - Mount the workdir to the init container.
 - `wget` the `http://info.cern.ch` and save as `index.html` to the `workdir` in the init container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
```

<details><summary>show</summary><p>

```yaml
cat << EOF > init-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  # Add the init container
  initContainers:
  - name: install
    image: busybox
    command:
    - wget
    - "-O"
    - "/work-dir/index.html"
    - http://info.cern.ch
    volumeMounts:
    - name: workdir
      mountPath: "/work-dir"
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
EOF

kubectl apply -f init-demo.yaml

kubectl exec init-demo -- curl http://localhost
#   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#                                  Dload  Upload   Total   Spent    Left  Speed
# 100   646  100   646    0     0  34000      0 --:--:-- --:--:-- --:--:-- 34000
# <html><head></head><body><header>
# <title>http://info.cern.ch</title>
# </header>

# <h1>http://info.cern.ch - home of the first website</h1>
# <p>From here you can:</p>
# <ul>
# <li><a href="http://info.cern.ch/hypertext/WWW/TheProject.html">Browse the first website</a></li>
# <li><a href="http://line-mode.cern.ch/www/hypertext/WWW/TheProject.html">Browse the first website using the line-mode browser simulator</a></li>
# <li><a href="http://home.web.cern.ch/topics/birth-web">Learn about the birth of the web</a></li>
# <li><a href="http://home.web.cern.ch/about">Learn about CERN, the physics laboratory where the web was born</a></li>
# </ul>
# </body></html>
```

</p></details>

<br />

### Add an init container `maker` with image `alpine` to maker-checker pod with the spec given below.
 - The init container should create an empty file named /workdir/calm.txt
 - If /workdir/calm.txt is not detected, the pod should exit
 - Once the spec file has been updated with the init container definition, the pod should be created.

<br />

```yaml
cat << EOF > maker-checker.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: maker-checker
  name: maker-checker
spec:
  containers:
  - image: alpine
    name: checker
    command: ["/bin/sh", "-c", "if /workdir/calm.txt; then sleep 3600; else exit 1; fi;"]
    volumeMounts:
    - name: workdir
      mountPath: "/work-dir"
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
  restartPolicy: Always
status: {}
EOF
```

<details><summary>show</summary><p>

```yaml
cat << EOF > maker-checker.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: maker-checker
  name: maker-checker
spec:
  containers:
  - image: alpine
    name: checker
    command: ["/bin/sh", "-c", "if [ -f /workdir/calm.txt ]; then sleep 3600; else exit 1; fi;"]
    volumeMounts:
    - name: workdir
      mountPath: "/workdir"
  # Add the init container
  initContainers:
  - name: maker
    image: alpine
    command: ["/bin/sh", "-c", "touch /workdir/calm.txt"]
    volumeMounts:
    - name: workdir
      mountPath: "/workdir"
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
  restartPolicy: Always
status: {}
EOF

kubectl apply -f maker-checker.yaml
```

</p></details>

<br />

### Clean up 

<br />

```bash
rm init-demo.yaml maker-checker.yaml
kubectl delete pod init-demo maker-checker --force --grace-period=0
```