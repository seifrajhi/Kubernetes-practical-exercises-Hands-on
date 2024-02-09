#!/bin/bash

# Alias to install & update minikube to the latest version
function minikube_update() {
    curl -sLo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
}

currentVersion=$(minikube update-check | grep Current | cut -d ' ' -f2)
lastestVersion=$(minikube update-check | grep Latest | cut -d ' ' -f2)
[[ "$currentVersion" != ${lastestVersion} ]] && minikube_update || echo "Already in latest version !"
minikube version