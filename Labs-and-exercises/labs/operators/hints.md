# Lab Hints

Check the application logs and they'll confirm the problem:

```
kubectl logs -l app=todo-list,component=save-handler
```

Shows that the message handler can't connect to the queue:

```
Connecting to message queue url: nats://todo-list-queue:4222
Unhandled exception. NATS.Client.NATSNoServersException: Unable to connect to a server.
```

And: 

```
kubectl logs -l app=todo-list,component=web --tail 100
```

Shows that the website can't connect to the database:

```
---> MySql.Data.MySqlClient.MySqlException (0x80004005): Unable to connect to any of the specified MySQL hosts
```

Check the configuration objects for the app to find the expected domain names for the message queue and database.

> Need more? Here's the [solution](solution.md).