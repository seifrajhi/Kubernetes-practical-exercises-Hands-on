### What is Kubernetes?

Kubernetes is a Container Orchestrator for Managing Highly-Available and Fault-Tolerant containerized workloads. Kubernetes clusters abstracts their underlying computing resources allowing users to deploy their workloads to a cluster, instead of to a particular server.

### Why Kubernetes?

Managing one container is easy, managing thousands of containers are difficult and that is where a orchestrator shines. It works in a desired state configuration, so if you run a deployment and you want 5 containers, the orchestrator will always make sure that there is 5 running containers. If a node fails or a container fails, the orchestrator will ensure that it replaces the failed containers to meet the desired state.

Kubernetes automates deployment using declarative statement and enforces desired state.

### Kubernetes Architecture

<img width="833" alt="image" src="https://user-images.githubusercontent.com/567298/66088402-430a5700-e57b-11e9-9d11-9e4decd59c0e.png">

