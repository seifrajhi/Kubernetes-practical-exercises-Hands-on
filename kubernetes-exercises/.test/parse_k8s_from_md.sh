#!/bin/bash
sed -n '/^```[^\n]*k8s/,/^```/p' | sed '/^```[^\n]*k8s/d' | sed -e 's/```/---/g'
