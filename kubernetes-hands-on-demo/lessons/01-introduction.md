## Containers and Docker

A overview of docker, images, and containers.

### What is Docker?

Docker is a container runtime that allows you to develop, ship, and run applications.

### What is a Image?

A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application. A container gets instantiated from a container image.

### What is a Container?

A container is a standard unit of software where you code and all its dependencies has been packaged up, so the application can run quickly and reliably from one computing environment to another.

Advantages of using Containers:

* Portable, once you build your image you can run a container anywhere on a container runtime (wrt linux containers)
* Lightweight, as containers share the kernel of the OS
* Secure, while containers share the OS kernel with other containers, each running as isolated processes in user space.
* Version control

A nice demonstration on the difference between containers and VM's (from: docker.com):

<img width="1173" alt="A6453138-A163-43D8-9A4A-2CEC8E86BC1A" src="https://user-images.githubusercontent.com/567298/66056117-e9803900-e536-11e9-8a02-e35307bd296f.png">

### Container Workflow

From building a container to running one, will be like the following:

- Pull: Downloads the upstream image to the docker host
- Build: Builds the image from the Dockerfile
- Push: Push the built image to a docker registry
- Run: Runs a container from a image

a Dockerfile declares how our application will be built:

```
FROM python:3.7
RUN pip install requests
ADD app.py /code/
CMD ["python", "/code/app.py"]
```

Every step will be run in its own layer:

1. FROM: Specifies which upstream image we want to use as our base.
2. RUN: The command that we are running inside the container, in this example installing the requests library
3. ADD: We are adding `app.py` from our local directory to `/code/app.py` in our container
4. CMD: Specifies the executable to start our application

Change to the lab directory where the `Dockerfile` and `app.py` is located:

```
$ cd ../labs/00-docker/
```

To build our image, we use the `docker build` command and specify which Dockerfile we want to use and also the tag we want as our image that will be hosted on the docker host.

```
$ docker build -f Dockerfile -t local-example:v1 .
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM python:3.7
 ---> 60e318e4984a
Step 2/4 : RUN pip install requests
 ---> Running in 2e0e7b6476b7
Collecting requests
  Downloading https://files.pythonhosted.org/packages/51/bd/23c926cd341ea6b7dd0b2a00aba99ae0f828be89d72b2190f27c11d4b7fb/requests-2.22.0-py2.py3-none-any.whl (57kB)
Collecting idna<2.9,>=2.5 (from requests)
  Downloading https://files.pythonhosted.org/packages/14/2c/cd551d81dbe15200be1cf41cd03869a46fe7226e7450af7a6545bfc474c9/idna-2.8-py2.py3-none-any.whl (58kB)
Collecting certifi>=2017.4.17 (from requests)
  Downloading https://files.pythonhosted.org/packages/18/b0/8146a4f8dd402f60744fa380bc73ca47303cccf8b9190fd16a827281eac2/certifi-2019.9.11-py2.py3-none-any.whl (154kB)
Collecting urllib3!=1.25.0,!=1.25.1,<1.26,>=1.21.1 (from requests)
  Downloading https://files.pythonhosted.org/packages/e0/da/55f51ea951e1b7c63a579c09dd7db825bb730ec1fe9c0180fc77bfb31448/urllib3-1.25.6-py2.py3-none-any.whl (125kB)
Collecting chardet<3.1.0,>=3.0.2 (from requests)
  Downloading https://files.pythonhosted.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl (133kB)
Installing collected packages: idna, certifi, urllib3, chardet, requests
Successfully installed certifi-2019.9.11 chardet-3.0.4 idna-2.8 requests-2.22.0 urllib3-1.25.6
Removing intermediate container 2e0e7b6476b7
 ---> 3a4ed53e27a3
Step 3/4 : ADD app.py /code/
 ---> 44591c4c5df7
Step 4/4 : CMD ["python", "/code/app.py"]
 ---> Running in 840c513a8e4d
Removing intermediate container 840c513a8e4d
 ---> 33f7ba91d789
Successfully built 33f7ba91d789
Successfully tagged local-example:v1
```

And running a container from our built image:

```
$ docker run local-example:v1
Response is: 200
```


### Resources:

- https://www.docker.com/resources/what-container
- https://docs.docker.com/engine/
