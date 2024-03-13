# [APIs](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)

<br />

### Get all `api-resource` and check the short names, api version.

<details><summary>show</summary><p>

```bash
kubectl api-resources
```
</p></details>

<br />

### Get the Api Group for `jobs` api

<details><summary>show</summary><p>

```bash
kubectl api-resources | grep jobs
#cronjobs                          cj           batch/v1beta1                          true         CronJob
#jobs                                           batch/v1                               true         Job
```

</p></details>

<br />

### Enable the `v1alpha1` version for `rbac.authorization.k8s.io` API group on the controlplane node.

<details><summary>show</summary><p>

Add `--runtime-config=rbac.authorization.k8s.io/v1alpha1` to the `/etc/kubernetes/manifests/kube-apiserver.yaml` file and let the kube-apiserver restart

</p></details>