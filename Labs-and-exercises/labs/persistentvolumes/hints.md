# Lab Hints

Here are the [types of volume](https://kubernetes.io/docs/concepts/storage/volumes/) you can use in a Pod spec.

If you can find one which gives you access to a path on the host node, then you can use that with the sleep image to run a container which can access the node's disk.

> Need more? Here's the [solution](solution.md).