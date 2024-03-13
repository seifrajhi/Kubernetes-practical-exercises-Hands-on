# [Docker](https://docs.docker.com/get-started/overview/)

<br />

### Given the docker file, 
- Build a container image with the name nginxer and tag 3.0.
- Export the built container image in OCI-format and store in at `nginxer-3.0.tar`
- Run container from image `nginxer:3.0` with name `nginxer-go` expsoing port `80`

```bash
FROM nginx:alpine
CMD ["nginx", "-g", "daemon off;"]
```

<br />

<details><summary>show</summary><p>

```bash
docker build . -t nginxer:3.0
docker save nginxer:3.0 -o nginxer-3.0.tar
docker run --name nginxer-go -p 80:80 nginxer:3.0
``` 

</p></details>

<br />

### Given the docker file which creates an alpine container exposing port 80. Apply 2 best practices to improve security of the image.

```bash
FROM alpine:3.12
RUN adduser -D myuser && chown -R myuser /myapp-data
USER root
ENTRYPOINT ["/myapp"]
EXPOSE 80 8080 22
```

<br />

<details><summary>show</summary><p>

```bash
FROM alpine:3.12
RUN adduser -D myuser && chown -R myuser /myapp-data
USER myuser # Avoid unnecessary privileges - run as a custom user.
ENTRYPOINT ["/myapp"]
EXPOSE 80 # Exposed ports - Expose only neccesary port 
```

</p></details>

<br />






