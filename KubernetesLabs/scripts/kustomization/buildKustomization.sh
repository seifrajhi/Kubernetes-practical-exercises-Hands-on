#!/bin/bash

# Set Verbose mode
set -x 

# Check to see if we have the latest version of kustomize
if [ ! -f ./kustomize ]; then
  # Install latest verison of Kustomize
  curl -sv "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
fi

# Save the kustomization path
KUSTOMIZATION_PATH=$(pwd)/kustomize

# Read the desired variable from the CLI
RESOURCES_PATH=$1

# Set the base path in caase we did not supply one
: ${RESOURCES_PATH:="/K8S/*"}

# Set the desired output file
KUSTOMIZATION_TARGET_FILE=$2

# Set the base path in caase we did not supply one
: ${KUSTOMIZATION_TARGET_FILE:="kustomization.yaml"}

# Verify that the file exist or create a new one
touch $RESOURCES_PATH/$KUSTOMIZATION_TARGET_FILE

# Switch to the desired kustomization folder
cd $RESOURCES_PATH

# Loop over the resources folder
for filePath in *
do
    # Add the yaml file to the kustomization file
    $KUSTOMIZATION_PATH edit add resource $filePath 
done

# Add the desired namespace
$KUSTOMIZATION_PATH edit set namespace codewizard

# Format the output file
$KUSTOMIZATION_PATH cfg fmt $KUSTOMIZATION_TARGET_FILE 

# print the full structure
./kustomize.exe cfg tree --all

# Set the desired namespace 
cat $KUSTOMIZATION_TARGET_FILE 

# disable verbose mode
set +x