# A placeholder section

## 💾 Install Tools

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv ./kubectl /usr/bin/kubectl
```

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 🥾 Bootstrap Flux Into Cluster

[Generate a GitHub personal access token](https://github.com/settings/tokens) (PAT) that can create repositories by checking all permissions under "repo", copy the token and set it into an environmental variable called `GITHUB_TOKEN`

```bash
export GITHUB_TOKEN={NEW_TOKEN_VALUE}
```

Now fork this repo [github.com/benc-uk/kube-workshop](https://github.com/benc-uk/kube-workshop) to your own GitHub personal account.

Run the Flux bootstrap which should point to your fork by setting the owner parameter to your GitHub username:

```bash
flux bootstrap github \
  --owner=__CHANGE_ME__ \
  --repository=kube-workshop \
  --path=gitops/apps \
  --branch=main \
  --personal
```

Check the status of Flux with the following commands:

```bash
kubectl get kustomizations -A

kubectl get gitrepo -A

kubectl get pod -n flux-system
```

You should also see a new namespace called "hello-world", check with `kubectl get ns` this has been created by the `gitops/apps/hello-world.yaml` file in the repo and automatically applied by Flux
