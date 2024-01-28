# Lab Solution

The only changes you need to make here are to the `FROM` lines in the Dockerfile.

In my [sample solution](./solution/Dockerfile) I've changed both lines:

```
FROM golang:1.17.1-alpine3.14 AS builder
# ...
FROM scratch
```

That's the latest [official Go image](https://hub.docker.com/_/golang?tab=tags&page=1&ordering=last_updated) version using the latest Alpine version for the builder stage. 

The final stage uses [scratch](https://hub.docker.com/_/scratch/), which means there is no base image.

You can copy the solution over the project Dockerfile, and push changes to start a new build:

```
cp labs/jenkins/solution/Dockerfile labs/jenkins/project/src/

git add labs/jenkins/project/src/Dockerfile

git commit -m 'Jenkins lab solution'

git push labs-jenkins
```

Check the build at http://localhost:30008/job/kiamol/

> The new build should trigger an update and when the Helm upgrade has finished, the app should work in the same way 

Test the app with `curl localhost:30028`. Then pull your two latest images and compare them. My optimized image is 1/3 smaller than the previous one:

```
> docker image ls courselabs/whoami-lab
REPOSITORY              TAG       IMAGE ID       CREATED   
           SIZE

courselabs/whoami-lab   21.09-4   061235acbb98   About a minute ago   8.22MB

courselabs/whoami-lab   21.09-3   4deca9963c2a   5 hours ago          12.7MB
```

> Back to the [exercises](README.md)