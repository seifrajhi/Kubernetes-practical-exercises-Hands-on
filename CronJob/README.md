Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [CronJob](#cronjob)
- [Cron schedule syntax](#cron-schedule-syntax)
- [Time zones](#time-zones)
- [CronJob limitations](#cronjob-limitations)
    - [For example](#for-example)
- [Running Automated Tasks with a CronJob](#running-automated-tasks-with-a-cronjob)
  - [Deleting a CronJob](#deleting-a-cronjob)
  - [Writing a CronJob Spec](#writing-a-cronjob-spec)
    - [Schedule](#schedule)
    - [Job Template](#job-template)
    - [Starting Deadline](#starting-deadline)
    - [Concurrency Policy](#concurrency-policy)
    - [Suspend](#suspend)
    - [Jobs History Limits](#jobs-history-limits)
- [Reference links](#reference-links)


# CronJob

A CronJob creates Jobs on a repeating schedule.

One CronJob object is like one line of a crontab (cron table) file. It runs a job periodically on a given schedule, written in Cron format.

CronJobs are meant for performing regular scheduled actions such as backups, report generation, and so on. Each of those tasks should be configured to recur indefinitely (for example: once a day / week / month); you can define the point in time within that interval when the job should start.

Example
This example CronJob manifest prints the current time and a hello message every minute:


```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

# Cron schedule syntax

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │                                   OR sun, mon, tue, wed, thu, fri, sat
# │ │ │ │ │
# * * * * *
```

|Entry|	Description|	Equivalent to|
|---|---|---|
|@yearly (or @annually)|	Run once a year at midnight of 1 January|	0 0 1 1 *|
|@monthly|	Run once a month at midnight of the first day of the month|	0 0 1 * *|
|@weekly|	Run once a week at midnight on Sunday morning|	0 0 * * 0|
@daily (or @midnight)|	Run once a day at midnight|	0 0 * * *|
@hourly|	Run once an hour at the beginning of the hour|	0 * * * *|

For example, the line below states that the task must be started every Friday at midnight, as well as on the 13th of each month at midnight:

`0 0 13 * 5`

To generate CronJob schedule expressions, you can also use web tools like [crontab.guru](https://crontab.guru/).

# Time zones

For CronJobs with no time zone specified, the kube-controller-manager interprets schedules relative to its local time zone.

# CronJob limitations

A cron job creates a job object _about_ once per execution time of its schedule. We say "about" because there are certain circumstances where two jobs might be created, or no job might be created. We attempt to make these rare, but do not completely prevent them. Therefore, jobs should be _idempotent_.

If `startingDeadlineSeconds` is set to a large value or left unset (the default) and if `concurrencyPolicy` is set to `Allow`, the jobs will always run at least once.

For every CronJob, the CronJob Controller checks how many schedules it missed in the duration from its last scheduled time until now. If there are more than 100 missed schedules, then it does not start the job and logs the error

`Cannot determine if job needs to be started. Too many missed start time (> 100). Set or decrease .spec.startingDeadlineSeconds or check clock skew.` 

It is important to note that if the `startingDeadlineSeconds` field is set (not `nil`), the controller counts how many missed jobs occurred from the value of `startingDeadlineSeconds` until now rather than from the last scheduled time until now. For example, if `startingDeadlineSeconds` is `200`, the controller counts how many missed jobs occurred in the last 200 seconds.

A CronJob is counted as missed if it has failed to be created at its scheduled time. For example, If `concurrencyPolicy` is set to `Forbid` and a CronJob was attempted to be scheduled when there was a previous schedule still running, then it would count as missed.

### For example

Suppose a CronJob is set to schedule a new Job every one minute beginning at `08:30:00`, and its `startingDeadlineSeconds` field is not set. 

If the CronJob controller happens to be down from `08:29:00` to `10:21:00`, the job will not start as the number of missed jobs which missed their schedule is greater than 100.

To illustrate this concept further, suppose a CronJob is set to schedule a new Job every one minute beginning at `08:30:00`, and its `startingDeadlineSeconds` is set to 200 seconds. If the CronJob controller happens to be down for the same period as the previous example (`08:29:00` to `10:21:00`,) the Job will still start at 10:22:00. 

This happens as the controller now checks how many missed schedules happened in the last 200 seconds (ie, 3 missed schedules), rather than from the last scheduled time until now.

The CronJob is only responsible for creating Jobs that match its schedule, and the Job in turn is responsible for the management of the Pods it represents.


# Running Automated Tasks with a CronJob

Cron jobs require a config file. Here is a manifest for a CronJob that runs a simple demonstration task every minute:

```yaml
#cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```


Run the example CronJob by using this command:

```shell
kubectl create -f cronjob.yaml
```

The output is similar to this:

```
cronjob.batch/hello created
```

After creating the cron job, get its status using this command:

```shell
kubectl get cronjob hello
```

The output is similar to this:

```
NAME    SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   */1 * * * *   False     0        <none>          10s
```

As you can see from the results of the command, the cron job has not scheduled or run any jobs yet. Watch for the job to be created in around one minute:

```shell
kubectl get jobs --watch
```

The output is similar to this:

```
NAME               COMPLETIONS   DURATION   AGE
hello-4111706356   0/1                      0s
hello-4111706356   0/1           0s         0s
hello-4111706356   1/1           5s         5s
```

Now you've seen one running job scheduled by the "hello" cron job. You can stop watching the job and view the cron job again to see that it scheduled the job:

```shell
kubectl get cronjob hello
```

The output is similar to this:

```
NAME    SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   */1 * * * *   False     0        50s             75s
```

You should see that the cron job `hello` successfully scheduled a job at the time specified in `LAST SCHEDULE`. There are currently 0 active jobs, meaning that the job has completed or failed.

Now, find the pods that the last scheduled job created and view the standard output of one of the pods.

**Note:** The job name is different from the pod name.

```shell
# Replace "hello-4111706356" with the job name in your system
pods=$(kubectl get pods --selector=job-name=hello-4111706356 --output=jsonpath={.items[*].metadata.name})
```

Show the pod log:

```shell
kubectl logs $pods
```


## Deleting a CronJob

When you don't need a cron job any more, delete it with `kubectl delete cronjob <cronjob name>`:

```shell
kubectl delete cronjob hello
```

Deleting the cron job removes all the jobs and pods it created and stops it from creating additional jobs. 

## Writing a CronJob Spec

As with all other Kubernetes objects, a CronJob must have `apiVersion`, `kind`, and `metadata` fields. 

Each manifest for a CronJob also needs a `.spec` section.

### Schedule

The `.spec.schedule` is a required field of the `.spec`. It takes a Cron format string, such as `0 * * * *` or `@hourly`, as schedule time of its jobs to be created and executed.

### Job Template

The `.spec.jobTemplate` is the template for the job, and it is required. It has exactly the same schema as a Job, except that it is nested and does not have an `apiVersion` or `kind`. For information about writing a job `.spec`.

### Starting Deadline

The `.spec.startingDeadlineSeconds` field is optional. 

It stands for the deadline in seconds for starting the job if it misses its scheduled time for any reason. 

After the deadline, the cron job does not start the job. Jobs that do not meet their deadline in this way count as failed jobs. If this field is not specified, the jobs have no deadline.

If the `.spec.startingDeadlineSeconds` field is set (not null), the CronJob controller measures the time between when a job is expected to be created and now. If the difference is higher than that limit, it will skip this execution.

For example, if it is set to `200`, it allows a job to be created for up to 200 seconds after the actual schedule.

### Concurrency Policy

The `.spec.concurrencyPolicy` field is also optional. It specifies how to treat concurrent executions of a job that is created by this cron job. The spec may specify only one of the following concurrency policies:

-   `Allow` (default): The cron job allows concurrently running jobs
-   `Forbid`: The cron job does not allow concurrent runs; if it is time for a new job run and the previous job run hasn't finished yet, the cron job skips the new job run
-   `Replace`: If it is time for a new job run and the previous job run hasn't finished yet, the cron job replaces the currently running job run with a new job run

Note that concurrency policy only applies to the jobs created by the same cron job. If there are multiple cron jobs, their respective jobs are always allowed to run concurrently.

### Suspend

The `.spec.suspend` field is also optional. If it is set to `true`, all subsequent executions are suspended. This setting does not apply to already started executions. Defaults to false.

### Jobs History Limits

The `.spec.successfulJobsHistoryLimit` and `.spec.failedJobsHistoryLimit` fields are optional. 

These fields specify how many completed and failed jobs should be kept. By default, they are set to 3 and 1 respectively. 

Setting a limit to `0` corresponds to keeping none of the corresponding kind of jobs after they finish.


# Reference links

- [CronJobs concepts](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [Automated Tasks with a CronJob](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/)



