#!/bin/sh

kubectl patch clusterrolebinding docker-for-desktop-binding --type=json --patch '[{"op":"replace", "path":"/subjects/0/name", "value":"system:serviceaccounts:kube-system"}]'