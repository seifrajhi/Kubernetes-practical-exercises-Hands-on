# Troubleshooting Apps in Kubernetes

You'll spend a lot of your time in Kubectl troubleshooting problems.

Kubernetes validates API specs for correctness when you deploy them, but it doesn't check that your app will actually work.

Objects like Services and Pods are loosely-coupled, so it's easy to break your application if there are errors in your specs.

## Lab

This one is all lab :) Try running this app - and make whatever changes you need to get the app running, so the Pod is healthy with no restarts.

```
kubectl apply -f labs/troubleshooting/specs/pi-failing
```

> Your goal is to browse to http://localhost:8020 or http://localhost:30020 and see the response from the Pi app

Don't go straight to the solution! These are the sort of issues you will get all the time, so it's good to start working through the steps to diagnose problems.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___
## Cleanup

When you're done you can remove all the objects:

```
kubectl delete all -l kubernetes.courselabs.co=troubleshooting
```