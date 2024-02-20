# 👷 CI/CD with Kubernetes

This is an optional section detailing how to set up a continuous integration (CI) and continuous
deployment (CD) pipeline, which will deploy to Kubernetes using Helm.

There are many CI/CD solutions available, we will use GitHub Actions, as it's easy to set up and most
developers will already have GitHub accounts. It assumes familiarity y with git and basic GitHub usage
such as forking & cloning.

> 📝 NOTE: This is not intended to be full guide or tutorial on GitHub Actions, you would be better
> off starting [here](https://docs.github.com/en/actions/learn-github-actions)
> or [here](https://docs.microsoft.com/en-us/learn/paths/automate-workflow-github-actions/?source=learn)

## 🔰 Get Started with GitHub Actions

We'll use a fork of this repo in order to set things up, but in principle you could also start with
an new/empty repo on GitHub.

- Go to the repo for this workshop <https://github.com/benc-uk/kube-workshop>.
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

The best place to check the status is from the GitHub web site and in the 'Actions' within your forked
repo, e.g. `https://github.com/{your-github-user}/kube-workshop/actions` you should be able to look at the workflow run, the status plus output & other details.

## ⌨️ Set Up GitHub CLI

Install the GitHub CLI, this will make setting up the secrets required in the next part much more simple. All commands below assume you are running them from within the path of the cloned repo on your local machine.

- On MacOS: [https://github.com/cli/cli#macos](https://github.com/cli/cli#macos)
- On Ubuntu/WSL: `curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/kubectl.sh | bash`

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

The workflow, doesn't really do much, so let's update the workflow YAML to carry out a build and push
of the application container images. We can do this using the code we've checked out in the previous
workflow step.

Add this as the YAML top level, e.g just under the `on:` section, change the `__YOUR_ACR_NAME__` string
to the name of the ACR you deployed previously (do not include the azurecr.io part).

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

## Navigation

[Return to Main Index 🏠](../../readme.md)
[Previous Section ⏪](../10-gitops-flux/readme.md)
