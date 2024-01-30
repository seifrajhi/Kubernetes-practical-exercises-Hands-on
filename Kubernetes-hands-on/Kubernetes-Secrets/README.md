### What are the secrets in Kubernetes?

Secrets allow Kubernetes users to more efficiently store and manage all sensitive <br>
information such as passwords, OAuth tokens, and ssh keys. This is a better and <br>
more flexible way compared to other options like using pod specifications and <br>
container images.

Users with API access or anyone with accessibility to etcd, <br>
the data store for Kubernetes, can recover each secret as plain text.


### Safety offered by Kubernetes

Kubernetes resources provide strict security to prevent secrets from being exposed. <br>
Brief information about the security added by various resources in the environment <br>
is as follows:

#### Secret resources
 
Pods and Secrets are completely isolated from each other, <br>
which makes data stored in a Secret less likely to be exposed <br>
during the full Pod lifecycle. Therefore, the first step to <br>
sharing critical information variables with pods is to create <br>
them separately as secret objects.

#### Kubelet

Kubelets are node agents that run on all nodes that interact with <br>
containers during runtime. Data stored in secrets is used by containers <br>
that are also available on nodes. However, these secrets are not shared <br>
with all nodes and are only given to nodes that have pods running the secret.

#### Pods

Multiple pods run on each node, but only select ones defined for <br>
using secrets can access them. That being said, there are many <br>
containers running in each pod, but Secrets is limited to only <br>
those containers called for in the volume mount specification. 

Thus, it reduces the possibility of redundant sharing of pods <br>
performance secrets to pods or containers.

#### Kubernetes API

The process of creating and accessing secrets is handled by the <br>
Kubernetes API. Thus, Kubernetes secures all communications between <br>
users, the API server, and the kubelet using SSL/TLS.

#### Etcd
 
Like any other Kubernetes resource's data, secrets are also stored <br>
in etcd. This makes it possible for people to access confidential data <br>
after entering etcd through the control plane. To avoid this, Kubernetes <br>
allows users to encrypt confidential data. Encryption further helps to <br>
isolate secrets from other Kubernetes resources and minimize exposure.




```yaml
#(deploy.yaml)

# `volumeMounts` section for configmap and secrets
        volumeMounts:
         - name: config-volume
           mountPath: /configs/
         - name: secret-volume
           mountPath: /secrets/
# `volumes` section for configmap and secrets
        volumes:
        - name: secret-volume
          secret:
            secretName: app-v2-test-config #name of our secret object
        - name: config-volume
          configMap:
            name: app-v2-test-config  
    
```

## The workflow which I go through

- Created a go application (to read config+secrets(app expecting a config and secrets) this is from application,<br> 
  and (k8s Deployment yaml file expects a config and secrets) -> which is mounted through volume
- Build an image out of it
- Created ConfigMap for the test environment
- Created Secret for the test environment
- Deploying the go application via Deployment(here ConfigMap and Secret mounted using MountPath)
- before the deployment is successfully running, it will go through some steps <br>
   -> it will start -> read the config -> successfully load the config. (this data is stored in logs) <br>
   -> it will start -> read the secret -> successfully load the secret. (this data is stored in logs)




