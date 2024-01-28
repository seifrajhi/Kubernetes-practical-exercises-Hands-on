# Lab Hints

Fixing apps is a process of checking the status of running objects and seeing what's wrong, then fixing up the YAML and redeploying.

## Troubleshooting Deployments

1. If the spec isn't valid you'll get a useful error from Kubectl

2. Remember the relationship between objects - you'll need to investigate with `get` and `describe` for Pods, ReplicaSets and Deployments.

## Troubleshooting Services

1. If the spec isn't valid you'll get a useful error from Kubectl

2. The relationship between Services, Pods and container ports is what you need to investigate.

3. A port forward is a useful way of checking the application Pod directly.

> Need more? Here's the [solution](solution.md).