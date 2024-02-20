# 🌎 Helm & Ingress

For this section we'll touch on two slightly more advanced topics, the key ones being the use of Helm and introducing an ingress controller to our cluster.
The ingress will let us further refine & improve the networking aspects of the app we've deployed.

## 🗃️ Namespaces

So far we've worked in a single _Namespace_ called `default`, but Kubernetes allows you create additional _Namespaces_ in order to logically group and separate your resources.

> 📝 NOTE: Namespaces do not provide a network boundary or isolation of workloads, and the underlying resources (Nodes) remain shared.
> There are ways to achieve these outcomes, but is well beyond the scope of this workshop.

Create a new namespace called `ingress`:

```bash
kubectl create namespace ingress
```

Namespaces are simple idea but they can trip you up, you will have to add `--namespace` or `-n` to any `kubectl` commands you want to use against a particular namespace.
The following alias can be helpful to set a namespace as the default for all `kubectl` commands, meaning you don't need to add `-n`, think of it like a Kubernetes equivalent of the `cd` command.

```bash
# Note the space at the end
alias kubens='kubectl config set-context --current --namespace '
```

## ⛑️ Introduction to Helm

[Helm is an CNCF project](https://helm.sh/) which can be used to greatly simplify deploying applications to Kubernetes, either applications written and developed in house, or external 3rd party software & tools.

- Helm simplifies deployment into Kubernetes using _charts_, when a chart is deployed it is refereed to as a _release_.
- A _chart_ consists of one or more Kubernetes YAML templates + supporting files.
- Helm charts support dynamic parameters called _values_. Charts expose a set of default _values_ through their `values.yaml` file, and these _values_ can be set and over-ridden at _release_ time.
- The use of _values_ is critical for automated deployments and CI/CD.
- Charts can referenced through the local filesystem, or in a remote repository called a _chart repository_.
  The can also be kept in a container registry but that is an advanced and experimental topic.
- To use Helm, the Helm CLI tool `helm` is required.

Well add the Helm chart repository for the ingress we will be deploying, this is done with the `helm repo` command.
This is a public repo & chart of the extremely popular NGINX ingress controller (more on that below).

> 📝 NOTE: The repo name `ingress-nginx` can be any name you wish to pick, but the URL has to be pointing to the correct place.

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update
```

## 🚀 Deploying The Ingress Controller

An [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) provides a reliable and secure way to route HTTP and HTTPS traffic into your cluster and expose your applications from a single point of ingress; hence the name.

![Ingress controller diagram showing routing of traffic to backend services](./kuberntes-ingress.png)

- The controller is simply an instance of a HTTP reverse proxy running in one or mode _Pods_ with a  _Service_ in front of it.
- It implements the [Kubernetes controller pattern](https://kubernetes.io/docs/concepts/architecture/controller/#controller-pattern) 
scanning for _Ingress_ resources to be created in the cluster, when it finds one, it reconfigures itself based on the rules and configuration within that _Ingress_, in order to route traffic.
- There are [MANY ingress controllers available](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/#additional-controllers) but we will use a very common and simple one, the [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/) maintained by the Kubernetes project.
- Often TLS is terminated by the ingress controller, and sometimes other tasks such as JWT validation for authentication can be done at this level.
  For the sake of this workshop no TLS & HTTPS will be used due to the dependencies it requires (such as DNS, cert management etc).

Helm greatly simplifies setting this up, down to a single command. Run the following:

```bash
helm install my-ingress ingress-nginx/ingress-nginx \
  --namespace ingress \
  --set controller.replicaCount=2
```

- The release name is `my-ingress` which can be anything you wish, it's often used by chart templates to prefix the names of created resources.
- The second parameter is a reference to the chart, in the form of `repo-name/chart-name`, if we wanted to use a local chart we'd simply reference the path to the chart directory.
- The `--set` part is where we can pass in values to the release, in this case we increase the replicas to two, purely as an example.

Check the status of both the pods and services with `kubectl get svc,pods --namespace ingress`, ensure the pods are running and the service has an external public IP.

You can also use the `helm` CLI to query the status, here's some simple and common commands:

- `helm ls` or `helm ls -A` - List releases or list releases in all namespaces.
- `helm upgrade {release-name} {chart}` - Upgrade/update a release to apply changes. Add `--install`
  to perform an install if the release doesn't exist.
- `--dry-run` - Add this switch to install or upgrade commands to get a view of the resources and
  YAML that would be created, without applying them to the cluster.
- `helm get values {release-name}` - Get the values that were used to deploy a release.
- `helm delete {release-name}` - Remove the release and all the resources.

## 🔀 Reconfiguring The App With Ingress

Now we can modify the app we've deployed to route through the new ingress, but a few simple changes
are required first. As the ingress controller will be routing all requests, the services in front of
the deployments should be switched back to internal i.e. `ClusterIP`.

- Edit both the data API & frontend **service** YAML manifests, change the service type to `ClusterIP`
  then reapply with `kubectl apply`
- Edit the frontend **deployment** YAML manifest, change the `API_ENDPOINT` environmental variable
  to use the same origin URI `/api` no need for a scheme or host.

Apply these three changes with `kubectl` and now the app will be temporarily unavailable. Note, if
you have changed namespace with `kubens` you should switch back to the **default** namespace before
running the apply.

The next thing is to configure the ingress by [creating an _Ingress_ resource](https://kubernetes.io/docs/concepts/services-networking/ingress/).
This can be a fairly complex resource to set-up, but it boils down to a set of HTTP path mappings
(routes) and which backend service should serve them.
Here is the completed manifest file `ingress.yaml`:

<details markdown="1">
<summary>Click here for the Ingress YAML</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: my-app
  labels:
    name: my-app

spec:
  # Important we leave this blank, as we don't have DNS configured
  # Blank means these rules will match ALL HTTP requests hitting the controller IP
  host:
  # This is important and required since Kubernetes 1.22
  ingressClassName: nginx
  rules:
    - http:
        paths:
          # Routing for the frontend
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: frontend
                port:
                  number: 80

          # Routing for the API
          - pathType: Prefix
            path: "/api"
            backend:
              service:
                name: data-api
                port:
                  number: 80
```

</details>
</br>

Apply the same as before with `kubectl`, validate the status with:

```bash
kubectl get ingress
```

It may take it a minute for it to be assigned an address, note the address will be the same as the external IP of the ingress-controller.
You can check this with:

```sh
kubectl get svc -n ingress | grep LoadBalancer
```

Visit this IP in your browser, if you check the "About" screen and click the "More Details" link it
should take you to the API, which should now be served from the same IP as the frontend.

## 🖼️ Cluster & Architecture Diagram

We've reached the final state of the application deployment. The resources deployed into the cluster
& in Azure at this stage can be visualized as follows:

![architecture diagram](./diagram.png)

This is a slightly simplified version from previously, and the _Deployment_ objects are not shown.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../07-improvements/readme.md) ‖ [Next Section ⏩](../09-extra-advanced/readme.md)
