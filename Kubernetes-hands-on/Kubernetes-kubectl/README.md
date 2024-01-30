<div align=center>
Kubernetes-kubectl
</div>

### What is it?

The Kubernetes command-line interface, or CLI, is a tool that you can use to run commands against Kubernetes clusters. With the Kubernetes CLI, you can control and configure the various components of a Kubernetes system, such as deployments, services, and pods.

To use the Kubernetes CLI, you first need to install the kubectl command on your local machine. Once kubectl is installed, you can use it to connect to a Kubernetes cluster and run commands against that cluster. For example, you can use the kubectl command to deploy a new application to a Kubernetes cluster, or to view the status of existing deployments.

### Why we use it?

We need the Kubernetes CLI because it provides a way to control and manage Kubernetes clusters from the command line. With the Kubernetes CLI, you can perform a wide range of tasks, such as deploying applications, scaling deployments, and viewing the status of various components in a Kubernetes system.

### Where we use it?

The Kubernetes CLI is especially useful for managing complex or large-scale Kubernetes deployments, where it can be difficult to manage all of the components manually. The Kubernetes CLI allows you to automate many of the tasks involved in managing a Kubernetes cluster, which can save time and effort.

### How it works?

In the real world, the Kubernetes CLI (kubectl) is used to manage and control Kubernetes clusters from the command line. For example, a developer might use the kubectl command to deploy a new application to a Kubernetes cluster, or to view the status of existing deployments.

Here is a simple example of how kubectl might be used in the real world:

The developer writes a new application and creates a Kubernetes deployment file, which defines the components needed to run the application in a Kubernetes cluster.

The developer uses the kubectl command to connect to the Kubernetes cluster, and deploys the application by running the following command:

```yaml
kubectl apply -f deployment.yaml
```

The Kubernetes API server receives the command and creates the necessary components, such as pods and services, to run the application.

The developer can use the kubectl command to view the status of the deployment, and see whether it was successful. For example, they might run the following command:

```yaml
kubectl get deployments
```

The Kubernetes API server returns the status of the deployment to the developer, showing whether it was successful and providing other details, such as the number of replicas and the current status of each pod.

### The pros of using the Kubernetes CLI (kubectl) include:

- It provides a simple and consistent way to perform a wide range of tasks in a Kubernetes cluster.

- The Kubernetes CLI is highly extensible, allowing you to add custom commands and functionality to suit your specific needs.
The Kubernetes CLI is widely used and well-supported, making it easy to find help and guidance if you run into any problems.

### The cons of using the Kubernetes CLI include:

- It can be complex and intimidating for new users, especially those who are not familiar with the command line.

- It can be difficult to automate, making it challenging to integrate into continuous integration and deployment pipelines.

### How we can add custom plugin?

To add custom commands to the Kubernetes CLI (kubectl), you can use the kubectl plugin command. This command allows you to create and install custom plugins that extend the functionality of kubectl.

Here is an example of how you might use the kubectl plugin command to add a custom command to kubectl:

Create a new directory for your plugin, and navigate to that directory in a terminal window.

Create a file called my_plugin.py, and add the following code to the file:


```yaml
from kubectl.commands import kubectl_command

@kubectl_command(name='my-plugin', help='This is my custom plugin')
def my_plugin(args):
    print('Hello from my plugin!')
```

Install the plugin by running the following command:

```yaml
kubectl plugin install my_plugin.py
```


Use the custom plugin by running the my-plugin command:

```yaml
kubectl my-plugin
```

In this example, we created a custom plugin called my_plugin.py, and installed it using the kubectl plugin install command. We then used the custom plugin by running the my-plugin command, which printed a message to the terminal.

### The history of kubectl

Kubectl is the command-line interface for Kubernetes, which was originally developed by Google. Kubernetes was first released as an open-source project in 2014, and kubectl was introduced as part of the project's initial release. Since then, kubectl has undergone regular updates and improvements, with the latest stable version being kubectl 1.26