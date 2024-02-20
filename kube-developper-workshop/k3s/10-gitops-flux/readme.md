# 🧬 GitOps & Flux

This is an advanced optional section going into two topics; Kustomize and also GitOps, using FluxCD.

## 🪓 Kustomize

Kustomize is a tool for customizing Kubernetes configurations.

Kustomize traverses Kubernetes manifests to add, remove or update configuration options. It is
available both as a [standalone binary](https://kubectl.docs.kubernetes.io/installation/kustomize/)
and as a native feature of kubectl. It can be thought of as similar to Helm where it provides a means
to template and parameterize Kubernetes manifests.

Kustomize works by looking for `kustomization.yaml` files and operating on their contents.

[These slides](https://speakerdeck.com/spesnova/introduction-to-kustomize) provide a fairly good
introduction.

To demonstrate Kustomize in practice, we can carry out a simple exercise, create a new directory
called `base`.

Place the the following two files into it:

<details markdown="1">
<summary>Contents of base/deployment.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver
spec:
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      labels:
        app: webserver
    spec:
      containers:
        - name: webserver
          image: nginx
          resources:
            limits:
              memory: "128Mi"
              cpu: "500m"
          ports:
            - containerPort: 80
```

</details>

<details markdown="1">
<summary>Contents of base/kustomization.yaml</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
```

</details>

Now run kustomize via kubectl, giving it the path to the base directory as follows:

```bash
kubectl kustomize ./base
```

You will see the YAML printed to stdout, as we've not provided any changes in the `kustomization.yaml`
all we get is a 1:1 version of the `deployment.yaml` file. This isn't very useful! 😬

To better understand what Kustomize can do, create a second directory at the same level as `base`
called `overlay`.

<details markdown="1">
<summary>Contents of overlay/override.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver

spec:
  template:
    spec:
      containers:
        - name: webserver
          resources:
            limits:
              cpu: 330m
          env:
            - name: SOME_ENV_VAR
              value: Hello!
```

</details>

<details markdown="1">
<summary>Contents of overlay/kustomization.yaml</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Reference to a base kustomization directory
resources:
  - ../base

# You can add suffixes and prefixes
nameSuffix: -dev

# Modify the image name or tags
images:
  - name: nginx
    newTag: 1.21-alpine

# Apply patches to override and set other values
patches:
  - ./override.yaml
```

</details>

Some points to highlight:

- The _Kustomization_ adds a suffix to the names of resources.
- Also the _Kustomization_ changes the image tag to reference a specific tag.
- The patch `override.yaml` file looks a little like a regular Kubernetes _Deployment_ but it only
  contains the part that will be patched/overlayed onto the base resource. On its own it's not a
  valid manifest.
  - The patch file sets fields in the base _Deployment_ such as changing the resource limits and
    adding an extra environmental variable.

See the [reference docs](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/) for
all the options available in the `kustomization.yaml` file.

The file & directory structure should look as follows:

```text
├── base
│   ├── deployment.yaml
│   └── kustomization.yaml
└── overlay
    ├── kustomization.yaml
    └── override.yaml
```

> 📝 NOTE: The names "base" and "overlay" are not special, often "environments" is used instead of
> "overlay", with sub-directories for each environment

Now running:

```bash
kubectl kustomize ./overlay
```

You will now see the overrides and modifications from the overlay applied to the base resources. With
the modified nginx image tag, different resource limits and additional env var.

This could be applied to the cluster with the following command `kubectl -k ./overlay apply`, however
there is no need to do this.

An interesting feature of kustomize you may want to check out is [variable substitution](https://fluxcd.io/flux/components/kustomize/kustomization/#variable-substitution).

## GitOps & Flux

GitOps is a methodology where you declaratively describe the entire desired state of your system using
git. This includes the apps, config, dashboards, monitoring and everything else. This means you can
use git branches and PR processes to enforce control of releases and provide traceability and
transparency.

![gitops](./gitops.png)

Kubernetes doesn't support this concept out of the box, it requires special controllers to be deployed
and manage this process. These controllers run inside the cluster, monitor git repositories for changes
and then make the required updates to the state of the cluster, through a process called reconciliation.

We will use the popular project [FluxCD](https://fluxcd.io/) (also just called Flux or Flux v2), however
other projects are available such as ArgoCD and support from GitLab.

As GitOps is a "pull" vs "push" approach, it also allows you to lock down your Kubernetes cluster,
and prevent developers and admins making direct changes with kubectl.

> 📝 NOTE: GitOps is a methodology and an approach, it is not the name of a product.

### 💽 Install Flux into K3s VM

You can install the [Flux](https://fluxcd.io/flux/installation/) CLI with:

```sh
 curl -s https://fluxcd.io/install.sh | sudo bash
 # Flux auto complete to .bashrc
 echo "command -v flux >/dev/null && . <(flux completion bash)" >> ~/.bashrc
. ~/.bashrc

```

Before we configure anything GitOps needs a git repo to work against. We'll use a fork of this repo,
to set this up:

- Got to the repo for this workshop <https://github.com/benc-uk/kube-workshop>
- Fork the repo to your own personal GitHub account, by clicking the 'Fork' button near the top right.

Now to install and set up Flux in your cluster, run the following command, replacing the `{YOUR_GITHUB_USER}`
part with your GitHub username you used for the fork:

```bash
# Install flux in the cluster, create flux pods, ect.
flux install

flux create source git kubeworkshop \
    --url="https://github.com/{YOUR_GITHUB_USER}/kube-workshop" \
    --branch=main \
    --interval=1m

flux create kustomization apps \
    --path="gitops/apps" \
    --source=kubeworkshop \
    --prune=true \
    --interval=1m
```

Check the status of Flux with the following commands:

```bash
kubectl get kustomizations -A

flux get kustomization

kubectl get gitrepo -A

kubectl get pod -n flux-system
```

Good for troubleshooting:

```sh
flux logs
kubectl get events -n flux-system
```

> More tips and tricks: [Flux Troubleshooting cheatsheet](https://fluxcd.io/docs/cheatsheets/troubleshooting/#getting-basic-information).

You should also see a new namespace called "hello-world", check with `kubectl get ns` this has been
created by the `gitops/apps/hello-world.yaml` file in the repo and automatically applied by Flux.

In addition, your cluster now has flux components installed, such as pods, which you can view with
`kubectl get pods -n flux-system`.

### 🚀 Deploying Resources

Clone the kube-workshop repo you forked earlier and open the directory in VS Code or other editor.

If you recall from the bootstrap command earlier we gave Flux a path within the repo to use and look
for configurations, which was `gitops/apps` directory. The contents of the whole of the `gitops`
directory is shown here.

```text
gitops
  ├── apps
  │   └── hello-world.yaml
  ├── base
  │   ├── data-api
  │   │   ├── deployment.yaml
  │   │   ├── kustomization.yaml
  │   │   └── service.yaml
  │   ├── frontend
  │   │   ├── deployment.yaml
  │   │   ├── ingress.yaml
  │   │   ├── kustomization.yaml
  │   │   └── service.yaml
  │   └── mongodb
  │       ├── kustomization.yaml
  │       └── mongo-statefulset.yaml
  └── disabled-k3s
      ├── mongodb
      │   ├── kustomization.yaml
      │   └── overrides.yaml
      └── smilr
          └── kustomization.yaml
```

The base directory provides us a library of Kustomization based resources we can use, but as it's
outside of the `gitops/apps` path they will not be picked up by Flux.

⚠️ **STOP!** Before we proceed, ensure the `mongo-creds` _Secret_ from the previous sections is still
in the default namespace. If you have deleted it, hop back to [section 7](../07-improvements/readme.md)
and quickly create it again. It's just a single command. Creating _Secrets_ using the GitOps approach
is problematic, as they need to be committed into a code repo. Flux supports solutions to this, such
as using [SOPS](https://fluxcd.io/docs/guides/mozilla-sops/) and
[Sealed Secrets](https://fluxcd.io/docs/guides/sealed-secrets/). For an intro such as this workshop,
they require too much extra setup, so we will skip over them.

First let's deploy MongoDB using Flux:

- Copy the `monogodb/` directory from "disabled-k3s" to "apps".
  - Note the `kustomization.yaml` in here is pointing at the base directory `../../base/mongodb` and
    overlaying it.
- `git commit` these changes to the main branch and push up to GitHub.
- Wait for ~1 minute for Flux to rescan the git repo.
- Check for any errors with `kubectl get kustomizations -A`.
- Check the default namespace for the new MongoDB StatefulSet and Pod using
  `kubectl get sts,pods -n default`.

Next deploy the Smilr app:

- Copy the `smilr/` directory from `disabled-k3s` to `apps`.
  - Note the `kustomization.yaml` in here is pointing at **several** base directories, for the app's
    data-api and frontend.
- Edit the ACR name in the `gitops/apps/smilr/kustomization.yaml` file.
- `git commit` these changes to the main branch and push up to GitHub.
- Wait for ~1 minute for Flux to rescan the git repo.
- Check for any errors with `kubectl get kustomizations -A`.
- Check the default namespace for the new resources using `kubectl get deploy,pods,ingress -n default`.

In the `smilr` folder we're using [kustomize patching](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/patches/#patch-using-path-json6902)
to modify the deployments to work on our k3s clusters.

If you encounter problems or want to force the reconciliation you can use the `flux` CLI, e.g.
`flux reconcile source git kubeworkshop`.

If we wanted to deploy this app across multiple environments or multiple times, we could create
sub-directories under `apps/`, each containing different Kustomizations and modifying the deployment
to suit that environment.

🧪 **Experiment**: Try deleting one of the deployments and watch it be brought back to life with
`flux` reconcile. You can speed up the recreation with `flux reconcile kustomization apps`.

## Navigation

[Return to Main Index 🏠](../../readme.md)
[Previous Section ⏪](../09-extra-advanced/readme.md) ‖ [Next Section ⏩](../11-cicd-actions/readme.md)
