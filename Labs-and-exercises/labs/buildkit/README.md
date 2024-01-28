# Building Docker Images with BuildKit

BuildKit is the image building engine inside Docker. It's not part of other container runtimes - like containerd - but you can run a BuildKit server in a container.

This powers a CI/CD pipeline running in Kubernetes, where you can have a BuildKit Pod building images from source. Builds are managed by an automation server - like Jenkins - which sends commands to the BuildKit server.

## Reference

- [BuildKit on GitHub](https://github.com/moby/buildkit)

- [Running BuildKit in Kubernetes](https://github.com/moby/buildkit/tree/master/examples/kubernetes)

- [Storing registry credentials in Kubernetes Secrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)

## Run the BuildKit server

BuildKit can run as a server application:

- [buildkitd.yaml](./specs/buildkitd/buildkitd.yaml) - specifies a Service and a Deployment. This simple example uses a privileged container; the rootless alternative is more secure.

```
kubectl apply -f labs/buildkit/specs/buildkitd

kubectl logs -l app=buildkitd
```

> The server is listening on port `1234`. We can send commands from a remote `builctl` CLI to build container images from a Dockerfile.

## Build an image with BuildKit

The `buildctl` CLI is a separate install. You don't typically need it on your machine, so we'll install it inside a Pod.

📋 Run a simple sleep Pod we can connect to, and exec into a shell session.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/buildkit/specs/sleep

kubectl exec -it sleep -- sh
```

</details><br/>

Inside the Pod session, install the BuildKit release:

```
wget https://github.com/moby/buildkit/releases/download/v0.9.0/buildkit-v0.9.0.linux-amd64.tar.gz

tar xvf buildkit-v0.9.0.linux-amd64.tar.gz
```

> The release contains the BuildKit server, CLI and emulators to build images for different CPU architectures.

Still inside the Pod session, download a Dockerfile:

```
cd bin

wget --no-check-certificate https://raw.githubusercontent.com/courselabs/kubernetes/main/labs/docker/simple/Dockerfile

cat Dockerfile
```

Build an image using the remote BuildKit server:

```
./buildctl --addr tcp://buildkitd:1234 build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=simple
```

> You'll see output which is familiar from Docker build commands, but the image is building on the BuildKit Pod; the logs show the Dockerfile and context being transferred before the build.

## Push image builds to a registry

BuildKit can automatically push images to a registry, but it needs to be authenticated. 

📋 Try the name buildctl command, but naming the image as `courselabs/simple` and pushing it to Docker Hub by adding the `push=true` flag to the output parameter.

<details>
  <summary>Not sure how?</summary>

```
./buildctl --addr tcp://buildkitd:1234 build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=docker.io/courselabs/simple,push=true
```

</details><br/>

> The build will work, but you'll get a 401 authorization failed error on the push. You can't push images to someone else's repo.

We'll try again with a Pod which is authorized to push images. Start by exiting the shell session:

```
exit
```

Kubernetes has a special type of secret called `docker-registry` which can be used to store image registry credentials. We'll create a Secret for your own Docker Hub creds - this also works for any registry with username/password authentication.

> If you're using Docker Hub you can create a temporary [access token](https://docs.docker.com/docker-hub/access-tokens/) instead of using your own password.


This is sensitive stuff, so we'll store the details in variables which you won't see on screen.


_On Windows, use PowerShell to store your credentials:_

```
$REGISTRY_SERVER='https://index.docker.io/v1/'
$REGISTRY_USER=Read-Host -Prompt 'Username'
$password = Read-Host -Prompt 'Password'-AsSecureString
$REGISTRY_PASSWORD = [System.Net.NetworkCredential]::new("", $password).Password
```

_OR on MacOS or Linux_:

```
REGISTRY_SERVER='https://index.docker.io/v1/'
read REGISTRY_USER
read -s REGISTRY_PASSWORD
```

📋 Now create a registry Secret in Kubernetes called `registry-creds`, using the variables you've stored.

<details>
  <summary>Not sure how?</summary>

```
kubectl create secret docker-registry registry-creds --docker-server=$REGISTRY_SERVER --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_PASSWORD
```

</details><br/>

We'll run a Pod which uses that Secret to authenticate with the registry. It needs one more setup step - the name of the registry and repository to use, which will get surfaced as environment variables.

📋 Create a ConfigMap called `build-config `, with a variable called `REGISTRY` set to your registry domain, and a variable called `REPOSITORY` set to your registry user name.

<details>
  <summary>Not sure how?</summary>

The Docker Hub registry domain is `docker.io` and I'll be pushing to the `courselabs` group, so I use:

```
kubectl create configmap build-config --from-literal=REGISTRY=docker.io  --from-literal=REPOSITORY=courselabs
```

</details><br/>

Now we can run a Pod from an image which has the BuildKit CLI already installed, surfacing the registry details we've created:

- [buildkit-cli.yaml](./specs/buildkit-cli/buildkit-cli.yaml) - mounts the registry credentials in the default path used by Docker and buildctl


📋 Run the BuildKit CLI Pod, and exec into a shell session.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/buildkit/specs/buildkit-cli

kubectl exec -it buildkit-cli -- sh
```

</details><br/>

Inside the Pod session, list the environment variables and check the registry credentials are loaded:

```
printenv | grep RE

ls -l /root/.docker
```

> If you cat the config.json file you'll see your creds in plain text...

Finally we can download a Dockerfile and use BuildKit to build and push the image. The registry credentials need to be set in the buildctl client, but it's the BuildKit server which does the push.

```
cd ~

wget --no-check-certificate https://raw.githubusercontent.com/courselabs/kubernetes/main/labs/docker/simple/Dockerfile

# build using the repository info from the ConfigMap:
buildctl --addr tcp://buildkitd:1234 build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${REGISTRY}/${REPOSITORY}/simple,push=true
```

> On Docker Hub you can check your page, e.g. https://hub.docker.com/r/courselabs/simple/tags; or on other registries run `docker pull ...`

## Lab

Your CI/CD pipeline will have a buildctl command which runs on every push to source control. You'll want a version number in the image tag, so you can identify the images pushed from each build.

Simulate that in this lab - build a new version of the simple Docker image and push it with a new tag. Use an environment variable for the version number, so your build command is the same every time; update the environment variable and push images with the tag `0.1.0` and `0.2.0`.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup

Cleanup by removing objects with this lab's label:

```
kubectl delete deploy,svc,pod -l kubernetes.courselabs.co=buildkit
```