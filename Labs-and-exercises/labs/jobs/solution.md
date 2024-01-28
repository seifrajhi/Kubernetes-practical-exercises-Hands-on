# Lab Solution

## Suspending the cleanup CronJob

This will need some investigation if you're not going to use `kubectl apply`. The command to run instead is:

```
kubectl edit cronjob job-cleanup
```

That launches the YAML spec in your editor - in the `spec` for the CronJob you'll find the field `suspend`. Just change the value from `false` to `true`, save the file and exit the editor.

Kubectl applies the change when the editor exits:

```
kubectl get cronjob
```

> Now the CronJob is suspended, so the spec is still there but it won't create any more Jobs.

## Creating a Job from a CronJob

This one is straightforward but you tend to use `kubectl create` rarely and you might forget what it can do:

```
kubectl create job --help
```

Shows you the exact syntax you need. For this lab:

```
kubectl create job db-backup-job --from=cronjob/db-backup

kubectl get jobs -l app=db-backup

kubectl logs -l app=db-backup
```

Adding the lab label will help with cleanup:

```
kubectl label job db-backup-job kubernetes.courselabs.co=jobs
```

> Back to the [exercises](README.md)