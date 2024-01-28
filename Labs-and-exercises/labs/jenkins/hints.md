# Lab Hints

You don't need to be a Go expert to optimize this image. The current Dockerfile uses an older version of the Go SDK, which is based on an old version of Alpine. 

Find the image details on the registry and you'll see you can use the latest SDK and the latest OS with a change to the first stage of the Dockerfile.

For the second stage - you can build Docker images which have no base OS image at all. There's a special `FROM` instruction you can use for that, which uses an image name that isn't a real image.

> Need more? Here's the [solution](solution.md).