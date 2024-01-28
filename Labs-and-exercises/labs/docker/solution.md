# Lab Solution

Running the app with a custom port just needs you to pass the arguments to the application:

```
# run the app listening on port 5000 inside the container:
docker run -d -P --name whoami2 whoami -port 5000
```

## Troubleshooting

You can check the port the app uses - but if you try to call it you won't get a response:

```
docker port whoami2

curl localhost:<port>
```

Check the logs and you'll see why - Docker is directing traffic to port 80, which is the port the image exposes. But the app is not listening on that port:

```
docker logs whoami2
```

## The fix

You need to explicitly map the port if you're configuring the app to use a port which is not exposed in the image:

```
docker run -d -p 8050:5000 --name whoami3 whoami -port 5000

curl localhost:8050
```

Or if you want Docker to set a random host port, specify only the target port:

```
docker run -d -p :5000 --name whoami4 whoami -port 5000

docker port whoami4

curl localhost:<port>
```

> Back to the [exercises](README.md)