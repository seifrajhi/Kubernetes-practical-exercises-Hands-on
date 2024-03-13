# Kubernetes cluster

# Writing and CI

Automated tests can extract Kubernetes YAML from markdown files and automatically lint them. For this to work, annotate your multi-line code blocks with both `yaml` and `k8s`. Your multi-line code block will have as its first line ````yaml,k8s`.
