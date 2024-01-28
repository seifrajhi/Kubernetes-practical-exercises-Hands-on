# Running a Local Kubernetes Cluster

Kubernetes clusters can have hundreds of nodes in production, but you can run a single-node cluster on your laptop and it works in the same way.

We'll also use [Git](https://git-scm.com) for source control, so you'll need a client on your machine to talk to GitHub.

## Git Client - Mac, Windows or Linux

Git is a free, open source tool for source control:

- [Install Git](https://git-scm.com/downloads)


## Docker Desktop - Mac or Windows

If you're on macOS or Windows 10 Docker Desktop is the easiest way to get Kubernetes:

- [Install Docker Desktop](https://www.docker.com/products/docker-desktop)

The download and install takes a few minutes. When it's done, run the _Docker_ app and you'll see the Docker whale logo in your taskbar (Windows) or menu bar (macOS).

> On Windows 10 the install may need a restart before you get here.

Right-click that whale and click _Settings_:

![](/img/docker-desktop-settings.png)

In the settings Windows select _Kubernetes_ from the left menu and click _Enable Kubernetes_: 

![](/img/docker-desktop-kubernetes.png)

> Docker downloads all the Kubernetes components and sets them up. That can take a few minutes too. When the Docker logo and the Kubernetes logo in the UI are both green, everything is running.

## **OR** k3d - Linux

<details>
  <summary>Running Kubernetes inside a container</summary>

On Linux [k3d](https://k3d.io) is a lightweight Kubernetes distribution with a good feature set. It runs a whole Kubernetes cluster inside a Docker container :)

> You can use k3d on macOS and Windows too - but Docker Desktop is easier.

You need to install Docker, then k3d and then create a cluster:

```
curl -fsSL https://get.docker.com | sh

curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

k3d cluster create k8s -p "30000-30040:30000-30040@server:0"
```

> This syntax uses the latest k3d command (v5); previous releases used a different syntax so you'll need to upgrade to v5.

</details><br />

## **OR** Kind - Linux

<details>
  <summary>An alternative Dockerized Kubernetes setup</summary>

If you're already using [Kind](kind.sigs.k8s.io/), use this setup which is tweaked for the labs:

```
kind create cluster --name k8s --config setup/kind.yaml
```

> If you're not already using Kind use k3d instead

</details><br />

## Check your cluster

Whichever setup you use, you should be able to run this command and get some output about your cluster:

```
kubectl get nodes
```

I'm using Docker Desktop and mine says:

```
NAME             STATUS   ROLES    AGE    VERSION
docker-desktop   Ready    master   5d4h   v1.19.7
```

> Your details may be different - that's fine. If you get errors then we need to look into it, because you'll need your own cluster for every part of the course.