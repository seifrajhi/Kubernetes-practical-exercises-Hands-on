# [Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

<br />

## [Certificates API](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/)

<br />

### Create a user certificate signing request using certs and specs as below and submit it for approval.

#### Create user certs

```bash
openssl genrsa -out normal.key 2048
openssl req -new -key normal.key -out normal.csr
```

#### Use below CertificateSigningRequest specs

```yaml
cat << EOF > normal-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: normal-csr
spec:
  request: ??
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
```

<br />

<details><summary>show</summary><p>

```yaml
cat << EOF > normal-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: normal-csr
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2lqQ0NBWElDQVFBd1JURUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpEQ0NBU0l3RFFZSktvWklodmNOCkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFNellTKzhhTXdBVmkwWHovaVp2Z2k0eGtNWTkyMWZRSmd1bGM2eDYKS0Q4UjNteEMyRkxlWklJSHRYTDZadG5KSHYxY0g0eWtMUEZtR2hDRURVNnRxQ2FpczNaWWV3MVBzVG5nd1Jzego3TG1oeDV4dzVRc3lRaFBkNjRuY3h1MFRJZmFGbmducU9UT0NGWERyaXBtZzJ5TExvbTIxL1ZxbjNQMVJQeE51CjZJdDlBOHB6aURlTVg5VTlaTHhzT0Jld2FzaFJzM29jb3NIcHp5cXN1SnQralVvUjNmaGducVB3UkNBZmQ3YUUKaUhKOWFxblhHVVNUWENXb2g2OEtPL3VkU3p2djNmcExhV1JxUUdHWi9HSWpjM1ZiZzNHN0FqNWNITUp2WHV3bwp3M0JkV1pZaEpycU9Ld21sMW9QVHJRNlhMQ2FBTFZ2NnFqZWVOSFNvOVZyVmM0OENBd0VBQWFBQU1BMEdDU3FHClNJYjNEUUVCQ3dVQUE0SUJBUUFEZGNmMHZVSnVtcmRwcGxOa0pwSERSVFI2ZlFzYk84OFM3cnlndC9vcFEvOCsKNVkyUVVjVzhSUUdpVGdvQjFGUG1FeERVcFRna2p1SEtDQ0l3RWdjc3pPRm5YdC95N1FsWXBuc0E3dG01V1ppUAozbG1xSFpQMU9tQlRBRU45L2swSFpKdjc4Rytmcm0xNnRJbWtzUHpSK2lBajZ2WDZtT1RNVEk3Y1U5cmIvSElLCmVOTTZjV2dYQzYrbU9PbDFqM3BjS1hlVlB0YS9MbDZEVFc0VWdnR0J1NVJPb3FWRS9sTDNQNnc4K2R3M0lWQngKWlBrK0JDNVQrMkZLMFNzd3VvSCtaKzhtbi8weHR2bk1nL3FPTWIwdXVvcDNSTklVZmFhR1pRSjRmSnVrMGdkQwpXZHFselJMREsydXZYcWVFUXFjMENxZmVVdXRGdzVuOWNWZVdvRFVwCi0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo= # use base64 encoded value of normal.csr file
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl apply -f normal-csr.yaml
```

#### Verify its submitted and in Pending status

```bash
kubectl get csr normal-csr
# NAME         AGE   SIGNERNAME                            REQUESTOR          CONDITION
# normal-csr   37s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Pending
```

</p></details>

<br />

### Approve the `normal-csr` request 

<br />

<details><summary>show</summary><p>

```bash
kubectl certificate approve normal-csr
# certificatesigningrequest.certificates.k8s.io/normal-csr approved
```

#### Verify its in Approved,Issued status

```bash
kubectl get csr normal-csr
# NAME         AGE     SIGNERNAME                            REQUESTOR          CONDITION
# normal-csr   4m15s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Approved,Issued
```

</p></details>

<br />

### Create the below csr request and reject the same.

<br />

```yaml
cat << EOF > hacker-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: hacker-csr
spec:
  groups:
  - system:masters
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2lqQ0NBWElDQVFBd1JURUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpEQ0NBU0l3RFFZSktvWklodmNOCkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFNellTKzhhTXdBVmkwWHovaVp2Z2k0eGtNWTkyMWZRSmd1bGM2eDYKS0Q4UjNteEMyRkxlWklJSHRYTDZadG5KSHYxY0g0eWtMUEZtR2hDRURVNnRxQ2FpczNaWWV3MVBzVG5nd1Jzego3TG1oeDV4dzVRc3lRaFBkNjRuY3h1MFRJZmFGbmducU9UT0NGWERyaXBtZzJ5TExvbTIxL1ZxbjNQMVJQeE51CjZJdDlBOHB6aURlTVg5VTlaTHhzT0Jld2FzaFJzM29jb3NIcHp5cXN1SnQralVvUjNmaGducVB3UkNBZmQ3YUUKaUhKOWFxblhHVVNUWENXb2g2OEtPL3VkU3p2djNmcExhV1JxUUdHWi9HSWpjM1ZiZzNHN0FqNWNITUp2WHV3bwp3M0JkV1pZaEpycU9Ld21sMW9QVHJRNlhMQ2FBTFZ2NnFqZWVOSFNvOVZyVmM0OENBd0VBQWFBQU1BMEdDU3FHClNJYjNEUUVCQ3dVQUE0SUJBUUFEZGNmMHZVSnVtcmRwcGxOa0pwSERSVFI2ZlFzYk84OFM3cnlndC9vcFEvOCsKNVkyUVVjVzhSUUdpVGdvQjFGUG1FeERVcFRna2p1SEtDQ0l3RWdjc3pPRm5YdC95N1FsWXBuc0E3dG01V1ppUAozbG1xSFpQMU9tQlRBRU45L2swSFpKdjc4Rytmcm0xNnRJbWtzUHpSK2lBajZ2WDZtT1RNVEk3Y1U5cmIvSElLCmVOTTZjV2dYQzYrbU9PbDFqM3BjS1hlVlB0YS9MbDZEVFc0VWdnR0J1NVJPb3FWRS9sTDNQNnc4K2R3M0lWQngKWlBrK0JDNVQrMkZLMFNzd3VvSCtaKzhtbi8weHR2bk1nL3FPTWIwdXVvcDNSTklVZmFhR1pRSjRmSnVrMGdkQwpXZHFselJMREsydXZYcWVFUXFjMENxZmVVdXRGdzVuOWNWZVdvRFVwCi0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

kubectl apply -f hacker-csr.yaml
```

<details><summary>show</summary><p>

```bash
ubectl certificate deny hacker-csr
# certificatesigningrequest.certificates.k8s.io/hacker-csr denied

```

#### Verify its in Approved,Issued status

```bash
kubectl get csr hacker-csr
# NAME         AGE   SIGNERNAME                            REQUESTOR          CONDITION
# hacker-csr   16s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Denied
```

</p></details>

<br />