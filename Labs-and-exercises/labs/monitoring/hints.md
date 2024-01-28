# Lab Hints

You'll need to change the Prometheus ConfigMap to add new scrape jobs for the new targets. The Pods are in the `kube-system` namespace and they each have an `app` label.

Prometheus config isn't straightforward, but you can use this as a starting point, replacing the angled-brackets:

```
      - job_name: '<x>'
        kubernetes_sd_configs:
         - role: pod 
        relabel_configs:
         - source_labels: 
            - __meta_kubernetes_namespace
            - __meta_kubernetes_pod_labelpresent_app
            - __meta_kubernetes_pod_label_app
           action: keep
           regex: <ns>;true;<app>
```

Prometheus doesn't reload the config file when it changes, so you'll need to force a Pod update.

> Need more? Here's the [solution](solution.md).