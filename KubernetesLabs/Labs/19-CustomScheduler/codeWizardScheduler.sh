#!/bin/bash
# Author: Nir Geier

# `set -o pipefail` 
#  When executing the sequence of commands connected to the pipe, 
#  as long as any one command returns a non-zero value, 
#  the entire pipe returns a non-zero value, 
#  even if the last command returns 0.
#  
#  In other words, the chain of command will fail if any of the command fail

set -eo pipefail
# `set -x`
# Shell mode, where all executed commands are printed to the terminal
# Remark if you dont wish to view full log 
set -x

# Start minikube if required
source ../../scripts/startMinikube.sh 

# Deploy our demo pods
kubectl kustomize ./resources | kubectl apply -f -

# Start the API and listen on port 8081
kubectl proxy --port=8081 &

# Syntax: 
# ${parameter:-word}
#   If parameter is unset or null, 
#       the expansion of word is substituted. 
#    Otherwise, 
#       the value of parameter is substituted.

# You can set those paramters out side of this script 
#  export CLUSTER_URL=<url>
CLUSTER_URL="${CLUSTER_URL:-127.0.0.1:8081}"
CUSTOM_SCHEDULER="${CUSTOM_SCHEDULER:-codeWizardScheduler}"

# Scheduler should always run 
while true; do
  # Get a list of all our pods in pending state
  for POD in $(kubectl  get pods \
                        --server ${CLUSTER_URL} \
                        --output jsonpath='{.items..metadata.name}' \
                        --field-selector=status.phase==Pending); 
    do

      # Get the desired schedulerName if the pod has defined any schedulerName
      CUSTOM_SCHEDULER_NAME=$(kubectl get pod ${POD} \
                                      --output jsonpath='{.spec.schedulerName}')
      
      # Check if the desired schedulerName is our custome one
      # If its a match this is where our custom scheduler will "jump in"
      if [ "${CUSTOM_SCHEDULER_NAME}" == "${CUSTOM_SCHEDULER}" ]; 
        then
          # Get the pod namespace
          NAMESPACE=$(kubectl get pod ${POD} \
                              --output jsonpath='{.metadata.namespace}')

          # Get an array for of all the nodes
          NODES=($(kubectl get nodes \
                  --server ${CLUSTER_URL} \
                  --output jsonpath='{.items..metadata.name}'));

          # Store a number for the length of our NODES array
          NODES_LENGTH=${#NODES[@]}

          # Randomly select a node from the array
          # $RANDOM % $NODES_LENGTH will be the remainder
          # of a random number divided by the length of our nodes
          # In the case of 1 node this is always ${NODES[0]}
          NODE=${NODES[$[$RANDOM % $NODES_LENGTH]]}

          # Bind the current pod to the node selected above
          # The "binding" is done using API call to pods/.../binding
          curl \
            --request POST \
            --silent \
            --fail \
            --header "Content-Type:application/json" \
            --data '{"apiVersion":"v1",
                    "kind": "Binding", 
                    "metadata": { 
                      "name": "'${POD}'" 
                      }, 
                    "target": {
                      "apiVersion": "v1", 
                      "kind": "Node", 
                      "name": "'${NODE}'"
                      }
                    }' \
            http://${CLUSTER_URL}/api/v1/namespaces/${NAMESPACE}/pods/${POD}/binding/ >/dev/null \
            && echo "${POD} was assigned to ${NODE}" \
            || echo "Failed to assign ${POD} to ${NODE}"
      fi
    done
  # Current scheduling done, sleep and wake up for the next iteration
  echo "Scheduler ig going to sleep"

  sleep 15s
done