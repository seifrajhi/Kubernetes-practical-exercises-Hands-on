# Lab Hints

The first part isn't too complicated, you just need to map ingress rules for the application's Service. Be aware that the app is in its own namespace. 

The second part you can only do if you're using LoadBalancer services. You'll need to change the Service ports and this is a good chance to explore the Ingress controller spec.

> Need more? Here's the [solution](solution.md).