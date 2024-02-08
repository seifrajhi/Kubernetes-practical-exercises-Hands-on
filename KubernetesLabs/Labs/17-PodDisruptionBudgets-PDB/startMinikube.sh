#!/bin/bash

# For more details about Feature Gates read: 
# https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/#feature-stages
#
# For more details about eviction-signals
# https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/#eviction-signals

minikube start \
    --extra-config=kubelet.eviction-hard="memory.available<480M" \
    --extra-config=kubelet.eviction-pressure-transition-period="30s" \
    --extra-config=kubelet.feature-gates="ExperimentalCriticalPodAnnotation=true"

kubectl describe node minikube | grep MemoryPressure