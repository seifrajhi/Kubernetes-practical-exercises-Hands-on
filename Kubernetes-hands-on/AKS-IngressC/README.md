<div align=center>

# Setting up access with NGINX - step by step

<a href="https://github.com/Kriyamlnamohan-Yerrabilli/Kubernetes-hands-on/edit/master/AKS-IngressC">
    <img src="https://user-images.githubusercontent.com/58173938/197652617-bd95adab-38a1-480f-805d-96fd7a1184ed.png" alt="Logo" width="850" height="550">
</a>

</div>	
<br>

There are many `Ingress-controllers models`, but `NGINX` is a widely used 
ingress controller, we will look at how to set it up with Azure Kubernetes 
Service. We'll set up two simple `web services` and use `NGINX ingress` to `route 
traffic` accordingly.


Step 1: Set up your `AKS cluster` and connect to it

    To do this, browse to the AKS cluster resource in the Azure portal 
    and click Connect. The commands required to connect through your 
    yamlell using the Azure CLI are yamlown.

Step 2: Install the `NGINX Ingress` controller

    This will install the controller into the ingress-nginx namespace, 
    creating that namespace if it doesn't already exist.

```yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml

```

```yaml
namespace/ingress-nginx created 
serviceaccount/ingress-nginx created 
serviceaccount/ingress-nginx-admission created 
role.rbac.authorization.k8s.io/ingress-nginx created 
role.rbac.authorization.k8s.io/ingress-nginx-admission created 
clusterrole.rbac.authorization.k8s.io/ingress-nginx created 
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created 
rolebinding.rbac.authorization. k8s.io/ingress-nginx created 
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created 
clusterrolebinding.rbac.authorization. k8s.io/ingress-nginx created 
clusterrolebinding.rbac.authorization. k8s.io/ingress-nginx-admission created 
configmap/ingress-nginx-controller created 
service/ingress-nginx-controller created 
service/ingress-nginx-controller-admission created 
deployment.apps/ingress-nginx-controller created 
job.batch/ingress-nginx-admission-create created 
job.batch/ingress-nginx-admission-patch created 
ingressclass.networking.k8s.io/nginx created 
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created 

```

Step 3: Check the Ingress controller pod is running

```yaml
kubectl get pods --namespace ingress-nginx
```

```yaml
Name                                         Ready   Status      Restarts   AGE
ingress-nginx-admission-create--1-3fh4s      0/1     Completed   0          10m
ingress-nginx-admission-patch--1-ts9ci       0/1     Running     0          10m
ingress-nginx-controller-55dcf56b68-ojdkn    1/1     Running     0          10m

```
Step 4: Check the `NGINX Ingress controller` has been assigned a public Ip address

You can see the `Service` type is `LoadBalancer`

```yaml
NAME                                        TYPE            CLUSTER-IP      EXTERNAL-IP     PORT(S)                        AGE  
ingress-nginx-controllerLoadBalancer        LoadBalancer    10.0.125.458    20.246.472.416  80:31170/TCP,443:32018/TCP     12m

```

    When you try to connect to this IP address, it will yamlow you an NGINX 404 page. 
    Because we haven't set up any routing rules for our services yet


Step 5 – Now setting up a basic web app for testing our new Ingress controller

First, we need to set up a `DNS record` pointing to the `External IP`
address we `discovered` in the previous step.

```yaml
Step 1: DNS Zone Creation
Step 2: Managed Identity Creation
Step 3: Create azure.json file
Step 4: Associate MSI in AKS cluster VMSS
Step 5: Create kubernetes secret
Step 6: Create external-dns.yaml manifest and deploy it 
Step 7: Deploy a demo application and test it
```

Once that is set, run the following command to set up a demo 
(replace the [DNS_NAME] with your record)

Note that you must set up a DNS record, this step will not work 
with an IP address.

we'll look at `declarative approaches` later in this article.

```yaml
kubectl create ingress demo --class=nginx --rule [DNS_NAME]/=demo:80
```

Step 6: Browse to the web address

    You'll see 'It works!' displayed, confirming that the ingress controller is routing 
    traffic correctly to the demo app.

Step 7: Set up two more web apps

Now we'll set up two more web apps and route traffic between them using NGINX.

We will create two YAML files using the demo apps from the official Azure documentation.


[aks-hwo.yaml](https://github.com/Kriyamlnamohan-Yerrabilli/Kubernetes-hands-on/blob/master/AKS-IngressC/aks-hwo.yml)

[aks-hwo2.yaml](https://github.com/Kriyamlnamohan-Yerrabilli/Kubernetes-hands-on/blob/master/AKS-IngressC/aks-hwo2.yml)


Apply the two configuration files to setup the apps:

```yaml
kubectl apply -f aks-hwo.yaml --namespace ingress-nginx
kubectl apply -f aks-hwo2.yaml --namespace ingress-nginx
```
Output 

```yaml
deployment.apps/aks-helloworld-one created
service/aks-helloworld-one created
```

```yaml
deployment.apps/aks-helloworld-two is created
service/aks-helloworld-two is created
```


Check that the new pods are running 
(now you can see two aks-helloworld pods are running):

```yaml
kubectl get pods --namespace ingress-nginx
```

```yaml
Name                                         Ready   Status      Restarts   AGE
aks-helloworld-one-nd5evg58a6-d31d4          1/1     Running     0          19m
aks-helloworld-two-5dz3fvesda-krs8s          1/1     Running     0          19m
ingress-nginx-admission-create--1-3fh4s      0/1     Completed   0          57m
ingress-nginx-admission-patch--1-ts9ci       0/1     Running     0          57m
ingress-nginx-controller-55dcf56b68-ojdkn    1/1     Running     0          57m
```

Step 8: Set up `Ingress` to route traffic between the two apps

We set up path-based routing to direct traffic to the appropriate web apps based 
on the URL entered by the user. EXTERNAL_IP/hello-world-one Redirected to a service 
named aks-helloworld-one. Traffic to `EXTERNAL_IP/hello-world`-to is redirected to the 
`aks-helloworld-two` service. Where the user (EXTERNAL_IP/) does not specify a route, 
traffic is redirected to aks-helloworld-one.(we set this to default) if user does not
specify what route wants to connect


[hw-ingress.yaml](https://github.com/Kriyamlnamohan-Yerrabilli/Kubernetes-hands-on/blob/master/AKS-IngressC/hw-ingress.yml)

Now it's time to `Create Ingress`, apply the below command 

```yaml
kubectl apply -f hw-ingress.yaml --namespace ingress-nginx
```

```yaml
ingress.networking.k8s.io/hw-ingress created
ingress.networking.k8s.io/hw-ingress-static created
```
Now check the static IP that you received and!paste it on browser

![Azure-ingress-application-routing](https://user-images.githubusercontent.com/58173938/196035205-08c2fcd4-b093-44ca-b0f6-38f7b1a13103.png)

Tada Congratulations you successfully setup and created a working Nginx-ingressC :)

Hope it helps, happy learning!