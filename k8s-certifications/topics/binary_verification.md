# Verify Platform Binaries

- Kubernetes provides the binaries and their checksum hash for us the verify the authenticity of the same.
- Check the Kubernetes [CHANGELOG](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG)

<br />

### Download the https://dl.k8s.io/v1.22.0/kubernetes.tar.gz and verify the sha matches with `d1145ec29a8581a4c94a83cefa3658a73bfc7d8e2624d31e735d53551718c9212e477673f74cfa4e430a8367a47bba65e2573162711613e60db54563dc912f00`.

<br />

<details><summary>show</summary><p>

```bash
curl https://dl.k8s.io/v1.22.0/kubernetes.tar.gz -L -o kubernetes.tar.gz
shasum -a 512 kubernetes.tar.gz
# d1145ec29a8581a4c94a83cefa3658a73bfc7d8e2624d31e735d53551718c9212e477673f74cfa4e430a8367a47bba65e2573162711613e60db54563dc912f00  kubernetes.tar.gz
```

</p></details>

<br />