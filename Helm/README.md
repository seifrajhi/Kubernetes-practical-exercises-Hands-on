Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [What is Helm?](#what-is-helm)
    - [Manage Complexity](#manage-complexity)
    - [Easy Updates](#easy-updates)
    - [Simple Sharing](#simple-sharing)
    - [Rollbacks](#rollbacks)
- [Helm Architecture](#helm-architecture)
  - [The Purpose of Helm](#the-purpose-of-helm)
  - [Components](#components)
  - [Implementation](#implementation)
- [Installing Helm](#installing-helm)
  - [From The Helm Project](#from-the-helm-project)
    - [From the Binary Releases](#from-the-binary-releases)
    - [From Script](#from-script)
  - [Through Package Managers](#through-package-managers)
    - [From Homebrew (macOS)](#from-homebrew-macos)
  - [Initialize a Helm Chart Repository](#initialize-a-helm-chart-repository)
  - [Install an Example Chart](#install-an-example-chart)
  - [Learn About Releases](#learn-about-releases)
  - [Uninstall a Release](#uninstall-a-release)
  - [Reading the Help Text](#reading-the-help-text)
  - [helm version](#helm-version)

# What is Helm?

Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.

Charts are easy to create, version, share, and publish.

### Manage Complexity

Charts describe even the most complex apps, provide repeatable application installation, and serve as a single point of authority.

### Easy Updates

Take the pain out of updates with in-place upgrades and custom hooks.

### Simple Sharing

Charts are easy to version, share, and host on public or private servers.

### Rollbacks

Use `helm rollback` to roll back to an older version of a release with ease.


# Helm Architecture

This  describes the Helm architecture at a high level.

## The Purpose of Helm

Helm is a tool for managing Kubernetes packages called _charts_. Helm can do the following:

-   Create new charts from scratch
-   Package charts into chart archive (tgz) files
-   Interact with chart repositories where charts are stored
-   Install and uninstall charts into an existing Kubernetes cluster
-   Manage the release cycle of charts that have been installed with Helm

For Helm, there are three important concepts:

1.  The _chart_ is a bundle of information necessary to create an instance of a Kubernetes application.
2.  The _config_ contains configuration information that can be merged into a packaged chart to create a releasable object.
3.  A _release_ is a running instance of a _chart_, combined with a specific _config_.

## Components

Helm is an executable which is implemented into two distinct parts:

**The Helm Client** is a command-line client for end users. The client is responsible for the following:

-   Local chart development
-   Managing repositories
-   Managing releases
-   Interfacing with the Helm library
    -   Sending charts to be installed
    -   Requesting upgrading or uninstalling of existing releases

**The Helm Library** provides the logic for executing all Helm operations. It interfaces with the Kubernetes API server and provides the following capability:

-   Combining a chart and configuration to build a release
-   Installing charts into Kubernetes, and providing the subsequent release object
-   Upgrading and uninstalling charts by interacting with Kubernetes

The standalone Helm library encapsulates the Helm logic so that it can be leveraged by different clients.

## Implementation

The Helm client and library is written in the Go programming language.

The library uses the Kubernetes client library to communicate with Kubernetes. Currently, that library uses REST+JSON. It stores information in Secrets located inside of Kubernetes. It does not need its own database.

Configuration files are, when possible, written in YAML.

# Installing Helm

This guide shows how to install the Helm CLI. Helm can be installed either from source, or from pre-built binary releases.

## From The Helm Project

The Helm project provides two ways to fetch and install Helm. These are the official methods to get Helm releases. 

In addition to that, the Helm community provides methods to install Helm through different package managers. Installation through those methods can be found below the official methods.

### From the Binary Releases

Every [release](https://github.com/helm/helm/releases) of Helm provides binary releases for a variety of OSes. These binary versions can be manually downloaded and installed.

1.  Download your [desired version](https://github.com/helm/helm/releases)
2.  Unpack it

```
tar -zxvf helm-v3.0.0-linux-amd64.tar.gz
```

3.  Find the `helm` binary in the unpacked directory, and move it to its desired destination 

```
mv linux-amd64/helm /usr/local/bin/helm
```

From there, you should be able to run the client and [add the stable repo](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository): 

```
helm repo add name chart repo
```

Example:

```
helm repo add bitnami https://charts.bitnami.com/bitnami
```


### From Script

Helm now has an installer script that will automatically grab the latest version of Helm and [install it locally](https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3).

You can fetch that script, and then execute it locally. It's well documented so that you can read through it and understand what it is doing before you run it.

```console
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```

## Through Package Managers

The Helm community provides the ability to install Helm through operating system package managers. These are not supported by the Helm project and are not considered trusted 3rd parties.

### From Homebrew (macOS)

Members of the Helm community have contributed a Helm formula build to Homebrew. This formula is generally up to date.

```console
brew install helm
```

## Initialize a Helm Chart Repository

Once you have Helm ready, you can add a chart repository. Check [Artifact Hub](https://artifacthub.io/packages/search?kind=0) for available Helm chart repositories.

```console
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once this is installed, you will be able to list the charts you can install:

```console
helm search repo bitnami
```

## Install an Example Chart

To install a chart, you can run the `helm install` command. Helm has several ways to find and install a chart, but the easiest is to use the `bitnami` charts.

```console
helm repo update             # Make sure we get the latest list of charts
```

```
helm install bitnami/mysql --generate-name
```

In the example above, the `bitnami/mysql` chart was released, and the name of our new release is `mysql-1612624192`.

You get a simple idea of the features of this MySQL chart by running `helm show chart bitnami/mysql`. 

Or you could run `helm show all bitnami/mysql` to get all information about the chart.

Whenever you install a chart, a new release is created. So one chart can be installed multiple times into the same cluster. And each can be independently managed and upgraded.

## Learn About Releases

It's easy to see what has been released using Helm:

```console
helm list
```

The `helm list` (or `helm ls`) function will show you a list of all deployed releases.

## Uninstall a Release

To uninstall a release, use the `helm uninstall` command:

```console
helm uninstall mysql
```

This will uninstall `mysql` from Kubernetes, which will remove all resources associated with the release as well as the release history.

If the flag `--keep-history` is provided, release history will be kept. You will be able to request information about that release:

```console
helm status mysql
```

Because Helm tracks your releases even after you've uninstalled them, you can audit a cluster's history, and even undelete a release (with `helm rollback`).

## Reading the Help Text

To learn more about the available Helm commands, use `helm help` or type a command followed by the `-h` flag:

```console
$ helm get -h
```

## helm version

Show the version for Helm.

This will print a representation the version of Helm.

```
helm version
```

print the client version information