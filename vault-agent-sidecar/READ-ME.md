# Injecting Secrets into Kubernetes Pods via Vault Helm Sidecar

This is a working WIP which might help to deploy Vault in DEV and HA mode on Kubernetes.

## For DEV / TEST

```bash
# for dev / test
git clone https://github.com/hashicorp/vault-helm.git
helm3 install vault ./addons/vault-helm --set "server.dev.enabled=true"

# --> Please continue with the main README.md
```

## HA mode, maybe for Production

```bash
# for ha, pods will not get ready, we need consul:

helm3 repo add hashicorp https://helm.releases.hashicorp.com

helm3 install consul hashicorp/consul --set global.name=consul

helm3 install vault ./addons/vault-helm --set "server.ha.enabled=true"

kubectl get pods -l app.kubernetes.io/name=vault -w 

kubectl exec -ti vault-0 -- vault operator init

Unseal Key 1: KinLA5oXaYpM1xZV8DYYmLqrlE9/2xwdGR562Ru/Ori9
Unseal Key 2: 2JSiir7xiGw++HIMf+ISCggCVXhyQ7ot07NcUwfGDVD/
Unseal Key 3: uo8q4KVs0Ywh5AeTJwzKM8javZsufdulgIz4iORFKFE+
Unseal Key 4: RVHqDRppsTzSlbCP7qeKlQiiuptFwIFsiSDEg5fHBYkr
Unseal Key 5: 32uq6mCP6QYHfuvW9gFTB7UTWl5TtMc77e2rJzy+lHPI

Initial Root Token: s.JaZ9CB0q2MEdXOp9axGuO3VX

## Unseal the first vault server until it reaches the key threshold
kubectl exec -ti vault-0 -- vault operator unseal # ... Unseal Key 1
kubectl exec -ti vault-0 -- vault operator unseal # ... Unseal Key 2
kubectl exec -ti vault-0 -- vault operator unseal # ... Unseal Key 3

Repeat the above for vault-1 and vault-2.

kubectl exec -it vault-0 /bin/sh

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
export VAULT_TOKEN=s.JaZ9CB0q2MEdXOp9axGuO3VX
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

vault auth enable kubernetes
vault auth enable userpass
vault write auth/userpass/users/testuser password=kubernauts policies=admins

## access the vault ui
kubectl port-forward vault-0 8200:8200

open http://127.0.0.1:8200

--> provide the Initial Root Token from above vault operator init command
s.Cnwm1aZTw3D83ENkMdoqpHO5

vault secrets enable -path=internal kv-v2
vault kv put internal/database/config username="db-readonly-username" password="db-secret-password"
vault kv get internal/database/config

vault write auth/kubernetes/config \
         token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
         kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
         kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault policy write internal-app - <<EOF
path "internal/data/database/config" {
capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/internal-app \
        bound_service_account_names=internal-app \
        bound_service_account_namespaces=default \
        policies=internal-app \
        ttl=24h

exit

kubectl get serviceaccounts
cat service-account-internal-app.yml
k create -f service-account-internal-app.yml
k create -f deployment-01-orgchart.yml
k get pods

The Vault-Agent injector looks for deployments that define specific annotations. None of these annotations exist within the current deployment. This means that no secrets are present on the orgchart container within the orgchart-69697d9598-l878s pod.

Verify that no secrets are written to the orgchart container in the orgchart-69697d9598-l878s pod.

k exec orgchart-69697d9598-p7wfc -c orgchart -- ls /vault/secrets

....

# --> Please continue with the main README.md
```


# Related Links

https://learn.hashicorp.com/vault/getting-started-k8s/sidecar

https://www.vaultproject.io/docs/platform/k8s/helm/run

https://www.consul.io/docs/platform/k8s/run.html

https://www.hashicorp.com/blog/vault-integrated-storage-ga/

https://www.vaultproject.io/docs/concepts/policies.html

https://www.vaultproject.io/docs/auth/kubernetes.html

https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/04-path-security-and-networking/401-configmaps-and-secrets#secrets-using-vault

