# CI/CD with Jenkins

Jenkins is a popular and powerful automation server. You can run Jenkins in your Kubernetes cluster as part of a deployment infrastructure to build and push Docker images, and update the running applications in your cluster.

These exercises run a full local build setup in Kubernetes:

- [Gogs](https://gogs.io/) - a Git server to host your project source code and specs
- [BuildKit](https://github.com/moby/buildkit) - to build container images from Dockerfiles
- [Jenkins](https://www.jenkins.io) - to fetch code from Gogs and build images with BuildKit

You don't typically run all this yourself, but it's very useful to see how it all fits together and have it as a backup option if your other services go down.

## Reference

- [Using images from a private registry in Pods](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

- [Getting started with Jenkins pipelines](https://www.jenkins.io/doc/book/pipeline/getting-started/)

- [Using Declarative Jenkins Pipelines](https://app.pluralsight.com/library/courses/using-declarative-jenkins-pipelines/table-of-contents) - Pluralsight course to learn more about Jenkins

## Deploy the build stack

The build components will all run as Deployments in a custom namespace:

- [infrastructure/gogs.yaml](./specs/infrastructure/gogs.yaml) - defines the Git server, and a NodePort to access it

- [infrastructure/buildkitd.yaml](./specs/infrastructure/buildkitd.yaml) - runs a BuildKit server, with a ClusterIP Service for internal access

- [infrastructure/jenkins.yaml](./specs/infrastructure/jenkins.yaml) - runs Jenkins with a NodePort to access on port 30008, plus setup scripts in a ConfigMap and RBAC rules for Jenkins to use the Kubernetes API server

Start by deploying all the infrastructure components:

```
kubectl apply -f labs/jenkins/specs/infrastructure
```

📋 Check on the Deployments. Not all the Pods are running - what's the problem?

<details>
  <summary>Not sure?</summary>

Check the Deployments:

```
kubectl get deploy -n infra
```

The Gogs and BuildKit Deployments get up to scale, but the Jenkins Deployment stays at 0/1 Ready.

Check the Pod:

```
kubectl get po -n infra -l app=jenkins
```

It's stuck at the `ContainerCreating` status. Describe the Pod and you'll see it needs a Secret: _secret "registry-creds" not found_.

</details><br/>

Jenkins will run a pipeline to build and push Docker images using BuildKit. For that it needs authentication to Docker Hub - or whichever image registry you use.

Just like the [BuildKit lab](../../labs/buildkit/README.md), this is sensitive stuff so we'll use variables to hide your password. 

> **Secrets are namespaced, and you can't mount a Secret from one namespace to a Pod in another namespace**.

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

📋 Now create a registry Secret in Kubernetes called `registry-creds` in the `infra` namespace, using the variables you've stored.

<details>
  <summary>Not sure how?</summary>

```
kubectl create secret docker-registry -n infra registry-creds --docker-server=$REGISTRY_SERVER --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_PASSWORD
```

</details><br/>

Your Jenkins Pod may be in a backoff state by now, so replace it with a new rollout:

```
kubectl rollout restart -n infra deploy/jenkins
```

The new Pod still won't start :)

📋 What's wrong with the Pod now?

<details>
  <summary>Not sure?</summary>

Check the Pods and you'll see they're in `CreateContainerConfigError` status:

```
kubectl get po -n infra -l app=jenkins
```

Describe the latest Pod and you'll see there's one more dependency needed: _Error: configmap "build-config" not found_

</details><br/>

We need a ConfigMap to store details of the image name to use for the build - the name includes the registry domain and your user (or group) name. 

Set your registry domain and repository name in a ConfigMap, **be sure to use your own registry ID**:

```
kubectl create configmap -n infra build-config --from-literal=RELEASE_VERSION=21.09 --from-literal=REGISTRY_DOMAIN=docker.io  --from-literal=REGISTRY_REPOSITORY=<your-registry-id>
```

Now you'll see the Jenkins Deployment come up to scale:

```
kubectl get deploy -n infra 
```

## Push the source code to your local Git server

The local build infrastructure is all running, and Jenkins is configured with a project which fetches a Git repo from the Gogs server.

To run a build we need to push our local code to Gogs. You can do this with the Git CLI - these commands adds the local server as a new remote and push a copy of the repo there:

```
# add the local Git server:
git remote add labs-jenkins http://localhost:30030/kiamol/kiamol.git

# and push:
git push labs-jenkins main
```

> You'll need to authenticate with the server, use `kiamol` as the username and password.

Now all the code from this repo is in your local Git server. You can browse here and see the build pipeline: http://localhost:30030/kiamol/kiamol/src/main/labs/jenkins/project/Jenkinsfile.

This is a Jenkins pipeline definition. If you're not familiar with the syntax, you can see we're mostly running shell scripts which use the BuildKit CLI to build and push images.

## Run the pipeline in Jenkins

Browse to Jenkins at http://localhost:30008. Click _log in_ at the top right of the screen, and use `kiamol` as the username and password.

Now browse to project at http://localhost:30008/job/kiamol/ (the project is created in the setup scripts in [jenkins.yaml](./specs/infrastructure/jenkins.yaml)).

Click _Enable_ and then click _Build Now_.

The build should complete sucessfully:

- Jenkins pulls the source code from Gogs
- it prints the version of the tools it's using
- it runs `buildctl` to build an image with the BuildKit server
- the image is built from the [whoami Dockerfile](./project/src/Dockerfile) 
- the image tag uses your registry configuration, and adds the Jenkins build number
- the image is pushed to your registry

If it all goes well, you should see the push information in the logs, and you can browse to Docker Hub and see your image - e.g. https://hub.docker.com/r/courselabs/whoami-lab/tags.

> If not check the Jenkins project logs - any problems are likely to be authentication using the Secret, or the image name compiled from the ConfigMap.


## Add the deployment stage

That's the CI part done - if the project had unit tests we could run them as another stage in the Dockerfile and be confident the built image was functionally correct.

Now we want to add Continuous Deployment. There's a Helm chart for the project which we can run manually to test the release:

- [whoami/templates/service.yaml](./project/helm/whoami/templates/service.yaml) - the Service uses variables for the type and port
- [whoami/templates/deployment.yaml](./project/helm/whoami/templates/deployment.yaml) - uses variables for the image name and a flag for using a private image registry
- [whoami/values.yaml](./project/helm/whoami/values.yaml) - sets default values for the chart
- [integration-test.yaml](./project/helm/integration-test.yaml) - provides alternative values for running a test environment

Install a local release to verify the chart - using a public image:

```
helm upgrade --install whoami-dev --set serverImage=docker.io/courselabs/whoami-lab:21.09-1 labs/jenkins/project/helm/whoami
```

When the app is running, test it at http://localhost:30028

We'll add the CD stage to the build, deploying to a new namespace. 

📋 Create a namespace called `integration-test` and label it with `kubernetes.courselabs.co=jenkins` so we can easily clean up at the end.

<details>
  <summary>Not sure how?</summary>

```
kubectl create ns integration-test 

kubectl label ns integration-test kubernetes.courselabs.co=jenkins
```

</details><br/>

We want to use the images Jenkins pushes to run the app in the test namespace - so that namespace will also need a registry authenticaion Secret to pull images.

Create a Secret using the same registry credentials:

```
kubectl create secret docker-registry -n integration-test registry-creds --docker-server=$REGISTRY_SERVER --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_PASSWORD
```

Now open the [Jenkinsfile](./project/Jenkinsfile), scroll to the end and uncomment the stage called _Deploy to test namespace_: delete the `/*` line at the start of the stage and the `*/` line at the end.

Push your changes to Gogs, and the pipeline will be updated in Jenkins:

```
# remove /* and */ comment lines from Jenkinsfile

git add labs/jenkins/project/Jenkinsfile

git commit -m 'Enable CD'

git push labs-jenkins
```

Browse back to your build at http://localhost:30008/job/kiamol/ - click _Build Now_ a few times to push images with different version numbers.

Check the CI/CD deployment works and is running the latest version:

```
helm ls -n integration-test

curl localhost:30029

kubectl get rs -n integration-test -o wide
```

> You should see the updated build versions in the image tags.

## Lab

This lab gets you to make use of the CI/CD pipeline to update the whoami app. The [Dockerfile](./project/src/Dockerfile) for the app needs updating and optimizing:

- the build stage should use the latest Go SDK on the latest version of the Alpine OS
- the final image doesn't need any OS tools, so it can be `FROM` a minimal image

Make your changes to the Dockerfile and check the image builds locally. Then push your changes to Gogs and confirm the app updates to your new image version and works correctly.

Pull your latest image and the one before that - is there a size difference?

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup

Remove the Helm releases:

```
helm uninstall whoami-dev

helm uninstall whoami-int -n integration-test
```

And all the other components:

```
kubectl delete ns -l kubernetes.courselabs.co=jenkins
```

Then remove your Git remote:

```
git remote rm labs-jenkins
```

👩‍🏫 **For the instructor** - remember to reset the Dockerfile and Jenkinsfile for the next class :)

```
cp labs/jenkins/project/src/Dockerfile.original labs/jenkins/project/src/Dockerfile
cp labs/jenkins/project/Jenkinsfile.original labs/jenkins/project/Jenkinsfile

git add labs/jenkins/project/src/Dockerfile
git add labs/jenkins/project/Jenkinsfile

git commit -m 'Reset Jenkins lab'
git push origin
```