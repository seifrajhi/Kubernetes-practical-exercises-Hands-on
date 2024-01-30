### What is ConfigMap in Kubernetes? Why Use it?

Configuration is a term for configuration settings, consisting of strings of key-value pairs. 
For containerized applications to work, Kubernetes provides these values to containers, 
and these keys help you determine the configuration value.

Configurations come in the form of an API and its main focus is to keep the configuration
separate from the container image. A ConfigMap represents an entire configuration file 
or individual data.

When working with Kubernetes, developers always look forward to keeping the images lightweight 
so that they are easily portable. And for that, you need to separate the configuration settings 
from the application code and Configmaps helps you

You can put different types of configuration data in pods to ensure that the application runs well 
in all kinds of environments. However, you can use the same application code with different 
configuration settings during the app development, testing and production phase.

### How does ConfigMap works?

Firstly, you will need multiple ConfigMaps because each one will act separately in different environments. 
And you will have to create and add a ConfigMap to the Kubernetes cluster. 
You will also have to use the value of ConfigMap in the pod reference

```yaml
#(deploy.yaml)

volumeMounts:
 - name: config-volume
   mountPath: /configs/
volumes:
  configMap:
    name: app-v1-test-config #name of our configmap object
```

## The workflow which I go through

- Created a go application (to read config(app expecting a config) this is from application,<br> 
  and (k8s Deployment yaml file expects a config) -> which is mounted through volume
- Build an image out of it
- Created ConfigMap for the test environment
- Deploying the go application via Deployment(here ConfigMap mounted using MountPath)
- before the deployment is successfully running the steps it goes through <br>
   -> it will start -> read the config -> successfully load the config. (this data is stored in logs)

*Note: Once the deployment fetch the config and handitover to the pod which is then handitover to the container <br>
but the application doesn't know the config data is coming from ConfigMap, it feels like* <br>
*the whole ConfigMap data is a part of the application* 