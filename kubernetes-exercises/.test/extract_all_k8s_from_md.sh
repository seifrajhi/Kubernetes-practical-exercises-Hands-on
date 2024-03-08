#!/bin/bash
find . -iname "*.md" -exec sh -c "cat {} | sh kubernetes-exercises/.test/parse_k8s_from_md.sh > {}.yaml" \;
