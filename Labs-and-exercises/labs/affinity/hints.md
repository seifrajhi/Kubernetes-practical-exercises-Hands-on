# Lab Hints

The syntax for affinity rules is tricky, especially when you want to apply multiple rules. For node affinity:

-  you can express AND conditions with multiple clauses in the same match expression

- the preference syntax is different from Pod affinity - check the [affinity API spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#affinity-v1-core)

The order that you do things is important too - typically you want all your nodes labelled correctly before you deploy, so the scheduler has all the information it needs.

And finally, preferences mean the scheduler can make a judgement, so you may not be able to get the exact results (5-1 spread on the agent nodes).

> Need more? Here's the [solution](solution.md).