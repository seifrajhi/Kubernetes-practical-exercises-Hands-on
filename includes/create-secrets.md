```
echo -n "yourvalue" > ./secret.txt
```

```
k create secret generic secretname --from-file=./secret.txt
```

```
k describe secrets secretname
```

```
k get secret secretname -o yaml
```

```
echo 'eW91cnZhbHVl' | base64 --decode
```

# or

```
k create secret generic mysecret --dry-run -o yaml --from-file=./secret.txt > secret.yaml
```

```
k create -f secret.yaml
```

# or

```
k create secret generic mysecret --dry-run -o yaml --from-literal=secret.txt=yourvalue > secret.yaml
```

