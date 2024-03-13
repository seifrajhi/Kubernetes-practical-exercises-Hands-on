# Readiness & Liveness Probes

-  Readiness probes helps kubelet to know when a container is ready to start accepting traffic. A Pod is considered ready when all of its containers are ready
 - Liveness probes helps kubelet to know when the pod is unhealthy and needs to be restarted.

<br />

 - [Readiness probes](#readiness-probes)
 - [Liveness probes](#liveness-probes)

## Readiness probes

<br />

### Create a `nginx-readiness` pod with a readiness probe that just runs the http request on `/` with port `80`

<details><summary>show</summary><p>

```bash
kubectl run nginx-readiness --image=nginx --restart=Never --dry-run=client -o yaml > nginx-readiness.yaml
```

Edit `nginx-readiness.yaml` file to add `readinessProbe` probe as below and apply `kubectl apply -f nginx-readiness.yaml`

```YAML
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    readinessProbe: # declare the readiness probe
      httpGet: # add this line
        path: / #
        port: 80 #
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

</p></details> 

<br />

## Liveness probes

<br />

### Create a `nginx-liveness` pod with a liveness probe that just runs the command 'ls'.

<details><summary>show</summary><p>

```bash
kubectl run nginx-liveness --image=nginx --restart=Never --dry-run=client -o yaml > nginx-liveness.yaml
```

Edit `nginx-liveness.yaml` file to add `livenessProbe` probe as below and apply `kubectl apply -f nginx-liveness.yaml`

```YAML
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    livenessProbe: # add liveness probe
      exec: # add this line
        command: # command definition
        - ls # ls command
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```
</p></details> 

<br />

### Modify `nginx-liveness` pod to add a delay of 30 seconds whereas the interval between probes would be 5 seconds.

<details><summary>show</summary><p>

#### Edit `nginx-liveness.yaml` file to update `livenessProbe` probe as below. Delete and recreate pod using `kubectl apply -f nginx-liveness.yaml`

```YAML
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    livenessProbe: 
      initialDelaySeconds: 30 # add this line
      periodSeconds: 5 # add this line as well
      exec:
        command:
        - ls
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

</p></details>

<br />

## Troubleshooting

### Create a pod `liveness-exec` with the following specs. Wait for 30 secs and check if the pod restarts. Identify the reason.

```bash
cat << EOF > exec-liveness.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

kubectl apply -f exec-liveness.yaml
```

<details><summary>show</summary><p>

```bash
kubectl get pod liveness-exec -w # pod restarts due to failed liveness check
# NAME            READY   STATUS    RESTARTS   AGE
# liveness-exec   1/1     Running   0          17s
# liveness-exec   1/1     Running   1          76s

kubectl describe pod liveness-exec

# Normal   Started    69s (x2 over 2m22s)  kubelet, node01    Started container liveness
# Warning  Unhealthy  25s (x6 over 110s)   kubelet, node01    Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
# Normal   Killing    25s (x2 over 100s)   kubelet, node01    Container liveness failed liveness probe, will be restarted
```

</p></details>

### Clean up 

```bash
rm nginx-liveness.yaml nginx-readiness.yaml
kubectl delete pod nginx-readiness nginx-liveness liveness-exec --force
```