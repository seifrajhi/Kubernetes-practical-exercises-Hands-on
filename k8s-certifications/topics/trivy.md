# [Trivy](https://aquasecurity.github.io/trivy)

A Simple and Comprehensive Vulnerability Scanner for Containers and other Artifacts, Suitable for CI.

<br />

### Trivy Installation
```bash
apt-get  update
apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

#Update Repo and Install trivy
apt-get update
apt-get install trivy -y

# OR (if you encounter issues 'Unable to locate package trivy')

wget https://github.com/aquasecurity/trivy/releases/download/v0.17.0/trivy_0.17.0_Linux-64bit.deb
sudo dpkg -i trivy_0.17.0_Linux-64bit.deb

```

<br />

### Scan the following images with Trivy and check the `CRITICAL` issues.
 - nginx:1.21.4-alpine
 - amazonlinux:2.0.20211201.0
 - nginx:1.21.4

<details><summary>show</summary><p>

```bash
docker pull nginx:1.21.4
trivy image --severity CRITICAL nginx:1.21.4
# nginx:1.21.4 (debian 11.1)
# ==========================
# Total: 7 (CRITICAL: 7)

docker pull nginx:1.21.4-alpine
trivy image --severity CRITICAL nginx:1.21.4-alpine
# nginx:1.21.4-alpine (alpine 3.14.3)
# ===================================
# Total: 0 (CRITICAL: 0)

docker pull amazonlinux:2.0.20211201.0
trivy image --severity CRITICAL amazonlinux:2.0.20211201.0
# amazonlinux:2.0.20211201.0 (amazon 2 (Karoo))
# =============================================
# Total: 0 (CRITICAL: 0)

```

</p></details>

<br />

### Scan the following images with Trivy and check the `HIGH` issues with output in json format and redirected to `/root/nginx.json`
- nginx:1.21.4

<details><summary>show</summary><p>

```bash
docker pull nginx:1.21.4
trivy image --severity HIGH --format json --output /root/nginx.json nginx:1.21.4 
# nginx:1.21.4 (debian 11.1)
# ==========================
# Total: 7 (CRITICAL: 7)

```

</p></details>

