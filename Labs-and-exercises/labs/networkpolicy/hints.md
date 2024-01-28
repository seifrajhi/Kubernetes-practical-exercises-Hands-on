# Lab Hints

The [NetworkPolicy API spec](https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#networkpolicy-v1-networking-k8s-io) includes namespace selectors in policy rules, which apply before the Pod selectors.

You'll need to include the namespace in both ingress and egress rules.

The existing policies do something similar already for accesss to the DNS server.

> Need more? Here's the [solution](solution.md).