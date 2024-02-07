### Test to see if the StatefulSet "saves" the state of the pods

# Programaticlly get the port and the IP
export CLUSTER_IP=$(kubectl get nodes \
            --selector=node-role.kubernetes.io/master \
            -o jsonpath='{$.items[*].status.addresses[?(@.type=="InternalIP")].address}')

export NODE_PORT=$(kubectl get \
            services postgres \
            -o jsonpath="{.spec.ports[0].nodePort}" \
            -n codewizard)

export POSTGRES_DB=$(kubectl get \
            configmap postgres-config \
            -o jsonpath='{.data.POSTGRES_DB}' \
            -n codewizard)

export POSTGRES_USER=$(kubectl get \
            configmap postgres-config \
            -o jsonpath='{.data.POSTGRES_USER}' \
            -n codewizard)

export PGPASSWORD=$(kubectl get \
            configmap postgres-config \
            -o jsonpath='{.data.POSTGRES_PASSWORD}' \
            -n codewizard)

# Echo check to see if we have all the required variables
printenv | grep POST*

# Connect to postgres and create table if required.
# Once the table exists - add row into the table
psql \
    -U ${POSTGRES_USER} \
    -h ${CLUSTER_IP} \
    -d ${POSTGRES_DB} \
    -p ${NODE_PORT} \
    -c "CREATE TABLE IF NOT EXISTS stateful (str VARCHAR); INSERT INTO stateful values (1); SELECT count(*) FROM stateful"