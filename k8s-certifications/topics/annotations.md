# [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

<br />

### Create pod `nginx-annotations` and Annotate it with `description='my description'` value

<br />

<details><summary>show</summary><p>

```bash
kubectl run nginx-annotations --image nginx
kubectl annotate pod nginx-annotations description='my description'
```

</p></details> 

<br />

<!-- 
### Check the annotations for pod nginx-annotations

<details><summary>show</summary><p>

```bash
kubectl annotate pod nginx-annotations --list
```
  
</p></details> 

<br />
-->