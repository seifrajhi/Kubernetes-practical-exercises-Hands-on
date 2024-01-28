# Lab Hints

Deployments and Services are loosely-coupled to Pods using labels. 

App name and version are common labels to apply, and you can use them in combination to have multiple Pods running, with the Service only sending traffic to a subset of them.

One Deployment cannot manage sets of Pods with different labels, so you'll need to think about how you structure your application model.

And if you're still running Pods and Services from the exercises, be careful with your labels so they don't clash.

> Need more? Here's the [solution](solution.md).