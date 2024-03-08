# Nextcloud docker-compose transformation showcase

# download kompose

```sh
curl -L https://github.com/kubernetes/kompose/releases/download/v1.22.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
```

Convert the file

```sh
kompose convert
```

examine the result.

realize that the connection between

## Additions

- add `type:NodePort` to service
- add new service for app to talk to DB:

```Yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    type: database
  name: db
spec:
  ports:
    - name: "mysqlport"
      port: 3306
      targetPort: 3306
  selector:
    io.kompose.service: db
  type: ClusterIP

```

Go into the website at see that it is running
