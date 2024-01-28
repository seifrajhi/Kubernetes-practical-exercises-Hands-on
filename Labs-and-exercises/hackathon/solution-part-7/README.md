## Hackathon Part 7 Solution

Remember you can scale down existing pods if you're low on resources:

```
kubectl scale deploy/products-api deploy/stock-api deploy/web sts/products-db --replicas 0
```

_Deploy the Helm chart to a new namespace using a sample variables file:_

```
helm install widg-uat -n widg-uat --create-namespace -f hackathon/files/helm/uat.yaml hackathon/solution-part-7/helm/widgetario
```

_Check the objects:_

```
kubectl get all -n widg-uat

kubectl get ingress -A
```

_Add hosts for the new domains:_

```
# On Windows (run as Admin)
./scripts/add-to-hosts.ps1 widgetario.uat 127.0.0.1
./scripts/add-to-hosts.ps1 api.widgetario.uat 127.0.0.1

# OR on Linux/macOS
./scripts/add-to-hosts.sh widgetario.uat 127.0.0.1
./scripts/add-to-hosts.sh api.widgetario.uat 127.0.0.1
```

Try the Products API:

```
curl -k https://api.widgetario.uat/products
```

> Browse to http://widgetario.uat; you'll see a new _Buy_ button from the latest image update

_Deploy the build infrastructure:_

```
kubectl apply -f hackathon/solution-part-7/infrastructure
```

_When it's all running, push your local code to Gogs:_

```
git remote add hackathon http://localhost:30031/kiamol/kiamol.git

git push hackathon main
```

_create registry creds - add your details with variables or use the scripts in the [Jenkins lab](../../labs/jenkins/README.md):_

```
kubectl -n infra create secret docker-registry registry-creds --docker-server=$REGISTRY_SERVER --docker-username=$REGISTRY_USER --docker-password=$REGISTRY_PASSWORD
```

_Create a configmap with the details for the image name - be sure to use a registry and domain you have push access for:_

```
kubectl -n infra create configmap build-config --from-literal=REGISTRY=docker.io  --from-literal=REPOSITORY=$REGISTRY_USER 
```

_Restart Jenkins to load the latest config:_

```
kubectl rollout restart deploy/jenkins -n infra
```

> Browse to Jenkins http://localhost:30007, sign in with the `kiamol` username and password

Open the Widgetario job in Jenkins, enable and build it. Confirm that your images build and are pushed with the correct tags.

_Add the Helm deploy stage to Jenkins:_

You can edit the Jenkisfile, or change the job to use the [part 7 solution Jenkinsfile](./Jenkinsfile):

- open http://localhost:30880/job/widgetario/configure
- scroll down to _Script Path_
- change the path to `hackathon/solution-part-7/Jenkinsfile`

Build again and confirm the latest images are deployed in the new namespace.

_Add smoke test domain to hosts file:_

```
# On Windows (run as Admin)
./scripts/add-to-hosts.ps1 widgetario.smoke 127.0.0.1
./scripts/add-to-hosts.ps1 api.widgetario.smoke 127.0.0.1

# OR on Linux/macOS
./scripts/add-to-hosts.sh widgetario.smoke 127.0.0.1
./scripts/add-to-hosts.sh api.widgetario.smoke 127.0.0.1
```

Check the Products API:

```
curl -k https://api.widgetario.smoke/products
```

> And test the app at http://widgetario.smoke
