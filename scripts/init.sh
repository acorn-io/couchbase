#!/bin/sh
# set -euxo pipefail

# Couple of variables to make local testing simpler
termination_log="/dev/termination-log"
acorn_output="/run/secrets/output"

# Cluster settings
CB_RAMSIZE=256
CB_SERVICES="data"

# Bucket settings
CB_BUCKET_RAMSIZE=100
CB_BUCKET_TYPE="couchbase"
CB_BUCKET_REPLICA=1

# Target couchbase container
CB_HOST="couchbase"
CB_PORT=8091

# Wait for Couchbase Web Console to be available
until $(curl --output /dev/null --silent --head --fail http://$CB_HOST:$CB_PORT); do
    echo "Waiting for Couchbase Server to be available..."
    sleep 5
done

# Additional delay for server initialization
echo "Couchbase Server is up, waiting for initialization..."
sleep 20

# Initialize the node and cluster
res=$(couchbase-cli cluster-init \
    --cluster $CB_HOST:$CB_PORT \
    --cluster-username $CB_ADMIN_USER \
    --cluster-password $CB_ADMIN_PASS \
    --cluster-name $CB_CLUSTER_NAME \
    --cluster-ramsize $CB_RAMSIZE \
    --services $CB_SERVICES 2>&1)

if [ $? -ne 0 ]; then
    echo "cluster init failed"
    echo $res | tee ${termination_log}
    exit 1
fi

echo "Couchbase Server has been initialized and configured!"

# Create a bucket
res=$(couchbase-cli bucket-create \
    --cluster $CB_HOST:$CB_PORT \
    --username $CB_ADMIN_USER \
    --password $CB_ADMIN_PASS \
    --bucket $CB_BUCKET_NAME \
    --bucket-type $CB_BUCKET_TYPE \
    --bucket-ramsize $CB_BUCKET_RAMSIZE \
    --bucket-replica $CB_BUCKET_REPLICA)

if [ $? -ne 0 ]; then
    echo "bucket creation failed"
    echo $res | tee ${termination_log}
    exit 1
fi

echo "Bucket $CB_BUCKET_NAME has been created."

# Define service
cat > /run/secrets/output<<EOF
services: db: {
    container: "couchbase"
    default: true
    secrets: ["admin"]
    ports: [
		"8091",
	]
    data: {
        bucketName: "${CB_BUCKET_NAME}"
    }
}
EOF