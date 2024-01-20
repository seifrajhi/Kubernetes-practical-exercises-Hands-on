```
k create cm kubernauts --from-literal=dev=ops --dry-run -o yaml > cm-kubernauts.yaml
```

```
cat cm-kubernauts.yaml
```

```
echo -n "ops" > dev
```

```
k create cm kubernauts --from-file=./dev
```

```
k get cm
```

```
k describe cm kubernauts
```

```
k delete cm kubernauts
```

```
k create -f cm-kubernauts.yaml
```

```
k describe cm kubernauts
```


