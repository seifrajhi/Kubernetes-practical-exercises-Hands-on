# Before we work with K8s PV, some things to be noted
## let's see what they are

### Container: 

- The container is just a running process
- Container is ephemeral
- when creating a container, Linux will assign a temporary file system, 
- which is related to Linux namespaces, capabilities

### State:

- The state is normally just some form of data that our application needs to function
- a container or pod or an application is just a running process, there are two types of process

### Stateless:

- A stateless process is a process that does depend on state or data to function 
- It does not store any state or data in memory(main) or the filesystem(secondary)

### Stateful:

- The stateful process depends on the state to function, which will store in only two places
- One is in memory and the other is on disk memory allows access to your data

### So what makes containers different to other processes:

- A container usually has its own file system when docker creates a container
- it creates a virtual file system and attaches it to that container unlike processes 
- on a host that have access to the whole file system 
- containers have their own file system so when a container gets destroyed and recreated 
- it loses the file system,  and the file system gets recreated against of files on lost 
- therefore the container file system is not persisted during restarts

# Let's see real world example, of how this thing works

## Let's play with docker volumes:

### below commands

```yaml
-d    -> Detach mode (no auto-logged into the running container)
--rm  -> when we logged out of from the running container it will automatically stop the container too 
-e    -> env (imperative way)
exec  -> execute a file
it    -> interactive env, we can able to perform operations inside the running container
bash  -> shell environment

```
# Practise example by using Postgresdb
```s

~ docker run -d --rm -e POSTGRES_DB=postgresdb -e POSTGRES_USER=mohan -e POSTGRES_PASSWORD=mohan123 postgres:15.0
df34bea9bbcae7297fe59f2de4a30f4459905d4dcd5218e7161253d83761af5b


~ docker exec -it df34bea9bbcae7297fe59f2de4a30f4459905d4dcd5218e7161253d83761af5b bash
root@df34bea9bbca:/# psql --username=mohan postgresdb
psql (15.0 (Debian 15.0-1.pgdg110+1))
Type "help" for help.

postgresdb=# 

CREATE TABLE COMPANY(                  #adding 1st table
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);

CREATE TABLE

postgresdb=# \d                               
        List of relations
 Schema |  Name   | Type  | Owner 
--------+---------+-------+-------
 public | company | table | mohan     #showing only 1 row
(1 row)

postgresdb=# 

CREATE TABLE DEP_MEM(               #Creating 2nd one
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);

CREATE TABLE

postgresdb=# \d                  
        List of relations
 Schema |  Name   | Type  | Owner 
--------+---------+-------+-------
 public | company | table | mohan       # showing both but when we restart this without attaching volumes
 public | dep_mem | table | mohan       # something bad happen which is the data will be lost
(2 rows)

postgresdb=# \q 

```

Restarting the above container and going back in you will notice \d commands does not return tables. Since data is lost.

## Same can be demonstrated using Kubernetes

![namespace](https://user-images.githubusercontent.com/58173938/196079761-4e86e8e2-9591-4962-aff9-94d62d2c6d3d.png)

### run the same above mentioned commands to create and list the database table
```
~ kubectl delete pod postgres-0
```

exec back in and confirm table does not exist.


volumes are not bound by namespaces meaning your administrators or your platform engineers that creates this 
persistent volume can create it for the cluster wide so it's not allocated for a specific namespace that means 
pods that are running and any namespace can use a persistence volume 

Note: Whereas PVC are bound to namespaces


```yaml

~ kubens pg
✔ Active namespace is "pg"

~ kubectl apply -f PersistentV.yml

~ kubectl apply -f PVC.yaml

~ kubectl apply -f postgres-with-pv-conf.yml

~ kubectl get pods

```


Workflow: 

-> Provisiong storage type on cloud (AWS, AZURE, GCP) Administrator <br>
-> Kubernetes Administrator provision (persistent volume with storageclas(This is simply a plugin nothing more checkout (CSI)) <br>
-> The storageclass will be declared in Persistent volume (cluster bound) <br>
-> Set up PVC on the cluster for to be used by the pods (namespace bound) <br>
-> create an db and attach the db(pod) to the pvc <br>

This is what actually going on, I hope you learnt something.
