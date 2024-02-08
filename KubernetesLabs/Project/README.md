![](../../../)

---

# Kubernetes Project

- The project will cover the following:

  - Docker
  - Kubernetes
  - Git
  - Jenkins

- The outcome of this project should be a sxcript which run all the required parts

---

## Pre Requirements

- Kubernetes cluster
  - For this project you can choose any cluoud provider you wish

## The project should have the following features:

- Git porject with Pipeline as code inside
- Jenkins pipelines for building and deploying the artifcates
- K8S cluster for the deployment

---

### Project breakdown:

- Build a Jenkins pipeline (Pipeline as code) which does the following:
  - Checkout the lates git source code
    - The code should be any application you wish as long as it can be scalled
  - Build the project (compile source code) if required
  - Execute test (or just print echo if there arent any test for the given project)
  - Build the Docker image with all the requirements
  - Deploy the Image to a K8S cluster
    - The project should include all the yaml files each defined in its own file
    - The project should have an Kustomize file for the K8S resources
    - The project should include a [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) which will restart the pods every 5 minutes
    - All the pods need to use a shared volume and will write the logs/outputs to this folder
    - The pods should implements a readiness or liveness probes
    - The configuration like ports, names etc should be loaded from ConfigMap
