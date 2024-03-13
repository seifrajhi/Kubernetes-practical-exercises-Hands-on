# [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

- Ingress manages external access to the services in a cluster, typically HTTP.
- Ingress may provide load balancing, SSL termination and name-based virtual hosting.

<br />

### Create the following
 - Deployment `web` with image `gcr.io/google-samples/hello-app:1.0` with 3 replicas. 
 - Service `web` to expose the deployment as Node Port
 - Ingress `web-ingress` to point to the `web` service using host `hellow-world.info`.

<br /> 
  
<details><summary>show</summary><p>

```bash
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment web --type=NodePort --port=8080
kubectl get service web
# NAME   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
# web    NodePort   10.104.218.215   <none>        8080:30807/TCP   12s
```

#### Create Ingress with the below specs and apply using `kubectl apply -f web-ingress.yaml`

```bash
kubectl create ingress web-ingress --rule="hello-world.info/=web:8080"
```

OR

```yaml
cat << EOF > web-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - host: hello-world.info
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 8080
EOF

kubectl apply -f web-ingress.yaml
```

OR below for older versions

```yaml
cat << EOF > web-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: hello-world.info
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          serviceName: web
          servicePort: 8080
EOF

kubectl apply -f web-ingress.yaml
```

```bash
# verification
kubectl get nodes -o wide # get node ip
kubectl get deploy web # check status
kubectl get svc web # check node port ip
curl http://10.0.26.3:32104 # use node ip:node port
kubectl get ingress web-ingress # you will get an ip address of the ingress controller if installed
# NAME          CLASS    HOSTS              ADDRESS   PORTS   AGE
# web-ingress   <none>   hello-world.info             80      11s
```

</p></details> 

<br />

## Ingress Security

<br />

### Create a tls secret `testsecret-tls` using tls.crt from file `../data/tls.crt` and `../data/tls.key`. Enable tls for the ingress below.

<br />

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  rules:
  - host: https-example.foo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 80
```

<details><summary>show</summary><p>

```bash
kubectl create secret tls testsecret-tls --cert=tls.crt --key=tls.key
```

```yaml

cat << EOF > tls-example-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls: # add tls entry 
  - hosts:
      - https-example.foo.com
    secretName: testsecret-tls
  rules:
  - host: https-example.foo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 80
EOF

kubectl apply -f tls-example-ingress.yaml

```

```bash
# verification
kubectl get secret testsecret-tls
kubectl get ingress tls-example-ingress
```

</p></details> 

<br />

### Clean up

<br />

```bash
kubectl delete secret testsecret-tls
kubectl delete ingress web-ingress tls-example-ingress
kubectl delete svc web
kubectl delete deployment web
```