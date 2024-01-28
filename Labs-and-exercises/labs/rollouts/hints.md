# Lab Hints

The Helm chart creates the two Deployment objects and one Service. The Deployments use different Pod labels for the blue and green release, but the Service doesn't use those in its selector...

The variable `activeSlot` is already defined in the values file, so that's the one to use in your updated template.

When you move onto automatic rollbacks, Helm has a different way of decribing it. You want to specify an update which needs to complete successfully, or all the changes will be rolled back. And that needs a time limit too, because the new v3 Pods will get created but never become ready.

> Need more? Here's the [solution](solution.md).