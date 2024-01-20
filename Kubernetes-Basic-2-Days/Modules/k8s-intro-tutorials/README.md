# **Kubernetes Tutorials**

## **Before you begin**

These tutorials  make use of [kind][kind]. A tool that allows users to quickly spin up and run a single instance of Kubernetes locally using Docker.

To install it and the other tutorial dependencies, see the [Installation Guides](#installation-guides) section.

Each section assumes an instance of kind is up and running. To start kind for the first time, use the command:

```
kind create cluster
```

---

## **Tutorial Index**
* [CLI](/Kubernetes-Basic-2-Days/Modules/k8s-intro-tutorials/CLI/README.md) - Covers the basics of using `kubectl` to interact with a Kubernetes cluster.
* [storage](/Kubernetes-Basic-2-Days/Modules/k8s-intro-tutorials/storage/README.md) - Explores the relationship between Persistent Volumes, Persistent Volume Claims, and Volumes themselves.
* [ConfigMaps and Secrets](/Kubernetes-Basic-2-Days/Modules/k8s-intro-tutorials/Configuration/README.md) - Tutorials going over how to use the two Configuration objects ConfigMaps and Secrets.