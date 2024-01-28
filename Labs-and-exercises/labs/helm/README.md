# Packaging and Deploying Apps with Helm

Helm adds a templating language on top of the standard Kubernetes YAML. You turn your object specs into templates with variables for values which need to change between releases or environments - like the image tag to use, or the number of replicas. Helm has its own CLI which you use to install and upgrade apps, but the deployed objects are standard Kubernetes resources you can manage with Kubectl.

Application packages in Helm are called charts, and you can install a chart from a local folder, a compressed archive, or from a remote chart repository (similar to Docker Hub, but for apps). Charts just contain the YAML templates so they're small downloads - container images are still pulled from the image registry.

## Reference

- [Helm documentation](https://helm.sh/docs/)

- [Helm CLI commands](https://helm.sh/docs/helm/helm/)

- [Chart structure and contents](https://helm.sh/docs/topics/charts/)

- [Template functions and pipelines](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/)

## Install Helm CLI

Helm uses the same context configuration as Kubectl to connect to your Kubernetes cluster(s). To start with you need to install the Helm CLI:

- Use the install instructions https://helm.sh/docs/intro/install/ **OR**

The simple way, if you have a package manager installed:

```
# On Windows using Chocolatey:
choco install kubernetes-helm

# On MacOS using brew:
brew install helm

# On Linux:
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

Test you have the CLI working:

```
helm version --short
```

> You should see a version number.

_You shouldn't use versions of Helm earlier than v3. Older versions needed a server component running in Kubernetes, which was a security issue. From v3 onwards, Helm is a purely client-side tool which only needs the CLI._

## Deploy a chart with default values

Here's a simple Helm chart for the whoami app. The release name is used in the object names, so the same app can be deployed multiple times.

- [Chart.yaml](./charts/whoami/Chart.yaml) - describes the application; these are a standard Helm fields
- [values.yaml](./charts/whoami/values.yaml) - defines the default values for custom fields used in the templates
- [templates/deployment.yaml](./charts/whoami/templates/deployment.yaml) - the templated Deployment object, using variables for custom values (e.g. `.Values.imageTag` and standard objects (e.g. `.Release.Name`)
- [templates/service.yaml](./charts/whoami/templates/service.yaml) - the templated Service

📋 Use Helm to install the chart from the `labs/helm/charts/whoami` folder, calling the release `whoami-default`.

<details>
  <summary>Not sure how?</summary>

To install a chart with default values, just give it a name and the location of the chart:

```
helm install whoami-default labs/helm/charts/whoami
```

</details><br/>

List your Helm releases, and check the Kubernetes objects:

```
helm ls

kubectl get all -l app.kubernetes.io/managed-by=Helm
```

> You have one release installed, which created the Kubernetes Service and Deployment. The object names are based on the Helm release name.

📋 Confirm this chart could be deployed again with a new release name - check the labels applied to the Pod, and the label selector used by the Service.

<details>
  <summary>Not sure how?</summary>

```
kubectl get po -o wide --show-labels

kubectl describe svc whoami-default-server 
```

</details><br/>

> Two Pods are in the Service endpoints. The selector label comes from the release name, so a second release would not interfere with this one.

Try the app:

```
curl localhost:30028
```

If you repeat the call you'll see responses load-balanced between Pods. The replica count and server mode are variables, currently using the default settings in the values file.

## Install a release with custom values

Any field in the values file can be overridden when you install or upgrade a release, using the `set` flag with the Helm CLI.

- [values.yaml](./charts/whoami/values.yaml) - contains all the variable names for the whoami app, together with the default values

📋 Install a new release from the same whoami chart, called `whoami-custom`. Set the replica count to 1 and the Service port to `30038`.

<details>
  <summary>Not sure how?</summary>

You can use multiple `set` flags, providing the variable name and value:

```
helm install whoami-custom --set replicaCount=1 --set serviceNodePort=30038 labs/helm/charts/whoami
```

</details><br/>

Validate your new release of the app is deployed:

```
helm ls

kubectl get pods -l component=server -L app
```

> You should see one Pod with the app label `whoami-custom`, and two with the label `whoami-default`.

Your new Service should be listening at the specified port:

```
curl localhost:30038
```

## Upgrade a release with custom values

You can upgrade a release with the Helm CLI. You do this to update to a new chart version, or use the same chart and change the deployed values.

Try to update the custom release, settings a new value for the server mode:

```
# this will fail:
helm upgrade whoami-custom --set serverMode=V labs/helm/charts/whoami
```

> Custom values from the install are not reused. The upgrade tries to change the port value from the custom one to the default, which is already in use from the other release.

📋 Repeat the upgrade command, but add a flag  so Helm will reuse the values from the original install command.

<details>
  <summary>Not sure how?</summary>

The [Helm upgrade options](https://helm.sh/docs/helm/helm_upgrade/#options) provide the `reuse-values` flag:

```
helm upgrade whoami-custom --reuse-values --set serverMode=V labs/helm/charts/whoami
```

</details><br/>

> Now the custom port from the install is reused, and only the server mode is changed.

Try the app now:

```
curl localhost:30038
```

Check the ReplicaSets for the custom install and you can see that Helm just makes changes to the Kubernetes objects - the Deployment got updated and it rolled out the change in the usual way:

```
kubectl get rs -l app=whoami-custom
```


📋 You can also use Helm to roll back releases. Check the history of the custom app and roll back to the first revision.

<details>
  <summary>Not sure how?</summary>

The [history](https://helm.sh/docs/helm/helm_history/) command lists all the revisions of the release, and the [rollback](https://helm.sh/docs/helm/helm_rollback/) command reverts to a previous revision.

```
helm history whoami-custom

helm rollback whoami-custom 1
```

</details><br/>

After the rollback, check the ReplicaSets and you'll see the original has scaled back up:

```
kubectl get rs -l app=whoami-custom
```

And the app is working with the "quiet" server mode:

```
curl localhost:30038
```

## Using chart repositories

Some teams use Helm to package their own apps - others stick with YAML files and only use Helm to deploy third-party apps. 

Projects like [Prometheus](https://prometheus-community.github.io/helm-charts/) and the [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm) publish packages as Helm charts, which makes it easy for you to install a production-grade release.

Charts are published in repositories, which can be public or private. Start by adding a simple repo:

```
helm repo ls

helm repo add kiamol https://kiamol.net

helm repo update
```

> Adding and updating chart repositories is similar to package managers like APT and APK on Linux.

📋 Search the repositories for a chart called `vweb`, and list the default values for the version `2.0.0` chart.

<details>
  <summary>Not sure how?</summary>

The search command looks across all repos:

```
helm search repo vweb --versions
```

> There are two version numbers for each line - the app version and the chart version. Charts can evolve independently, so the same app version might have multiple charts.

Default values are packaged in the chart, and you can print them from the CLI, using the repo name and chart details:

```
helm show values kiamol/vweb --version 2.0.0
```

</details><br/>

The values file is YAML, so it can contain comments - very helpful for users.

📋 Install a release called `vweb` from the `kiamol/vweb` chart at version `2.0.0`, using a NodePort service listening on port 30039.

<details>
  <summary>Not sure how?</summary>

It's the same install command, specifying the chart version and the location includes the repo name:

```
helm install --set replicaCount=1 --set serviceType=NodePort --set servicePort=30039 vweb kiamol/vweb --version 2.0.0
```

</details><br/>

List the Services to confirm the deployment:

```
kubectl get svc -l app.kubernetes.io/instance=vweb
```

> You should be able to browse to the app at http://localhost:30039. It's not very exciting.

Upgrades don't have to use a newer version. You can downgrade to the version `1.0.0` chart of this app, but it might not do what you think.

📋 Check the default values for the `1.0.0` release, and upgrade to that version. How do you access the site now?

<details>
  <summary>Not sure how?</summary>

```
helm show values kiamol/vweb --version 1.0.0

# the v1 chart doesn't let you choose the service type, only the port

helm upgrade --reuse-values vweb kiamol/vweb --version 1.0.0
```

</details><br/>

> The "upgrade" works, but the v1 chart doesn't have a variable for the Service type, it's fixed as LoadBalancer. The app is still available at http://localhost:30039, but only if your cluster supports LoadBalancer services. 

## Lab

You can use a local values file to override the defaults in a chart, instead of using lots of `set` arguments. 

This values file is suitable for the Nginx ingress controller chart in a local environment:

- [labs/helm/ingress-nginx/dev.yaml](./ingress-nginx/dev.yaml)

Install the Nginx Ingress controller from the public Helm chart, using at least version `1.3.0` of the app. Use a new namespace called `ingress`. Browse to the HTTP endpoint and confirm you get a response from Nginx.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup

Remove all the Helm releases:

```
helm uninstall vweb whoami-custom whoami-default

helm uninstall ingress-nginx -n ingress

kubectl delete ns ingress
```