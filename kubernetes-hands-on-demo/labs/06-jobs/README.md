# Jobs with Kubernetes

* [PreRequirements](README.md#pre-requirements)
* [Basic Job](README.md#basic-job)
* [Jobs with Script as ConfigMap](README.md#jobs-with-script-as-configmap)
* [Jobs with ActiveDeadlineSeconds](README.md#jobs-with-activedeadlineseconds)
* [BackoffLimit with Jobs](README.md#backofflimit-with-jobs)
* [CompletionNumber with Jobs](README.md#completionnumber-with-jobs)
* [Parallelism with Jobs](README.md#parallelism-with-jobs)
* [Cronjob](README.md#cronjob)
* [Cronjob with ConcurrencyPolicy](README.md#cronjob-with-concurrencypolicy)

## Pre Requirements

Create a Namespace for our Jobs:

```
> kubectl create namespace jobs
```

## Basic Job

```
> kubectl apply -f 01-job.yml
job.batch/basic created
```

```
> kubectl get jobs -n jobs
NAME    COMPLETIONS   DURATION   AGE
basic   1/1           11s        11s
```

```
> kubectl get pods -n jobs
NAME          READY   STATUS      RESTARTS   AGE
basic-zhwgk   0/1     Completed   0          17s
```

```
> kubectl logs -f job/basic -n jobs
=> Start of Job
hello, world
goodbye, world
=> Finish of Job
```
```
> kubectl delete job/basic -n jobs
job.batch "basic" deleted
```

## Jobs with Script as ConfigMap

```
> kubectl apply -f 02-job-with-script.yml
configmap/script-configmap unchanged
job.batch/script-job created
```
```
> kubectl get jobs/script-job -n jobs
NAME         COMPLETIONS   DURATION   AGE
script-job   1/1           5s         22s
```
```
> kubectl get pods -n jobs
NAME               READY   STATUS      RESTARTS   AGE
script-job-pkd8f   0/1     Completed   0          31s
```
```
> kubectl logs -f job/script-job -n jobs
Hello world!
Goodbye world!
script-job-pkd8f
```

```
> kubectl delete job/script-job -n jobs
job.batch "script-job" deleted
```

## Jobs with ActiveDeadlineSeconds

Jobs with `activeDeadlineSeconds` less than the runtime of the job

```
> kubectl apply -f 03-job-with-activedeadlineseconds.yml
job.batch/hello-goodbye-with-timeout created
```

```
$ kubectl get jobs/hello-goodbye-with-timeout -n jobs
NAME                         COMPLETIONS   DURATION   AGE
hello-goodbye-with-timeout   0/1           63s        63s
```

```
> kubectl get jobs/hello-goodbye-with-timeout -n jobs -o yaml
status:
  conditions:
  - lastProbeTime: "2020-02-13T10:21:57Z"
    lastTransitionTime: "2020-02-13T10:21:57Z"
    message: Job was active longer than specified deadline
    reason: DeadlineExceeded
    status: "True"
    type: Failed
  failed: 1
  startTime: "2020-02-13T10:21:55Z"
```

## BackoffLimit with Jobs

```
> kubectl apply -f 04-job-with-backupofflimit.yml
job.batch/back-off-limit created
```

```
> kubectl get pods -n jobs -w
NAME                   READY   STATUS             RESTARTS   AGE
back-off-limit-8rkh8   0/1     CrashLoopBackOff   3          107s
back-off-limit-8rkh8   1/1     Running            4          2m
back-off-limit-8rkh8   0/1     Error              4          2m5s
back-off-limit-8rkh8   0/1     CrashLoopBackOff   4          2m18s
```

```
> kubectl get jobs -n jobs
NAME             COMPLETIONS   DURATION   AGE
back-off-limit   0/1           9m5s       9m5s
```

```
> kubectl get job/back-off-limit -n jobs -o yaml
...
status:
  conditions:
  - lastProbeTime: "2020-02-13T10:33:04Z"
    lastTransitionTime: "2020-02-13T10:33:04Z"
    message: Job has reached the specified backoff limit
    reason: BackoffLimitExceeded
    status: "True"
    type: Failed
  failed: 1
  startTime: "2020-02-13T10:29:28Z"
```

## CompletionNumber with Jobs

```
> kubectl apply -f 05-job-with-completion-number.yml
job.batch/completion-number created
```

```
> kubectl get jobs/completion-number -n jobs
NAME                COMPLETIONS   DURATION   AGE
completion-number   6/6           91s        98s
```

```
> kubectl get pods -n jobs
NAME                      READY   STATUS      RESTARTS   AGE
completion-number-wkhtx   0/1     Completed   0          107s
completion-number-2h8kq   0/1     Completed   0          92s
completion-number-j99cv   0/1     Completed   0          77s
completion-number-t74zn   0/1     Completed   0          61s
completion-number-n5btz   0/1     Completed   0          46s
completion-number-gz4sr   0/1     Completed   0          31s
```

```
> kubectl get jobs/completion-number -n jobs -o yaml
...
status:
  completionTime: "2020-02-13T10:44:51Z"
  conditions:
  - lastProbeTime: "2020-02-13T10:44:51Z"
    lastTransitionTime: "2020-02-13T10:44:51Z"
    status: "True"
    type: Complete
  startTime: "2020-02-13T10:43:20Z"
  succeeded: 6
```

## Parallelism with Jobs

```
> kubectl apply -f 06-job-with-paralell-execusions.yml
job.batch/parallelism created
```

```
> kubectl get jobs -n jobs
NAME          COMPLETIONS   DURATION   AGE
parallelism   3/3           21s        34s
```

```
> kubectl get pods -n jobs
NAME                READY   STATUS      RESTARTS   AGE
parallelism-5qrhv   0/1     Completed   0          30s
parallelism-msbz8   0/1     Completed   0          30s
parallelism-2r9bw   0/1     Completed   0          30s
```

```
> kubectl get job/parallelism -n jobs -o yaml
...
status:
  completionTime: "2020-02-13T10:50:25Z"
  conditions:
  - lastProbeTime: "2020-02-13T10:50:25Z"
    lastTransitionTime: "2020-02-13T10:50:25Z"
    status: "True"
    type: Complete
  startTime: "2020-02-13T10:50:04Z"
  succeeded: 3
```

## Cronjob

A cronjob spawns a job

```
> kubectl apply -f 07-cronjob.yml
cronjob.batch/every-minute created
ruan.bekker in ~/workspace/personal/k3d-prometheus-grafana
```
```
> kubectl get cronjobs -n jobs
NAME           SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
every-minute   */1 * * * *   False     0        <none>          11s
ruan.bekker in ~/workspace/personal/k3d-prometheus-grafana
```

```
> kubectl get pods -n jobs
NAME                            READY   STATUS      RESTARTS   AGE
every-minute-1581591600-k4ttx   0/1     Completed   0          3m9s
every-minute-1581591660-x8jrs   0/1     Completed   0          2m8s
every-minute-1581591720-bw6wx   0/1     Completed   0          68s
every-minute-1581591780-dx448   1/1     Running     0          8s
```

```
> kubectl get jobs -n jobs
NAME                      COMPLETIONS   DURATION   AGE
every-minute-1581591600   1/1           11s        3m14s
every-minute-1581591660   1/1           10s        2m13s
every-minute-1581591720   1/1           9s         73s
every-minute-1581591780   1/1           10s        13s
```

```
> kubectl get cronjobs/every-minute -n jobs
NAME           SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
every-minute   */1 * * * *   False     1        14s             7m34s
```
```
> kubectl delete cronjobs/every-minute -n jobs
cronjob.batch "every-minute" deleted
```

## Cronjob with ConcurrencyPolicy

* `Forbid` if you don't want concurrent executions of your Job.
* `Replace` as the concurrency policy, the currently running Job will be stopped and a new Job will be spawned.
* `Allow` will let multiple Job instances run concurrently.

```
> kubectl apply -f 08-cronjob-concurrency.yml
cronjob.batch/concurrency created
```

```
> kubectl get jobs -n jobs
NAME                     COMPLETIONS   DURATION   AGE
concurrency-1581592320   1/1           95s        4m22s
concurrency-1581592380   1/1           96s        3m22s
concurrency-1581592500   0/1           82s        82s
concurrency-1581592440   1/1           95s        2m22s
concurrency-1581592560   0/1           22s        22s
```

```
> kubectl get pods -n jobs
NAME                           READY   STATUS      RESTARTS   AGE
concurrency-1581592320-6njzg   0/1     Completed   0          4m29s
concurrency-1581592380-ddcdg   0/1     Completed   0          3m29s
concurrency-1581592500-64bg7   1/1     Running     0          89s
concurrency-1581592440-94xdr   0/1     Completed   0          2m29s
concurrency-1581592560-v8nrx   1/1     Running     0          29s
```

```
> kubectl get cronjobs -n jobs
NAME          SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
concurrency   '*/1 * * * *'   False     2        23s             5m14s
```

```
> kubectl delete cronjobs/concurrency -n jobs
cronjob.batch "concurrency" deleted
```
