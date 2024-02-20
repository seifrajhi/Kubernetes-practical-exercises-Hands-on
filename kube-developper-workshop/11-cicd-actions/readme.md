# 👷 CI/CD with Kubernetes

This is an optional section detailing how to set up a continuous integration (CI) and continuous
deployment (CD) pipeline, which will deploy to Kubernetes using Helm.

There are many CI/CD solutions available, we will use GitHub Actions, as it's easy to set up and most
developers will already have GitHub accounts. It assumes familiarity with git and basic GitHub usage
such as forking & cloning.

> 📝 NOTE: This is not intended to be full guide or tutorial on GitHub Actions, you would be better
> off starting [here](https://docs.github.com/en/actions/learn-github-actions) or
> [here](https://docs.microsoft.com/en-us/learn/paths/automate-workflow-github-actions/?source=learn).

## 🚩 Get Started with GitHub Actions

We'll use a fork of this repo in order to set things up, but in principle you could also start with
an new/empty repo on GitHub.

- Go to the repo for this workshop [https://github.com/benc-uk/kube-workshop](https://github.com/benc-uk/kube-workshop).
- Fork the repo to your own personal GitHub account, by clicking the 'Fork' button near the top right.
- Clone the forked repo from GitHub using git to your local machine.

Inside the `.github/workflows` directory, create a new file called `build-release.yaml` and paste in
the contents:

> 📝 NOTE: This is special directory path used by GitHub Actions!

```yaml
# Name of the workflow
name: CI Build & Release

# Triggers for running
on:
  workflow_dispatch: # This allows manually running from GitHub web UI
  push:
    branches: ["main"] # Standard CI trigger when main branch is pushed

# One job for building the app
jobs:
  buildJob:
    name: "Build & push images"
    runs-on: ubuntu-latest
    steps:
      # Checkout code from another repo on GitHub
      - name: "Checkout app code repo"
        uses: actions/checkout@v2
        with:
          repository: benc-uk/smilr
```

The comments in the YAML should hopefully explain what is happening. But in summary this will run a
short single step job that just checks out the code of the Smilr app repo. The name and filename do
not reflect the current function, but the intent of what we are building towards.

Now commit the changes and push to the main branch, yes this is not a typical way of working, but
adding a code review or PR process would merely distract from what we are doing.

The best place to check the status is from the GitHub web site and in the 'Actions' within your
forked repo, e.g. `https://github.com/{your-github-user}/kube-workshop/actions` you should be able
to look at the workflow run, the status, plus output & other details.

> 📝 NOTE: It's unusual for the code you are building to be a in separate repo from the workflow(s),
> in most cases they will be in the same code base, however it doesn't really make any difference to
> the approach we will take.

## ⌨️ Set Up GitHub CLI

Install the GitHub CLI, this will make setting up the secrets required in the next part much more simple.
All commands below assume you are running them from within the path of the cloned repo on your local
machine.

- On MacOS: [https://github.com/cli/cli#macos](https://github.com/cli/cli#macos)
- On Ubuntu/WSL: `curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/gh.sh | bash`

Now login using the GitHub CLI, follow the authentication steps when prompted:

```bash
gh auth login
```

Once the CLI is set up it, we can use it to create a [secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
within your repo, called `ACR_PASSWORD`. We'll reference this secret in the next section. This combines
the Azure CLI and GitHub CLI into one neat way to get the credentials:

```bash
gh secret set ACR_PASSWORD --body "$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)"
```

## 📦 Add CI Steps For Image Building

The workflow, doesn't really do much, the applicaiton gets built and images created but they go nowhere.
So let's update the workflow YAML to carry out a build and push of the application container images.
We can do this using the code we've checked out in the previous workflow step.

Add this as the YAML top level, e.g just under the `on:` section, change the `__YOUR_ACR_NAME__`
string to the name of the ACR you deployed previously (do not include the azurecr.io part).

```yaml
env:
  ACR_NAME: __YOUR_ACR_NAME__
  IMAGE_TAG: ${{ github.run_id }}
```

Add this section under the "Checkout app code repo" step in the job, it will require indenting to the
correct level:

```yaml
      - name: "Authenticate to access ACR"
        uses: docker/login-action@master
        with:
          registry: ${{ env.ACR_NAME }}.azurecr.io
          username: ${{ env.ACR_NAME }}
          password: ${{ secrets.ACR_PASSWORD }}

      - name: "Build & Push: data API"
        run: |
          docker buildx build . -f node/data-api/Dockerfile \
            -t $ACR_NAME.azurecr.io/smilr/data-api:$IMAGE_TAG \
            -t $ACR_NAME.azurecr.io/smilr/data-api:latest
          docker push $ACR_NAME.azurecr.io/smilr/data-api:$IMAGE_TAG

      - name: "Build & Push: frontend"
        run: |
          docker buildx build . -f node/frontend/Dockerfile \
            -t $ACR_NAME.azurecr.io/smilr/frontend:$IMAGE_TAG \
            -t $ACR_NAME.azurecr.io/smilr/frontend:latest
          docker push $ACR_NAME.azurecr.io/smilr/frontend:$IMAGE_TAG
```

Save the file, commit and push to main just as before. Then check the status from the GitHub UI and
'Actions' page of your forked repo.

The workflow now does three important things:

- Authenticate to "login" to the ACR.
- Build the **smilr/data-api** image and tag as `latest` and also the GitHub run ID, which is unique
  to every run of the workflow. Then push these images to the ACR.
- Do exactly the same for the **smilr/frontend** image.

The "Build & push images" job and the workflow should take around 2~3 minutes to complete.

## 🔌 Connect To Kubernetes

We'll be using an approach of "pushing" changes from the workflow pipeline to the cluster, really
exactly the same as we have been doing from our local machines with `kubectl` and `helm` commands.

To do this we need a way to authenticate, so we'll use another GitHub secret and store the cluster
credentials in it.

There's a very neat 'one liner' command you can run to do this. It's taking the output of the
`az aks get-credentials` command we ran previously and storing the result as a secret called
`CLUSTER_KUBECONFIG`. Run the following:

```bash
gh secret set CLUSTER_KUBECONFIG --body "$(az aks get-credentials --name $AKS_NAME --resource-group $RES_GROUP --file -)"
```

Next add a second job called `releaseJob` to the workflow YAML, beware the indentation,
this should under the `jobs:` key

```yaml
  releaseJob:
    name: "Release to Kubernetes"
    runs-on: ubuntu-latest
    if: ${{ github.ref == 'refs/heads/main' }}
    needs: buildJob

    steps:
      - name: "Configure kubeconfig"
        uses: azure/k8s-set-context@v2
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.CLUSTER_KUBECONFIG }}

      - name: "Sanity check Kubernetes"
        run: kubectl get nodes
```

This is doing a bunch of things so lets step through it:

- This second job has a dependency on the previous build job, obviously we don't want to run a
  release & deployment if the build has failed or hasn't finished!
- This job will only run if the code is in the `main` branch, which means we won't run deployments
  on pull requests, this is a common practice.
- It uses the `azure/k8s-set-context` action and the `CLUSTER_KUBECONFIG` secret to
  authenticate and point to our AKS cluster.
- We run a simple `kubectl` command to sanity check we are connected ok.

Save the file, commit and push to main just as before, and check the status using the GitHub
actions page.

## 🪖 Deploy using Helm

Nearly there! Now we want to run `helm` in order to deploy the Smilr app into the cluster, but also
make sure it deploys from the images we just built and pushed. There's two ways for Helm to access
a chart, either using the local filesystem or a remote chart published to a chart repo. We'll be
using the first approach. The Smilr git repo contains a Helm chart for us to use, we'll check it out
and then run `helm` to release the chart.

Add the following two steps to the releaseJob (beware indentation again!)

```yaml
      - name: "Checkout app code repo" # Needed for the Helm chart
        uses: actions/checkout@v2
        with:
          repository: benc-uk/smilr

      - name: "Update chart dependencies"
        run: helm dependency update ./kubernetes/helm/smilr
```

You can save, commit and push at this point to run the workflow and check everything is OK, or push
onto the next step.

Add one final step to the releaseJob, which runs the `helm upgrade` command to create or update a release. See the [full docs on this command](https://helm.sh/docs/helm/helm_upgrade/)

```yaml
      - name: "Release app with Helm"
        run: |
          helm upgrade myapp ./kubernetes/helm/smilr --install --wait --timeout 120s \
          --set registryPrefix=$ACR_NAME.azurecr.io/ \
          --set frontend.imageTag=$IMAGE_TAG \
          --set dataApi.imageTag=$IMAGE_TAG \
          --set mongodb.enabled=true
```

This command is doing an awful lot, so let's break it down:

- `helm upgrade` tells Helm to upgrade an existing release, as we also pass `--install` this means
  Helm will install it first if it doesn't exist. Think of it as create+update, or an "upsert"
  operation.
- The release name is `myapp` but could be anything you wish, it will be used to prefix all the
  resources in Kubernetes.
- The chart is referenced by filesystem path `./kubernetes/helm/smilr` which is why we checked out
  the Smilr git repo before this step. The GitHub link to that directory
  [is here of you are curious](https://github.com/benc-uk/smilr/tree/master/kubernetes/helm/smilr)
- The `--set` flags pass parameters into the chart for this release, which are the ACR name, plus
  the image tags we just built. These are available as variables in our workflow `$ACR_NAME` and
  `$IMAGE_TAG`
- The `--wait --timeout 120s` flags tell Helm to wait 2 minutes for the Kubernetes pods to start

Phew! As you can see Helm is a powerful way to deploy apps to Kubernetes, sometimes with a single
command

Once again save, commit and push, then check the status of the workflow. It's very likely you made
a mistake, keep committing & pushing to fix and re-run the workflow until it completes and runs
green.

You can validate the deployment with the usual `kubectl get pods` command and `helm ls` to view
the Helm release. Hopefully all the pods should be running.

## 🏅 Bonus - Environments

GitHub has the concept of [environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment), which are an abstraction representing a target set of
resources or a deployed application. This lets you use the GitHub UI to see the status of deployments
targeting that environment, and even give users a link to access it

We can add an environment simply by adding the follow bit of YAML under the releaseJob job:

```yaml
    environment:
      name: workshop-environment
      url: http://__PUBLIC_IP_OF_CLUSTER__/
```

Tip. The `environment` part needs to line up with the `needs` and `if` parts in the job YAML.

The `name` can be anything you wish and the URL needs to point to the public IP address of your
cluster which you were referencing earlier, if you've forgotten it try running  
`kubectl get svc -A | grep LoadBalancer | awk '{print $5}'`

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../10-gitops-flux/readme.md)
