# Lab Hints

This is where the sidecar pattern comes in - running another container in the Pod, which can share part of the filesystem with the application container.

Your new container can use a minimal Linux OS as the image, with the `tail` command reading the application log file. All the log entries will be printed by this container and they'll surface as Pod logs.

> Need more? Here's the [solution](solution.md).