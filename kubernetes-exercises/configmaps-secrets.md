# ConfigMaps and Secrets

## Learning Goals

- learn how to create `configmaps` and `secrets`
- learn how to use `configmaps` and `secrets` in a `deployment`

## Introduction

Configmaps and secrets are a way to store information that is used by several deployments and pods in your cluster.
This makes it easy to update the configuration in one place, when you want to change it.

Both configmaps and secrets are generic `key-value` pairs, but secrets are `base64 encoded` and configmaps are not.

> :bulb: Secrets are not encrypted, they are encoded. This means that if someone gets access to the cluster, they can will be able to read the values.

## ConfigMaps

You use a ConfigMap to keep your application code separate from your configuration.

It is an important part of creating a [Twelve-Factor Application](https://12factor.net/).

This lets you change easily configuration depending on the environment (development, production, testing, etc.) and to dynamically change configuration at runtime.

A ConfigMap manifest looks like this in yaml:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  key1: value1
  key2: value2
  key3: value3
```

There are three ways to create ConfigMaps using the `kubectl create configmap` command.

- Use the contents of an entire directory with `kubectl create configmap my-config --from-file=./my/dir/path/`
- Use the contents of a file or specific set of files with `kubectl create configmap my-config --from-file=./my/file.properties`

<details>
<summary>
:bulb: More info
</summary>

Env-files contain a list of environment variables.
These syntax rules apply:

- Each line in an env file has to be in VAR=VAL format.
- Lines beginning with # (i.e. comments) are ignored.
- Blank lines are ignored.
- There is no special handling of quotation marks (i.e. they will be part of the ConfigMap value).

```properties
enemies=aliens
lives=3
allowed="true"

# This comment and the empty line above it are ignored
```

Will be rendered as:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  enemies: aliens
  lives: "3"
  allowed: "true"
```

[Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-configmaps-from-files)

</details>

- Use literal key-value pairs defined on the command line with `kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2`

> :bulb: remember the `--dry-run=client -o yaml` trick to see what the yaml file will look like before you apply it.

<details>
<summary>
:bulb: More info
</summary>

[Summary of Configmaps](https://matthewpalmer.net/kubernetes-app-developer/articles/ultimate-configmap-guide-kubernetes.html)

</details>

## Secrets

`secrets` are used for storing configuration that is considered sensitive, and well ... _secret_.

When you create a `secret` Kubernetes will go out of it's way to not print the actual values of secret object, to things like logs or command output.

You should use `secrets` to store things like passwords for databases, API keys, certificates, etc.

Rather than hardcode this sensitive information and commit it to git for all the world to see, we source these values from environment variables.

`secrets` function for the most part identically to `configmaps`, but with the difference that the actual values are `base64` encoded.
`base64` encoded means that the values are obscured, but can be trivially decoded.
When values from a `secret` are used, Kubernetes handles the decoding for you.

> :bulb: As `secrets` don't actually make their data secret for anyone with access to the cluster, you should think of `secrets` as metadata for humans, to know that the data contained within is considered secret.

## Using ConfigMaps and Secrets in a deployment

To use a configmap or secret in a deployment, you can either mount it in as a volume, or use it directly as an environment variable.

### Injecting a ConfigMap as environment variables

This will inject all key-value pairs from a configmap as environment variables in a container.
The keys will be the name of variables, and the values will be values of the variables.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  ...
    spec:
    containers:
      - name: my-app
        image: my-app:latest
        ports:
          - containerPort: 8080
        envFrom:
          - configMapRef: # this is the configmap that we want to use
              name: my-config # the name of the configmap we want to use
```

## Exercise

### Overview

- Add the database part of the application
- Change the database user into a configmap and implement that in the backend
- Change the database password into a secret, and implement that in the backend.
- Change database deployment to use the configmap and secret.

### Step by step instructions

<details>
<summary>
Step by step:
</summary>

> :bulb: All files for the exercise are found in the `configmap-secrets/start` folder.

**Add the database part of the application**

We have already created the database part of the application, with a deployment and a service.

- Look at the database deployment file `postgres-deployment.yaml`.
  Notice the database username and password are injected as hardcoded environment variables.

> :bulb: This is not a good practice, as we do not want to store these values in version control.
> We will fix this in the next steps.

- Look at the service file in `postgres-svc.yaml`.
  It provides a service for the database, so that the backend can connect to it.

- Apply the whole folder with `kubectl apply -f .`

- Check that the applications are running with `kubectl get pods`

Expected output:

```bash
NAME                       READY   STATUS    RESTARTS   AGE
backend-7d64597fcf-98vv5   1/1     Running   0          4s
backend-7d64597fcf-npvnq   1/1     Running   0          4s
backend-7d64597fcf-nrchp   1/1     Running   0          4s
frontend-5f9b5f46c8-jkw9n  1/1     Running   0          4s
postgres-6fbd757dd7-ttpqj  1/1     Running   0          4s
```

**Refactor the database user into a configmap and implement that in the backend**

We want to change the database user into a configmap, so that we can change it in one place, and use it on all deployments that needs it.

- Create a configmap with the name `postgres-config` and filename `postgres-config.yaml` and the information about database configuration as follows:

```yaml
data:
  DB_HOST: postgres
  DB_PORT: "5432"
  DB_USER: superuser
  DB_PASSWORD: complicated
  DB_NAME: quotes
```


:bulb: If you are unsure how to do this, look at the [configmap section](#configmaps) above.

<details>
<summary>Help me out!</summary>

If you are stuck, here is the solution:

This will generate the file:

```
kubectl create configmap postgres-config --from-literal=DB_HOST=postgres --from-literal=DB_PORT=5432 --from-literal=DB_USER=superuser --from-literal=DB_PASSWORD=complicated --from-literal=DB_NAME=quotes --dry-run=client -o yaml > postgres-config.yaml
```

You can also write it by hand:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
data:
  DB_HOST: postgres
  DB_PORT: "5432'
  DB_USER: superuser
  DB_NAME: quotes
  DB_PASSWORD: complicated
```

</details>


- apply the configmap with `kubectl apply -f postgres-config.yaml`

- In the `backend-deployment.yaml`, change the environment variables to use the configmap instead of the hardcoded values.

Change this:

```yaml
env:
  - name: DB_HOST
    value: postgres
  - name: DB_PORT
    value: "5432"
  - name: DB_USER
    value: superuser
  - name: DB_PASSWORD
    value: complicated
  - name: DB_NAME
    value: quotes
```

To this:

```yaml
envFrom:
  - configMapRef:
      name: postgres-config
```

- re-apply the backend deployment with `kubectl apply -f backend-deployment.yaml`
- check that the website is still running.

**Change the database password into a secret, and implement that in the backend.**

We want to change the database password into a secret, so that we can change it in one place, and use it on all deployments that needs it.
In order for this, we need to change the backend deployment to use the secret instead of the configmap for the password itself.

- create a secret with the name `postgres-secret` and the following data:

```yaml
data:
  DB_PASSWORD: Y29tcGxpY2F0ZWQ=
```

<details>
<summary>
Help me out!
</summary>

If you are stuck, here is the solution:

```
kubectl create secret generic postgres-secret --from-literal=DB_PASSWORD=complicated --dry-run=client -o yaml > postgres-secret.yaml
```

You can also write the secret by hand:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
data:
  DB_PASSWORD: Y29tcGxpY2F0ZWQ=
```

</details>

- apply the secret with `kubectl apply -f postgres-secret.yaml`

- In the `backend-deployment.yaml`, change the environment variables to use the secret instead of the configmap for the password.

Change this:

```yaml
envFrom:
  - configMapRef:
      name: postgres-config
```

To this:

```yaml
envFrom:
  - configMapRef:
      name: postgres-config
  - secretRef:
      name: postgres-secret
```

- Delete the password from the configmap, and re-apply the configmap with `kubectl apply -f postgres-config.yaml`

- Re-apply the backend deployment with `kubectl apply -f backend-deployment.yaml`

- Check that the website is still running.

**Change database deployment to use the configmap and secret.**

We are going to implement the configmap and secret in the database deployment as well.

The standard Postgres docker image can be configured by setting specific environment variables, ([you can see the documentation here](https://hub.docker.com/_/postgres)).
By populating these specific values we can configure the credentials for root user and the name of the database to be created.

This means that we need to change the way we are injecting the environment variables, in order to make sure the environment variables have the correct names.

- Open the `postgres-deployment.yaml` file, and change the way the environment variables are injected to use the configmap and secret.

```yaml
### using configMapKeyRef
env:
  - name: POSTGRES_USER
    valueFrom:
      configMapKeyRef:
        name: postgres-config
        key: DB_USER
  - name: POSTGRES_DB
    valueFrom:
      configMapKeyRef:
        name: postgres-config
        key: DB_NAME
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: DB_PASSWORD
```

- re-apply the database deployment with `kubectl apply -f postgres-deployment.yaml`
- check that the website is still running, and that the new database can be reached from the backend.

Congratulations! You have now created a configmap and a secret, and used them in your application.

</details>

### Extra

If you have time, try to get the secret data decoded again.

Here is a snippet to get you started:

```bash
kubectl get secret <secret-name> -o jsonpath="{.data.password}" | base64 --decode
```

### Clean up

Delete the resources you have deployed by running `kubectl delete -f .` in the `configmaps-secrets/start` directory.
