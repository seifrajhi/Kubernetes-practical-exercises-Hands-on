#!/bin/bash

# start minikube tunnel so we can simulate LoadBalancer
# Execute tunnel in subshell and move to background
(minikube tunnel &)

# This script will simulate traffic to our cluster so we will be able to see some action in kiali
# Execute tunnel in subshell and move to background so it can run with minikube tunnel 
(while (true)
do
    SLEEP_TIME=$(( $RANDOM % 10 ))
    echo Ping server
    curl -si $(kubectl get service/proxy-service -o jsonpath="{.spec.clusterIP}") | head -1
    echo Going to sleep for $SLEEP_TIME seconds
    sleep $SLEEP_TIME
done &)

#####################################
# To stop the script execute:      ##
# pkill -f ./simulateTraffic.sh    ##
#####################################