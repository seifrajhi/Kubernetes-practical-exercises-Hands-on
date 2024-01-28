# Running One-off Pods with Jobs and Recurring Pods with CronJobs

Sometimes you want a Pod to execute some work and then stop. You could deploy a Pod spec, but that has limited retry support if the work fails, but you can't use a Deployment because it will replace the Pod if it exits successfully.

[Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) are for this use-case - they're a Pod controller which creates a Pod and ensures it runs to completion. If the Pod fails the Job will start a replacement, but when the Pod succeeds the Job is done.

Jobs can have their own controller with a [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) that contains a Job spec and a schedule. On the schedule it creates a Job, which creates and monitors a Pod.

## API specs

- [Job (batch/v1)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#job-v1-batch)
- [CronJob (batch/v1beta1)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#cronjob-v1beta1-batch)

<details>
  <summary>YAML overview</summary>

The simplest Job spec just has metadata and a template with a standard Pod spec:

```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-job  
spec:
  template:
    spec:
      containers:
        - # container spec
      restartPolicy: Never
```

- `template.spec` - a Pod spec which can include volumes, configuration and everything else in a normal Pod
- `restartPolicy` - the default Pod restart policy is `Always` which is not allowed for Jobs; you must specify `Never` or `OnFailure`

CronJobs wrap the Job spec, adding a schedule in the form of a *nix [cron expression](https://www.baeldung.com/cron-expressions):

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: db-backup
spec:
  schedule: "0 9 * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    # job spec
```

- `apiVersion` - Kubernetes uses beta versions to indicate the API isn't final; [CronJobs will graduate to stable in Kubernetes 1.21](https://kubernetes.io/blog/2021/04/08/kubernetes-1-21-release-announcement/#cronjobs-graduate-to-stable)
- `schedule` - cron expression for when Jobs are to be created
- `concurrencyPolicy` - whether to `Allow` new Job(s) to be created when the previous scheduled Job is still runing, `Forbid` that or `Replace` the old Job with a new one

</details><br/>

## Run a one-off task in a Job

We have a website we can use to calculate Pi, but the app can also run a one-off calculation:

- [pi-job-50dp.yaml](specs/pi/one/pi-job-50dp.yaml) - Job spec which uses the same Pi image with a new command to run a one-off calculation

Create the Job:

```
kubectl apply -f labs/jobs/specs/pi/one

kubectl get jobs
```

Jobs apply a label to Pods they create (in addition to any labels in the template Pod spec).

📋 Use the Job's label to get the Pod details and show its logs.

<details>
  <summary>Not sure how?</summary>

```
kubectl get pods --show-labels 

kubectl get pods -l job-name=pi-job-one

kubectl logs -l job-name=pi-job-one
```

</details><br/>

> You'll see Pi computed. That's the only output from this Pod.

When Jobs have completed they are not automatically cleaned up:

```
kubectl get jobs
```

> The Job shows 1/1 completions - which means 1 Pod ran successfully 

You can't update the Pod spec for an existing Job, Jobs don't manage Pod upgrades like Deployments do.

- [pi-job-500dp.yaml](specs/pi/one/update/pi-job-500dp.yaml) - changes the Pod spec to calculate Pi to more decimal places

Try to change the existing Job and you'll get an error:

```
kubectl apply -f labs/jobs/specs/pi/one/update
```

> To change a Job you would first need to delete the old one

## Run a Job with multiple concurrent tasks

Jobs aren't just for a single task, in some scenarios you want the same Pod to run for a fixed number of times. 

When you have a fixed set of work to process, use can use a Job to run all the pieces in parallel:

- [pi-job-random.yaml](specs/pi/many/pi-job-random.yaml) - defines a Job to run 3 Pods concurrently, each of which calculates Pi to a random number of decimal places

Run the random Pi Job:

```
kubectl apply -f labs/jobs/specs/pi/many

kubectl get jobs -l app=pi-many
```

> You'll see one Job, with 3 expected completions

📋 Check the Pod status and logs for this Job.

<details>
  <summary>Not sure how?</summary>

```
kubectl get pods -l job-name=pi-job-many

kubectl logs -l job-name=pi-job-many
```

</details><br />

> You'll get logs for all the Pods - pages of Pi :)

The Job has details of all the Pods it creates:

```
kubectl describe job pi-job-many
```

> Shows Pod creation events and Pod statuses

## Schedule tasks with CronJobs

Jobs are not automatically cleared up so you can work with the Pods and see the logs.

Periodically running a cleanup task is one scenario where you use a CronJob:

- [cleanup/cronjob.yaml](specs/cleanup/cronjob.yaml) - a CronJob which runs a shell script to delete jobs by running Kubectl inside a Pod
- [cleanup/rbac.yaml](specs/cleanup/rbac.yaml) - Service Account for the Pod and RBAC rules to allow it to query and delete Jobs
- [cleanup/configmap.yaml](specs/cleanup/configmap.yaml) - ConfigMap which contains the shell script - this is a nice way to run scripts without having to build a custom Docker image

The CronJob is set to run every minute so you'll soon see it get to work.

📋 Deploy the CronJob and watch all Jobs to see them being removed.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/jobs/specs/cleanup

kubectl get cronjob

kubectl get jobs --watch
```

</details><br/>

> You'll see the cleanup Job get created, and then the list will be updated with new a new cleanup Job every minute

Confirm that completed Pi Jobs and their Pods have been removed:

```
# Ctrl-C to exit the watch

kubectl get jobs 

kubectl get pods -l job-name --show-labels
```

> The most recent cleanup job is still there because CronJobs don't delete Jobs when they complete

You can check the logs to see what the cleanup script did:

```
kubectl logs -l app=job-cleanup
```

## Lab

Real CronJobs don't run every minute - they're used for maintenance tasks and run much less often, like hourly, daily or weekly.

Often you want to run a one-off Job from a CronJob without waiting for the next one to be created on schedule.

The first task for this lab is to edit the `job-cleanup` CronJob and set it to suspended, so it won't run any more Jobs and confuse you when you create your new Job. **See if you can do this without using `kubectl apply`**.

Then deploy this new CronJob:

```
kubectl apply -f labs/jobs/specs/backup
```

And the next task is to run a Job from this CronJob's spec. **See if you can also do this without using `kubectl apply`**.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___


## **EXTRA** Manage failures in Jobs

<details>
  <summary>Retry options for failed Jobs</summary>

Background tasks in Jobs could run for a long time, and you need some control on how you handle failures. 

The first option is to allow Pod restarts, so if the container fails then a new container is started in the same Pod:

- [one-failing/pi-job.yaml](specs/pi/one-failing/pi-job.yaml) - a Job spec with a mistake in the container command; the restart policy is set so the Pod will restart when the container fails

Try this Job:

```
kubectl apply -f labs/jobs/specs/pi/one-failing

kubectl get jobs pi-job-one-failing
```

The Pod is created but the container will immediately exit, causing the Pod to restart:

```
kubectl get pods -l job-name=pi-job-one-failing --watch
```

> You'll see RunContainerError statuses & multiple restarts until the Pod goes into CrashLoopBackoff

You may not want a failing Pod to restart, and the Job can be set to create replacement Pods instead. This is good if a failure was caused by a problem on one node, because the replacement Pod could run on a different node:

- [pi-job-restart.yaml](specs/pi/one-failing/update/pi-job-restart.yaml) - sets the restart policy so the Pod never restarts, and sets a backoff limit in the Job so if the Pod fails the Job will try with new Pods up to 4 times

You can't update the existing Job, so you'll need to delete it first:

```
kubectl delete jobs pi-job-one-failing

kubectl apply -f labs/jobs/specs/pi/one-failing/update
```

Now when you watch the Pods you won't see the same Pod restarting, you'll see new Pods being created:

```
kubectl get pods -l job-name=pi-job-one-failing --watch
```

> You'll see ContainerCannotRun status, 0 restarts & by the end a total of 4 Pods

A side-effect of a Pod hitting `ContainerCannotRun` status is that you won't see any logs, and to find out why you'll need to describe the Pod:

```
kubectl logs -l job-name=pi-job-one-failing

kubectl describe pods -l job-name=pi-job-one-failing
```

> Just a typo in the command line...

</details><br/>

___

## Cleanup

```
kubectl delete job,cronjob,cm,sa,clusterrole,clusterrolebinding -l kubernetes.courselabs.co=jobs
```