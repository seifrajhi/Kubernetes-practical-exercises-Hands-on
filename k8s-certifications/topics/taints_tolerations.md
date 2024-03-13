# [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

<br />

### Create a taint on worker node `node01` with key `app` with value `critical` and effect of `NoSchedule`

<br />

<details><summary>show</summary><p>

```bash
kk taint node node01 app=critical:NoSchedule
```

</p></details> 

<br />

