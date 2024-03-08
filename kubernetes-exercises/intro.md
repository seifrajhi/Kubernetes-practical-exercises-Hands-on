# Kubernetes-introduction

## Introduction

In this course, we will learn how to deploy applications in Kubernetes.
We will start by deploying the entire quotes application the way it will be done when we are done with the course. 

# Deploying an application

Our small example flask application that displays quotes.

The application consists of three components, frontend, backend and a database.

The frontend and backend are small python flask webservers that listen for HTTP requests.
For persistent storage, a postgresql database is used.

## Learning Goals

- Use the Kubernetes command line interface (CLI) `kubectl`.
- Familiarize yourself with the quotes application.
- Access the application from outside the cluster through a service.


## Introduction

In Kubernetes, we run containers, but we don't manage containers directly. Containers are instead placed inside `pods`.
A `pod` _contains_ containers.

Pods in turn are managed by controllers, the most common one is called a `deployment`.

And in order to make the application accessible from the outside, we use a `service`. Don't worry if you feel a bit overwhelmed, we will go through them in detail later in the course.

Kubernetes resources are declared in what is called `manifests` which use a markup language called `yaml` to express the desired state of resources.

### Imperative vs Declarative

You can use the Kubernetes CLI to create, delete and modify resources in two ways - imperatively and declaratively.

Imperatively means that you are actively _creating, deleting and modifying_ resources. And if for example you run a create command twice, you will end up with one resource and a "fail to create" error message, because it is already created.

Declaratively means that you _declare what you want,_ and _not how_ Kubernetes should do it. If you run the same command twice, you will end up with just one resources. This is because Kubernetes will fulfill your desired state, and if it already exists, it will not create it again.

Doing things **imperatively** is fine for _hacking_ on things, but most of the time we want to work with Kubernetes **declaratively**.

Therefore we much prefer to do things **declaratively**.
Declaratively means that we _declare what we want,_ and _not how_ Kubernetes should do it.

This declaration is what we call our `desired state`.


### Interacting with Kubernetes using kubectl

We will be interacting with Kubernetes using the command line.

The Kubernetes CLI is called `kubectl`, and allows us to manage our applications and Kubernetes itself.

To use it, type `kubectl <subcommand> <options>` in a terminal.

## Exercise

### Overview

- Inspect existing Kubernetes manifest for a `deployment` object.
- Apply the Quotes flask application using the `kubectl apply` command.
- Access the application from the Internet

### Step by step instructions

<details>
<summary>Step by step</summary>

**take the same bullet names as above and put them in to illustrate how far the student have gone**

## Inspect existing Kubernetes manifest for a `deployment` object.


We have prepared all the Kubernetes manifests that you need for the application to run.

You can find the manifest in the folder called `quotes-flask`.

- Open up the frontend manifest located at `quotes-flask/frontend-deployment.yaml`.

Try to see if you can find information about:

- The name of the deployment
- The number of replicas
- The image used for the container
- The port the container listens on

Do not worry if you don't understand everything yet, we will go through it in detail later in the course.

## Apply the manifest using the `kubectl apply`.

Use the `kubectl apply -f <file>` command to send the manifest with your desired state to Kubernetes:

``` bash
kubectl apply -f quotes-flask/
```

Expected output:

```
configmap/backend-config created
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created
configmap/postgres-config created
deployment.apps/postgres created
persistentvolumeclaim/postgres-pvc created
secret/postgres-secret created
service/postgres created
```

- You can verify that the deployment is created by running the `kubectl get deployments` command.

``` bash
kubectl get deployments
```

Expected output:

```
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
backend         1/1     1            1           27s
frontend        1/1     1            1           27s
postgres        1/1     1            1           27s
```

> :bulb: You might need to issue the command a couple of times, as it might take a few seconds for the deployment to be created and available.

##  Access the application from the Internet

We are getting a little ahead of our exercises here, but to illustrate that we actually have
a functioning application running in our cluster, let's try accessing it from a browser!

First of, get the `service` called `frontend` and note down the NodePort, by finding the `PORT(S)` column and noting the number on the right side of the colon `:`

> :bulb: A `service` is a networking abstraction that enables a lot of the neat networking features of Kubernetes.
> We will cover `services` in detail in a later exercise, so just go with it for now :-)

``` bash
kubectl get service frontend
```

Expected output:

```
NAME        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
frontend       NodePort   10.96.223.218   <none>        80:32458/TCP   12s
```

In this example, Kubernetes has chosen port `32458`, you will most likely get a different number.

Finally, look up the IP address of a node in the cluster with:

``` bash
kubectl get nodes -o wide
```

> :bulb: The `-o wide` flag makes the output more verbose, i.e. to include the IPs

Expected output:

```
NAME    STATUS   . . . INTERNAL-IP  EXTERNAL-IP     . . .
node1   Ready    . . . 10.123.0.8   35.240.20.246   . . .
node2   Ready    . . . 10.123.0.7   35.205.245.42   . . .
```

In the example your external IPs are either `35.240.20.246` or `35.205.245.42`.

Since your `service` is of type `NodePort` it will be exposed on _all_ of the nodes. The service will be exposed on the port with the number you noted down above.

Choose one of the `EXTERNAL-IP`'s, and point your web browser to the address: `<EXTERNAL-IP>:<PORT>`.

In this example, the address could be `35.240.20.246:32458`, or `35.205.245.42:32458`.

You should see the application in the browser now!

</details>

Congratulations! You have deployed your first application in Kubernetes! 
Easy, right :-)


### Clean up

To clean up, run the following command:

```
kubectl delete -f quotes-flask/
```

### Extra

If you have more time, take a look at the YAML manifests that we used to deploy the application.
They are in the `quotes-flask` folder.
First take a look at the deployment manifest, and see if you can find the following information:

- The name of the deployment
- The number of replicas
- The image used for the container

Then take a look at the service manifest, and see if you can find the following information:

- The name of the service
- The port the service listens on

