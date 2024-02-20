# Kubernetes Networking - Ingress

1. Create a K8S cluster (or you can use minikube, docker for mac ...) <br>
Check out https://github.com/tigera-solutions/onprem-k8s-calico-oss

2. List the nodes

```
kubectl get no 
```

3. List namespaces
```
kubectl get namespaces
``` 
4. Clone this repo
```
git clone https://github.com/tigera-solutions/ingress_kubernetes_workshop.git
```

5. Create a small demo app1 and app2
```
kubectl create ns app1
kubectl apply -n app1 -f nginx-deployment.yaml
kubectl apply -n app1 -f nginx-expose-clusterip.yaml
```

```
kubectl create ns app2
kubectl apply -n app2 -f nginx-deployment.yaml
kubectl apply -n app2 -f nginx-expose-clusterip.yaml
```

6. Test app1 and app2 
```
kubectl get namespaces
kubectl get all -n app1  -o wide 
kubectl get all  -n  app2 -o wide 
```

```
kubectl run -it -n app1 --rm --image dockersec/siege siege -- siege http://my-nginx-clusterip
kubectl run -it -n app2 --rm --image dockersec/siege siege -- siege http://my-nginx-clusterip
```

7. Let's install a default nginx Ingress controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/baremetal/deploy.yaml
```
```
kubectl get namespaces
kubectl get po -n ingress-nginx -o wide 
kubectl get svc -n ingress-nginx 
```

Export the NodePorts to make out life easier
```
export SECUREWEB=$(kubectl get svc ingress-nginx-controller -n ingress-nginx  -n ingress-nginx -o=jsonpath="{.spec.ports[?(@.port==443)].nodePort}")
export WEB=$(kubectl get svc ingress-nginx-controller -n ingress-nginx  -n ingress-nginx -o=jsonpath="{.spec.ports[?(@.port==80)].nodePort}")
echo $WEB
echo $SECUREWEB 
```
```
curl -kv http://localhost:$WEB  #change the portsnumber according kubectl svc -n ingress-nginx
curl -kv https://localhost:$SECUREWEB  #change the portsnumber according kubectl svc -n ingress-nginx
```

8. Let's configure an Ingress resource  app1_ingress.yaml
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: app1-ingress
spec:
  rules:
  - host: app1.dockersec.me
    http:
      paths:
      - backend:
          serviceName: my-nginx-clusterip
          servicePort: 80
```
```
kubectl apply -n app1 -f app1_ingress.yaml
kubectl  get ingress  -n app1
```

```
curl -kv  -H "Host: app1.dockersec.me" http://localhost:$WEB
curl -kv  -H "Host: app2.dockersec.me" http://localhost:$WEB  #this should not work
```

9. Let's configure an Ingress resource  app2_ingress.yaml

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: app2-ingress
spec:
  rules:
  - host: app2.dockersec.me
    http:
      paths:
      - backend:
          serviceName: my-nginx-clusterip
          servicePort: 80
```
```
kubectl apply -n app2 -f app2_ingress.yaml
kubectl  get ingress  -n app2
```
```
curl -kv  -H "Host: app1.dockersec.me" http://localhost:$WEB
curl -kv  -H "Host: app2.dockersec.me" http://localhost:$WEB  #this should work now
```



10. Check the nginx config file in the nginx-ingress-controller ....


11. Create a certificate and key

```
openssl req -x509 -newkey rsa:2048 -keyout tls.key -out tls.crt -days 365 -nodes -subj "/CN=tlsapp1.dockersec.me"
kubectl create secret tls tlscertsapp1 -n app1 --cert=./tls.crt --key=./tls.key
kubectl describe secret -n app1 tlscertsapp1
```



12 create tlsapp1_ingress.yaml

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls:
  - hosts:
      - tlsapp1.dockersec.me
    secretName: tlscertsapp1
  rules:
  - host: tlsapp1.dockersec.me
    http:
      paths:
      - path: /
        backend:
          serviceName: my-nginx-clusterip
          servicePort: 80

```
```
kubectl apply -n app1 -f tlsapp1_ingress.yaml
kubectl get ingress tls-example-ingress -n app1 
```

Update you hostfile !!!
```
Add to /etc/hosts
127.0.0.1 tlsapp1.dockersec.me
```

```
curl -kv  -H "Host: tlsapp1.dockersec.me" https://tlsapp1.dockersec.me:$SECUREWEB
curl -kv  -H "Host: tlsapp1.dockersec.me" https://localhost:$SECUREWEB
```





