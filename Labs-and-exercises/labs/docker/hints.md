# Lab Hints

The [Dockerfile](./whoami/Dockerfile) for the app uses the `ENTRYPOINT` instruction to start the app, so any arguments you pass to the `docker run` command get passed onto the container.

In the Dockerfile the `EXPOSE` command tells Docker which ports the app expects to listen to. This is built into the image as metadata, it's not linked to the ports the app actually listens on. 

Publishing all ports won't do what you want if the app listens on a different port than the container image expects.

> Need more? Here's the [solution](solution.md).