#!/bin/bash

# Loop over the resources folder
for filePath in "_base"/*
do
    # Add the yaml file to the kustomization file
    kustomize edit add resource $filePath
done