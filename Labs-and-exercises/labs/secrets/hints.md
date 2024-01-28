# Lab Hints

There are two common approaches for this. One preserves your config changes by keeping old objects in Kubernetes, rather than updating the Secret for each update.

The other updates the existing secret and uses metadata to trigger the Deployment change.

Deployments only trigger a Pod rollout if the Pod spec changes. 

> Need more? Here's the [solution](solution.md).