# Cheatsheet - Commonly used kubectl Commands

```bash
kubectl config get-contexts                              # See all available contexts
kubectl config view                                      # See current cluster context
kubectl config set-context $(kubectl config current-context) --namespace=my-namespace
                                                         # Change default namespace

kubectl help run                                         # See help about run (or other commands)
kubectl explain pod.spec                                 # Documenation on any resource attribute

kubectl get nodes                                        # See nodes in cluster
kubectl get pods -o wide                                 # See pods in current namespace
kubectl get pod <name> -o yaml                           # See info about pod <name> in yaml format
kubectl describe pod <name>                              # Show information about pod <name>
kubectl describe service <name>                          # Show information about service <name>

kubectl api-resources                                    # See resources types and abbreviations

kubectl create namespace my-namespace                    # Create namespace
                                                         # Set default namespace
kubectl config set-context $(kubectl config current-context) --namespace=<my-namespace>

kubectl run multitool --image=ghcr.io/eficode-academy/network-multitool --restart Never   # Create plain pod
kubectl create deployment nginx --image=nginx:1.7.9      # Create deployment

kubectl set image deployment/nginx nginx=nginx:1.9.1     # Update image in deployment pod template
kubectl scale deployment nginx --replicas=4              # Scale deployment
kubectl rollout status deployment/nginx                  # See rollout status
kubectl rollout undo deployment/nginx                    # Undo a rollout

kubectl exec -it <name> bash                             # Execute bash inside pod <name>
kubectl exec -it <name> -- my-cmd -with -args            # Execute cmd with arguments inside pod

kubectl delete pod <name>                                # Delete pod with name <name>
kubectl delete deployment <name>                         # Delete deployment with name <name>

kubectl expose deployment envtest --type=NodePort --port=3000  # Create service, expose deployment

kubectl create configmap language --from-literal=LANGUAGE=Elvish  # Create configmap
                                                         # Create secret
kubectl create secret generic apikey --from-literal=API_KEY=oneringtorulethemall
```
