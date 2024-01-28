# Lab Hints

You can use the same buildctl Pod that we used in the exercises.

The build command needs to add the tag to the image name - the format is the same as with the `docker build -t` command.

An automation server like Jenkins or GitHub Actions will populate a build number as an environment variable, but the release version will need to be set in your scripts. You can do it manually here with the Linux `export` command.

> Need more? Here's the [solution](solution.md).