#!/bin/bash

# Build the resources folder
kubectl kustomize resources/ > logger.yaml && kubectl delete -f logger.yaml
kubectl kustomize resources/ > logger.yaml && kubectl apply -f logger.yaml
