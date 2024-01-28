# Controlling Admission

Admission control is the process of allowing - or blocking - workloads from running in the cluster. You can use this to enforce your own rules. You might want to block all containers unless they're using an image from an approved registry, or block Pods which don't include resource limits in the spec.

You can do this with admission controller webhooks - HTTP servers which run inside the cluster and get invoked by the API to apply rules when objects are created. Admission controllers can use your own logic, or can use a standard tool like [Open Policy Agent](https://www.openpolicyagent.org).

## Reference

- [Using admission controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [Creating self-signed SSL certs for webhook servers](https://cert-manager.io/docs/concepts/ca-injector/)
- [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/)
- [Gatekeeper policy library](https://github.com/open-policy-agent/gatekeeper-library)

## In-cluster webhook servers over HTTPS

Admission controller webhooks give you the most flexibility, because you can run any code you like. You'll typically run them inside the cluster using standard Deployment and Service objects.

**But** the Kubernetes API server will only call webhooks if they're served over HTTPS using a trusted certificate. A nice way to do that is with [cert-manager](https://cert-manager.io), a CNCF project which generates TLS certificates and creates them as Secrets.

- [cert-manager/1.5.3.yaml](./specs/cert-manager/1.5.3.yaml) - is from the cert-manager docs, it includes custom resources to create Certificates and all the RBAC, Services and Deployments to run the manager. It's complex - but definitely better than managing certs yourself

_Deploy cert-manager:_

```
kubectl apply -f labs/admission/specs/cert-manager
```

Cert-manager uses _Issuers_ to define how certificates get created. You can configure this to use a real certificate provider - e.g. Let's Encrypt - but we'll use a self-signed issuer:

- [issuers/self-signed.yaml](./specs/cert-manager/issuers/self-signed.yaml) - creates the issuer; this is a custom resource but this spec doesn't need any special config

📋 Create the issuer and print the details.

<details>
  <summary>Not sure how?</summary>

It's a custom resource, but it's all YAML to Kubernetes:

```
kubectl apply -f labs/admission/specs/cert-manager/issuers
```

And you work with it in the usual way:

```
kubectl get issuers

kubectl describe issuer selfsigned
```

You'll see a lot of output, including the status showing the issuer is ready to use.

</details><br/>

Our admission controller is a NodeJS web app, built to match the webhook API spec ([source code on GitHub](https://github.com/sixeyed/kiamol/tree/master/ch16/docker-images/admission-webhook/src)):

- [webhook-server/admission-webhook.yaml](./specs/webhook-server/admission-webhook.yaml) - defines a Deployment and Service. There's no RBAC or special permissions, this is a standalone web server - but it does run under HTTPS, expecting to find the TLS cert in a Secret

- [webhook-server/certificate.yaml](./specs/webhook-server/certificate.yaml) - will create the certificate using the self-signed issuer and store it in the Secret the Pod expects to use. cert-manager will take care of creating and rotating this cert.

📋 Deploy the webhook server and confirm the certificate Secret gets created.

<details>
  <summary>Not sure how?</summary>

The specs are in the `webhook-server` folder:

```
kubectl apply -f labs/admission/specs/webhook-server
```

Check the certificate objects:

```
kubectl get certificates
```

You should see that the cert is _Ready_ and the output shows the Secret name where it is stored:

```
kubectl describe secret admission-webhook-cert
```

The Secret contains the TLS certificate and key, and the CA certificate for the issuer.

</details><br/>

This is just a standard web server, so we can test the HTTPS setup by running a sleep Pod:

```
kubectl apply -f labs/admission/specs/sleep

# you'll get a security error here:
kubectl exec sleep -- curl https://admission-webhook.default.svc
```

> The error means the certificate has been applied, but curl doesn't trust the issuer

## Validating Webhooks

The admission controller is running, but it's not doing anything yet. It needs to be configured as a webhook for the Kubernetes API server to call:

- [validatingWebhookConfiguration.yaml](./specs/validating-webhook/validatingWebhookConfiguration.yaml) - configures Kubernetes to call the webhook on the `/validate` path when Pods are created or updated; the annotation is there to configure the self-signed cert as trusted.

This is a validating webhook - the logic in the server will block any Pods from being created, where the spec does not set the `automountServiceAccountToken` field to `false`. 

Apply the validating webhook:

```
kubectl apply -f labs/admission/specs/validating-webhook
```

Check the details and you'll see cert-manager has applied the CA cert from the certificate it generated:

```
kubectl describe validatingwebhookconfiguration servicetokenpolicy
```

Now the webhook is running, Kubernetes won't run any Pods that don't meet the rules - like the one in this [whoami app Deployment](./specs/whoami/deployment.yaml).

Create the application objects:

```
kubectl apply -f labs/admission/specs/whoami
```

📋 The app won't run. Debug it to find the error message generated by the admission controller.

<details>
  <summary>Not sure how?</summary>

Check the Deployment:

```
kubectl get deploy whoami

kubectl describe deploy whoami
```

There should be two Pods, but none are ready. The events show the ReplicaSet has been created and scaled up, so there are no errors here.

Check the RS:

```
kubectl describe rs -l app=whoami
```

Here you see the message from the admission controller:  _Error creating: admission webhook "servicetokenpolicy.courselabs.co" denied the request: automountServiceAccountToken must be set to false_

</details><br/>


This app won't fix itself - the ReplicaSet will keep trying to create Pods and they will keep getting rejected by the admission controller.

To get it running you need to change the Pod spec - you can edit the Deployment or apply [a new spec](./specs/whoami/fix/deployment.yaml) which meets the validation rules:

```
kubectl apply -f labs/admission/specs/whoami/fix

kubectl get po -l app=whoami --watch
```

> Now the Pods get created.

Validating webhooks are a powerful way of ensuring your apps meet your policies - any objects can be targetted and the whole spec is sent to the webhook, so you can use it for security, performance or reliability rules.

## Mutating Webhooks

Validating webhooks either allow an oject to be created or they block it. The other type of admission control is to silently edit the incoming object spec using a mutating webhook.

The webhook server we're running has mutation logic too:

- [mutatingWebhookConfiguration.yaml](./specs/mutating-webhook/mutatingWebhookConfiguration.yaml) - operates when Pods are created or updated, and calls the `/mutate` endpoint on the server.

Deploy the new webhook:

```
kubectl apply -f labs/admission/specs/mutating-webhook

kubectl describe mutatingwebhookconfiguration nonrootpolicy
```

> There's no information about what this policy actually does...

Try running another app - using this [spec for the Pi website](./specs/pi/pi.yaml):

```
kubectl apply -f labs/admission/specs/pi
```

📋 This app won't run either. Check the objects and the spec to try to find out what went wrong.

<details>
  <summary>Not sure how?</summary>

Look at the Pods:

```
kubectl get po -l app=pi-web
```

You'll see the status is _CreateContainerConfigError_. Check the Pod details:

```
kubectl describe po -l app=pi-web
```

You'll see an error message in the events: _Error: container has runAsNonRoot and image will run as root_.

That means the container image uses the root user by default, but the Pod spec is set with a security context so it won't run containers as root.

</details><br/>

The Pod spec in the Deployment doesn't say anything about non-root users, that's been applied by the mutating webhook.

You can get the app running by applying this [updated spec](./specs/pi/fix/pi-nonroot.yaml):

```
kubectl apply -f labs/admission/specs/pi/fix
```

## OPA Gatekeeper

Custom webhooks have two drawbacks: you need to write the code yourself, which adds to your maintenance estate; and their rules are not discoverable through the cluster, so you'll need external documentation.

OPA Gatekeeper is an alternative which implements admission control using generic rule descriptions (in a language called [Rego](https://www.openpolicyagent.org/docs/latest/policy-language/)).

We'll deploy admission rules with Gatekeeper - first delete all of the custom webhooks (ours and cert-manager's):

```
kubectl delete ns,all,ValidatingWebhookConfiguration,MutatingWebhookConfiguration -l kubernetes.courselabs.co=admission

kubectl delete crd,ValidatingWebhookConfiguration,MutatingWebhookConfiguration -l app.kubernetes.io/instance=cert-manager
```

OPA Gatekeeper is another complex component, where you trade the overhead of managing it with the issues of running your own controllers:

- [opa-gatekeeper/3.5.yaml](./specs/opa-gatekeeper/3.5.yaml) - deploys custom resources to describe admission rules, RBAC for the controller and a Service and Deployment to run it

_Deploy OPA:_

```
kubectl apply -f labs/admission/specs/opa-gatekeeper
```

📋 What custom resource types does Gatekeeper install?

<details>
  <summary>Not sure?</summary>

Check the CustomResourceDefinitions:

```
kubectl get crd
```

You'll see a few - the main one we work with is the ConstraintTemplate.

</details><br/>

There are two parts to applying rules with Gatekeeper:

1. Create a _ConstraintTemplate_ which defines a generic constraint (e.g. containers in a given namespace can only use a given image registry)

2. Create a _Constraint_ from the template (e.g.containers in namespace `apod` can only use images from `courselabs` repos on Docker Hub)

The rule definition is done with the Rego generic policy language:

- [requiredLabels-template.yaml](./specs/opa-gatekeeper/templates/requiredLabels-template.yaml) - defines a simple (!) template to require labels on an object

- [resourceLimits-template.yaml](./specs/opa-gatekeeper/templates/resourceLimits-template.yaml) - defines a more complex template requiring container objects to have resources set

Create the templates:

```
kubectl apply -f labs/admission/specs/opa-gatekeeper/templates
```

📋 Check the custom resources again; how do you think Gatekeeper stores constraints in Kubernetes?

<details>
  <summary>Not sure?</summary>

```  
kubectl get crd
```

You see new CRDs for the constraint templates:

```
policyresourcelimits.constraints.gatekeeper.sh

requiredlabels.constraints.gatekeeper.sh
```

Gatekeeper creates a CRD for each constraint template, so each constraint becomes a Kubernetes resource.

</details><br/>

Here are the constraints which use the templates:

- [requiredLabels.yaml](./specs/opa-gatekeeper/constraints/requiredLabels.yaml) - requires `app` and `version` labels on Pods, and a `kubernetes.courselabs.co` label on namespaces

- [resourceLimits.yaml](./specs/opa-gatekeeper/constraints/resourceLimits.yaml) - requires resources to be specified for any Pods in the `apod` namespace

Deploy the constraints:

```
kubectl apply -f labs/admission/specs/opa-gatekeeper/constraints
```

📋 Print the details of the required labels namespace constraint. Is it clear what it's enforcing?

<details>
  <summary>Not sure?</summary>

The constraint type is a CRD so you can list objects in the usual way:

```  
kubectl get requiredlabels

kubectl describe requiredlabels requiredlabels-ns
```

You'll see all the existing violations of the rule, and it should be clear what's required - the label on each namespace.

</details><br/>

## Lab

Now we have OPA Gatekeeper in place, we can see how it works.

Try deploying the APOD app from the specs for this lab:

```
kubectl apply -f labs/admission/specs/apod
```

It will fail because the resources don't meet the constraints we have in place. Your job is to fix up the specs and get the app running - without making any changes to policies :)

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup

Remove all the lab's namespaces:

```
kubectl delete ns -l kubernetes.courselabs.co=admission
```

And the CRDs:

```
kubectl delete crd -l gatekeeper.sh/system

kubectl delete crd -l gatekeeper.sh/constraint
```