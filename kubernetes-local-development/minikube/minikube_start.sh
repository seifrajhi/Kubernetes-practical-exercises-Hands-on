#!/bin/bash

# Env vars

# MINIKUBE_HOME - (string) sets the path for the .minikube directory that minikube uses for state/configuration
# MINIKUBE_IN_STYLE - (bool) manually sets whether or not emoji and colors should appear in minikube. Set to false or 0 to disable this feature, true or 1 to force it to be turned on.
# MINIKUBE_WANTUPDATENOTIFICATION - (bool) sets whether the user wants an update notification for new minikube versions
# MINIKUBE_REMINDERWAITPERIODINHOURS - (int) sets the number of hours to check for an update notification
# CHANGE_MINIKUBE_NONE_USER - (bool) automatically change ownership of ~/.minikube to the value of $SUDO_USER
# MINIKUBE_ENABLE_PROFILING - (int, 1 enables it) enables trace profiling to be generated for minikube

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
export MINIKUBE_IN_STYLE=true

mkdir -p $HOME/.kube
mkdir -p $HOME/.minikube
touch $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# Launch
# https://istio.io/docs/setup/kubernetes/prepare/platform-setup/minikube/
# https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md#known-issues
sudo -E minikube start --vm-driver=none \
--memory=8192 --cpus=4 \
--extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook" \
--extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf

# Addons
sudo minikube addons enable heapster
sudo minikube addons enable metrics-server

# Show Dashboard URL
echo "------------------------------------"
echo "Showing dashboard URL..."
sudo minikube dashboard --url &
echo "------------------------------------"

# Wait for the cluster to be ready
# watch kubectl get pods --namespace kube-system
