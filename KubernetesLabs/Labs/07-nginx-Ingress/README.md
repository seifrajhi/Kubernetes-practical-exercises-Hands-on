

# K8S Hands-on


---

# Nginx-Ingress

### ✅ !!! Important - 
> We cannot see it in action on local host (meaning that it will not get external ip) unless we use the explicit 
http://host:port


- Kubernetes ingress object is a DNS
- To enable an ingress object, we need an ingress controller
- In this demo we will use nginx-ingress
- To get started with nginx-ingress, we will deploy out previous app
    ```sh
    # Create 3 containers
    $ kubectl run ingress-pods --image=nirgeier/k8s-secrets-sample --replicas=3

    # Expose the service
    $ kubectl expose deployment ingress-pods --port=5000
    ```
- Now lets deploy the nginx-ingress (grabbed from the official site) 
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
        name: default-http-backend
    spec:
        replicas: 1
        selector:
            matchLabels:
            app: default-http-backend
        template:
            metadata:
            labels:
                app: default-http-backend
            spec:
                terminationGracePeriodSeconds: 60
                containers:
                - name: default-http-backend
                    # Any image is permissable as long as:
                    # 1. It serves a 404 page at /
                    # 2. It serves 200 on a /healthz endpoint
                    image: gcr.io/google_containers/defaultbackend:1.0
                    livenessProbe:
                    httpGet:
                        path: /healthz
                        port: 8080
                        scheme: HTTP
                    initialDelaySeconds: 30
                    timeoutSeconds: 5
                    ports:
                    - containerPort: 8080
                    resources:
                    limits:
                        cpu: 10m
                        memory: 20Mi
                    requests:
                        cpu: 10m
                        memory: 20Mi
    ```   
- Next create the service
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
        name: default-http-backend
    spec:
        selector:
        app: default-http-backend
        ports:
        - protocol: TCP
        port: 80
        targetPort: 8080
        type: NodePort
    ```          
### Import ssl certificate       
-   In this demo we will use certificate.    
-   The certificate is in the same folder as this file
-   The certificate is for the host name: `ingress.local`
    ```sh
    # If you wish to create the certificate use this script
    ### ---> The common Name fiels is your host for later on
    ###      Common Name (e.g. server FQDN or YOUR name) []:
    $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certificate.key -out certificate.crt
    
    # Create a pem file
    # The purpose of the DH parameters is to exchange secrets
    $ openssl dhparam -out certificate.pem 2048
    ```
- Store the certificate in secret    
    ```sh
    # Store the certificate
    $ kubectl create secret tls tls-certificate --key certificate.key --cert certificate.crt
    secret/tls-certificate created

    # Store the DH parameters
    $ kubectl create secret generic tls-dhparam --from-file=certificate.pem
    secret/tls-dhparam created
    ```
### Deploy the ingress
- Now that we have the certificate we can deploy the Ingress
    ```yaml
    # Ingress.yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
        name: my-first-ingress
    annotations:
        kubernetes.io/ingress.class: "nginx"
        nginx.org/ssl-services: "my-service"
    spec:
        tls:
            - hosts:
            - myapp.local
            secretName: tls-certificate
        rules:
        - host: myapp.local
            http:
            paths:
            - path: /
                backend:
                serviceName: ingress-pods
                servicePort: 5000
    ```

### Enable the ingress addon 
- The ingress is not enabled by default and we have to "turn it on"
    ```sh
    $ minikube addons enable ingress
    ✅  ingress was successfully enabled
    ```

<!-- navigation start -->

---

<div align="center">
:arrow_left:&nbsp;
  <a href="../06-DataStore">06-DataStore</a>
&nbsp;&nbsp;||&nbsp;&nbsp;  <a href="../08-Kustomization">08-Kustomization</a>
  &nbsp;:arrow_right:</div>

---

<div align="center">
  <small>&copy;CodeWizard LTD</small>
</div>



<!-- navigation end -->