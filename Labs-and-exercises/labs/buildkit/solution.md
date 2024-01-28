# Lab Solution

Connect to a shell session in the BuildKit CLI Pod (if you're not already connected):

```
kubectl exec -it buildkit-cli -- sh
```

Set an environment variable for the build version:

```
export BUILD_VERSION=0.1.0
```

Add the tag to the `name` field in the `output` parameter, separating it from the image name with a colon:

```
cd ~

buildctl --addr tcp://buildkitd:1234 build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${REGISTRY}/${REPOSITORY}/simple:${BUILD_VERSION},push=true
```

Now you can update the version number and repeat the same command:

```
export BUILD_VERSION=0.2.0

buildctl --addr tcp://buildkitd:1234 build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${REGISTRY}/${REPOSITORY}/simple:${BUILD_VERSION},push=true
```

Check your tags on Docker Hub (or your own registry) to verify the new images have been pushed.