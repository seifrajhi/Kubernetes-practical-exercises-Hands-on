# Jobs & Cron Jobs
A Job creates one or more Pods and will continue to retry execution of the Pods until a specified number of them successfully terminate.  
A CronJob creates Jobs on a repeating schedule.

<br />

- [Jobs](#jobs)
- [Cron Jobs](#cron-jobs)

<br /> 

## Jobs

<br />

### Create job named `pi` with image `perl` that runs the command with arguments `"perl -Mbignum=bpi -wle 'print bpi(2000)'"`

<br />

<details><summary>show</summary><p>

`kubectl create job pi  --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'`

OR 

```bash
cat << EOF > pi.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
EOF

kubectl apply -f pi.yaml
```

</p></details> 

<br />

### Wait till it's done, get the output

<br /> 

<details><summary>show</summary><p>

```bash
kubectl get jobs -w # wait till 'SUCCESSFUL' is 1 (will take some time, perl image might be big)
# NAME   COMPLETIONS   DURATION   AGE
# pi     1/1           2m18s      2m47s
kubectl get pod # get the pod name
# NAME       READY   STATUS      RESTARTS   AGE
# pi-vkj8b   0/1     Completed   0          2m50s
kubectl logs pi-vkj8b # get the pi numbers
# 3.141592653589793238462643383279502884........
kubectl delete job pi
```
OR 

```bash
kubectl get jobs -w # wait till 'SUCCESSFUL' is 1 (will take some time, perl image might be big)
kubectl logs job/pi
kubectl delete job pi
```
OR 

```bash
kubectl wait --for=condition=complete --timeout=300s job pi
kubectl logs job/pi
kubectl delete job pi
```

</p></details> 

<br />

### Create a job `busybox` with `busybox` image that would be automatically terminated by kubernetes if it takes more than 30 seconds to execute.

<br /> 

<details><summary>show</summary><p>

```bash
kubectl create job busybox --image=busybox --dry-run=client -o yaml -- /bin/sh -c 'while true; do echo hello; sleep 10;done' > busybox-job.yaml
```
  
#### Edit `busybox-job.yaml` to add `job.spec.activeDeadlineSeconds=30` and apply `kubectl apply -f busybox-job.yaml`

```yaml
cat << EOF > busybox-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: busybox
spec:
  activeDeadlineSeconds: 30 # add this line
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - while true; do echo hello; sleep 10;done
        image: busybox
        name: busybox
        resources: {}
      restartPolicy: Never
status: {}
EOF

kubectl apply -f busybox-job.yaml
```

#### Describe the job with the statement `Warning  DeadlineExceeded  xxs   job-controller  Job was active longer than specified deadline`

</p></details> 

<br />

### Delete the job

<br /> 

<details><summary>show</summary><p>

```bash
kubectl delete job busybox
```

</p></details> 

<br />

### Create a job `busybox-completions-job` with `busybox` image that would be run 5 times

<br />

<details><summary>show</summary><p>

```bash
kubectl create job busybox-completions-job --image=busybox --dry-run=client -o yaml -- /bin/sh -c 'echo hello;sleep 10;echo world' > busybox-completions-job.yaml
```

#### Edit `busybox-completions-job.yaml` to add `job.spec.completions=5` and apply `kubectl apply -f busybox-completions-job.yaml`

```yaml
cat << EOF > busybox-completions-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: busybox-completions-job
spec:
  completions: 5 # add this line
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - echo hello;sleep 10;echo world
        image: busybox
        name: busybox-completions-job
        resources: {}
      restartPolicy: Never
status: {}
EOF 

kubectl apply -f busybox-completions-job.yaml
```

#### Check the job pod status `kk get pods -l job-name=busybox-completions-job` or `kubectl get jobs -w` are in completed status after 2-3 minutes.

```bash
kubectl get jobs -w
# NAME                      COMPLETIONS   DURATION   AGE
# busybox-completions-job   0/5           7s         7s
# busybox-completions-job   1/5           15s        15s
# busybox-completions-job   2/5           28s        28s
# busybox-completions-job   3/5           42s        42s
# busybox-completions-job   4/5           56s        56s
# busybox-completions-job   5/5           70s        70s
```

</p></details> 

<br />

### Create a job `busybox-parallelism-job` with `busybox` image that would be run parallely 5 times.

<br />

<details><summary>show</summary><p>

```bash
kubectl create job busybox-parallelism-job --image=busybox --dry-run=client -o yaml -- /bin/sh -c 'echo hello;sleep 10;echo world' > busybox-parallelism-job.yaml
```

#### Edit `busybox-parallelism-job.yaml` to add `job.spec.parallelism=5` and apply `kubectl apply -f busybox-parallelism-job.yaml`

```yaml
cat << EOF > busybox-parallelism-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: busybox-parallelism-job
spec:
  parallelism: 5 # add this line
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - echo hello;sleep 10;echo world
        image: busybox
        name: busybox-parallelism-job
        resources: {}
      restartPolicy: Never
status: {}
EOF 

kubectl apply -f busybox-parallelism-job.yaml
```

#### Check the job pod status `kk get pods -l job-name=busybox-parallelism-job` or `kubectl get jobs -w` are in completed status after 1 minute, as it would quicker as compared to before.

```bash
kubectl get jobs -w
# NAME                      COMPLETIONS   DURATION   AGE
# busybox-parallelism-job   1/1 of 5      15s        15s
# busybox-parallelism-job   2/1 of 5      16s        16s
# busybox-parallelism-job   3/1 of 5      17s        17s
# busybox-parallelism-job   4/1 of 5      18s        18s
# busybox-parallelism-job   5/1 of 5      19s        19s
```

</p></details> 

<br /> 

## [Cron jobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

<br />

### Create a cron job `busybox-cron-job` with image `busybox` that runs every minute on a schedule of `*/1 * * * *` and writes `date; echo Hello from the Kubernetes cluster` to standard output

<details><summary>show</summary><p>

```bash
kubectl create cronjob busybox-cron-job --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster'
```

</p></details> 

<br />

### See its logs and delete it

<br />

<details><summary>show</summary><p>

```bash
kubectl get cj
kubectl get jobs --watch # Bear in mind that Kubernetes will run a new job/pod for each new cron job
# NAME                          COMPLETIONS   DURATION   AGE
# busybox-cron-job-1639638720   0/1                      0s
# busybox-cron-job-1639638720   0/1           0s         0s
# busybox-cron-job-1639638720   1/1           8s         9s
# busybox-cron-job-1639638780   0/1                      0s
# busybox-cron-job-1639638780   0/1           1s         1s
# busybox-cron-job-1639638780   1/1           9s         9s
kubectl get pod --show-labels # observe that the pods have a label that mentions their 'parent' job
kubectl logs busybox-1529745840-m867r
kubectl delete cj busybox
```

</p></details> 

<br />

### Create a cron job with image busybox that runs every minute and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it takes more than 17 seconds to start execution after its scheduled time (i.e. the job missed its scheduled time).

<br />

<details><summary>show</summary><p>

```bash
kubectl create cronjob time-limited-job --image=busybox --restart=Never --dry-run=client --schedule="* * * * *" -o yaml -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster' > time-limited-job.yaml
vi time-limited-job.yaml
```

#### Add `cronjob.spec.startingDeadlineSeconds=17` and apply

```bash
cat << EOF > time-limited-job.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  creationTimestamp: null
  name: time-limited-job
spec:
  startingDeadlineSeconds: 17 # add this line
  jobTemplate:
    metadata:
      creationTimestamp: null
      name: time-limited-job
    spec:
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
            image: busybox
            name: time-limited-job
            resources: {}
          restartPolicy: Never
  schedule: '* * * * *'
status: {}
EOF

kubectl apply -f time-limited-job.yaml
```

</p></details> 

<br />

### Create a cron job with image busybox that runs every minute and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it successfully starts but takes more than 12 seconds to complete execution.

<br />

<details><summary>show</summary><p>

```bash
kubectl create cronjob time-limited-job --image=busybox --restart=Never --dry-run=client --schedule="* * * * *" -o yaml -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster' > time-limited-job.yaml
vi time-limited-job.yaml
```

#### Add cronjob.spec.jobTemplate.spec.activeDeadlineSeconds=12

```bash
cat << EOF > time-limited-job.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  creationTimestamp: null
  name: time-limited-job
spec:
  jobTemplate:
    metadata:
      creationTimestamp: null
      name: time-limited-job
    spec:
      activeDeadlineSeconds: 12 # add this line
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
            image: busybox
            name: time-limited-job
            resources: {}
          restartPolicy: Never
  schedule: '* * * * *'
status: {}
EOF 

kubectl apply -f time-limited-job.yaml
```

</p></details> 

<br />

### Create a CronJob named `hello` that executes a Pod running the following single container.
- name: hello
- image: busybox:1.28
- command: ["/bin/sh", "-c", "date; echo Hello from the Kubernetes cluster"]
Configure the CronJob to
- Execute once every 2 minutes
- Keep 3 completed Job
- Keep 3 failed job
- Never restart Pods
- Terminate Pods after 10 seconds
Manually create and execute on job named `hello-test` from the `hello` CronJob for testing purpose.

<br />

<details><summary>show</summary><p>

```bash
kubectl create cronjob hello --image=busybox --restart=Never --dry-run=client --schedule="*/2 * * * *" -o yaml -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster' > hello-cronjob.yaml
vi hello-cronjob.yaml
```

#### Add the following specs.

```yaml
cat << EOF > hello-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  creationTimestamp: null
  name: hello
spec:
  jobTemplate:
    metadata:
      creationTimestamp: null
      name: hello
    spec:
      activeDeadlineSeconds: 10 # Terminate Pods after 10 seconds
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
            image: busybox
            name: hello
            resources: {}
          restartPolicy: Never # Never restart Pods 
  schedule: '*/2 * * * *' # Execute once every 2 minutes
  successfulJobsHistoryLimit: 3 # Keep 3 completed Job
  failedJobsHistoryLimit: 3 # Keep 3 failed job
status: {}
EOF 

kubectl apply -f hello-cronjob.yaml

# Trigger the job manually
kubectl create job --from=cronjob/hello hello-test
```

</p></details> 

<br />

## Clean up

<br />

```bash
rm hello-cronjob.yaml time-limited-job.yaml busybox-parallelism-job.yaml
kubectl delete job pi busybox-parallelism-job busybox-completions-job hello-test
kubectl delete cronjob time-limited-job hello-cronjob
```