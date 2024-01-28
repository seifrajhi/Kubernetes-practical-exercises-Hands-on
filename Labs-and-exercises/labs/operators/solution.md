# Lab Solution

My solution uses two custom resources:

- [todo-list-queue.yaml](./solution/todo-list-queue.yaml) - a NatsCluster object with the name `todo-list-queue` which will become the Service name

- [todo-list-db.yaml](./solution/todo-list-db.yaml) - password Secret and MysqlCluster with the expected name `todo-db`

Create the resources:

```
kubectl apply -f labs/operators/solution
```

Check the message queue gets created:

```
kubectl get po,svc -l app=nats
```

You may need to restart the message handler if it's in a backoff state:

```
kubectl rollout restart deploy todo-save-handler

kubectl logs -l app=todo-list,component=save-handler
```

Check the database gets created:

```
kubectl get po,svc -l app.kubernetes.io/instance=todo-db
```

> Try the app at http://localhost:30028

- Add a new item
- Refresh list
