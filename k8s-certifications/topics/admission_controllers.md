# [Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)

An admission controller is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

 - [ImagePolicyWebhook](#imagepolicywebhook)
 - [PodSecurityPolicy](#podsecuritypolicy)

<br />

## Basics

<br />

### Check the admission controller enabled by default

<details><summary>show</summary><p>

```bash
kubectl exec -it kube-apiserver-controlplane -n kube-system -- kube-apiserver -h | grep 'enable-admission-plugins'
```

</p></details>

<br />

### Check the admission controller enabled explicitly.

<details><summary>show</summary><p>

#### Check the `--enable-admission-plugins` property in the `/etc/kubernetes/manifests/kube-apiserver.yaml` file

</p></details>

<br />

### Disable `DefaultStorageClass` admission controller

<details><summary>show</summary><p>

#### Add `--disable-admission-plugins=DefaultStorageClass` to the `/etc/kubernetes/manifests/kube-apiserver.yaml` file

</p></details>

<br />

## [ImagePolicyWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook)

<br />

### [Set Up](https://github.com/kainlite/kube-image-bouncer)

```bash
# add image-bouncer-webhook to the host file
echo "127.0.0.1 image-bouncer-webhook" >> /etc/hosts

# make directory to host the keys - using /etc/kubernetes/pki as the volume is already mounted
mkdir -p /etc/kubernetes/pki/kube-image-bouncer
cd /etc/kubernetes/pki/kube-image-bouncer

# generate webhook certificate OR use the one in data folder
openssl req -x509 -new -days 3650 -nodes \
  -keyout webhook.key -out webhook.crt -subj "/CN=system:node:image-bouncer-webhook.default.pod.cluster.local" \
  -addext "subjectAltName=DNS:image-bouncer-webhook,DNS:image-bouncer-webhook.default.svc,DNS:image-bouncer-webhook.default.svc.cluster.local"

# create secret 
kubectl create secret tls tls-image-bouncer-webhook --cert=/etc/kubernetes/pki/kube-image-bouncer/webhook.crt --key=/etc/kubernetes/pki/kube-image-bouncer/webhook.key

# create webhook deployment exposed as node port service
cat << EOF > image-bouncer-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: image-bouncer-webhook
  name: image-bouncer-webhook
spec:
  type: NodePort
  ports:
    - name: https
      port: 443
      targetPort: 1323
      protocol: "TCP"
      nodePort: 30080
  selector:
    app: image-bouncer-webhook
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: image-bouncer-webhook
spec:
  selector:
    matchLabels:
      app: image-bouncer-webhook
  template:
    metadata:
      labels:
        app: image-bouncer-webhook
    spec:
      containers:
        - name: image-bouncer-webhook
          imagePullPolicy: Always
          image: "kainlite/kube-image-bouncer:latest"
          args:
            - "--cert=/etc/admission-controller/tls/tls.crt"
            - "--key=/etc/admission-controller/tls/tls.key"
            - "--debug"
            - "--registry-whitelist=docker.io,k8s.gcr.io"
          volumeMounts:
            - name: tls
              mountPath: /etc/admission-controller/tls
      volumes:
        - name: tls
          secret:
            secretName: tls-image-bouncer-webhook
EOF

kubectl apply -f image-bouncer-webhook.yaml

# define the admission configuration file @ /etc/kubernetes/pki/kube-image-bouncer/admission_configuration.yaml
cat << EOF > admission_configuration.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/pki/kube-image-bouncer/kube-image-bouncer.yml
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: false
EOF

OR 

# Define the admission configuration file in json format @ /etc/kubernetes/admission_configuration.json
cat << EOF > admission_configuration.json
{
  "imagePolicy": {
     "kubeConfigFile": "/etc/kubernetes/pki/kube-image-bouncer/kube-image-bouncer.yml",
     "allowTTL": 50,
     "denyTTL": 50,
     "retryBackoff": 500,
     "defaultAllow": false
  }
}
EOF

# Define the kube config file @ /etc/kubernetes/pki/kube-image-bouncer/kube-image-bouncer.yml

cat << EOF > kube-image-bouncer.yml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/kube-image-bouncer/webhook.crt
    server: https://image-bouncer-webhook:30080/image_policy
  name: bouncer_webhook
contexts:
- context:
    cluster: bouncer_webhook
    user: api-server
  name: bouncer_validator
current-context: bouncer_validator
preferences: {}
users:
- name: api-server
  user:
    client-certificate: /etc/kubernetes/pki/apiserver.crt
    client-key:  /etc/kubernetes/pki/apiserver.key
EOF

```

#### Check if can create pods with nginx:latest image

```bash
kubectl create deploy nginx --image nginx
# deployment.apps/nginx created
kk get pods -w
# NAME                    READY   STATUS    RESTARTS   AGE
# nginx-f89759699-5qbv5   1/1     Running   0          13s
kubectl delete deploy nginx 
# deployment.apps "nginx" deleted
```

#### Enable the addmission controller. 

Edit the `/etc/kubernetes/manifests/kube-apiserver.yaml` file as below.

```yaml
   - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook # update
   - --admission-control-config-file=/etc/kubernetes/pki/kube-image-bouncer/admission_configuration.yaml # add
```

#### Verify 

Wait for the kube-apiserver to restart and trying creating deployment with nginx:latest image

```bash
kubectl get deploy nginx 
# NAME    READY   UP-TO-DATE   AVAILABLE   AGE
# nginx   0/1     0            0           12s

kubectl get events
# 7s          Warning   FailedCreate              replicaset/nginx-f89759699                    (combined from similar events): Error creating: pods "nginx-f89759699-b2r4k" is forbidden: image policy webhook backend denied one or more images: Images using latest tag are not allowed 
```

<br />

## PodSecurityPolicy

Refer [Pod Security Policy Admission Controller](./pod_security_policies.md)