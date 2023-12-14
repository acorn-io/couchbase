## Couchbase Database

Couchbase is a high-performance, distributed NoSQL database designed for large-scale, interactive applications, offering features like flexible data modeling (JSON), full-text search, real-time analytics, and SQL-like querying capabilities (N1QL). It is known for its easy scalability, consistent high performance, and efficient replication and synchronization for mobile and edge computing.

## Couchbase as an Acorn Service

This Acorn provides a Couchbase database as an Acorn Service. It can be used to easily get a Couchbase database for your application during development. The current service runs a single Couchbase container backed by a persistent volume and define credentials for an admin user.

The Acorn image of this service is hosted in GitHub container registry at [ghcr.io/acorn-io/couchbase](ghcr.io/acorn-io/couchbase). 

Currently this Acorn has the following configuration options:
- *version*: version of the database (*7.2.3* by default)
- *dbUser*: name of the admin user (empty by default)
- *clusterName*: name of the Couchbase cluster to create
- *bucketName*: name of the bucket to create inside the cluster

These values can be changed using the *serviceArgs* property, for instance:

```
services: db: {
  image: "ghcr.io/acorn-io/couchbase:v#.#.#-#"
  serviceArgs: {
    clusterName: "mytestcluster"
    bucketName: "mytestbucket"
  }
}
```

## Usage

The [examples folder](https://github.com/acorn-io/couchbase/tree/main/examples) contains a sample application using this Service. This app consists in a Python backend based on the FastAPI library, it displays a web page indicating the number of times the application was called, a counter is saved in the underlying Couchbase database and incremented with each request. The screenshot below shows the UI of the example application. 

![UI](./examples/images/ui.png)

To use the Couchbase Service, we first define a *service* property in the Acornfile of the application:

```
services: db: {
	image: "ghcr.io/lucj/acorn-couchbase:v#.#.#-#"
}
```

Next we define the application container. This one can connect to the Couchbase service via environment variables which values are set based on the service's properties.

```
containers: {
	app: {
		build: {
			context: "."
			target:  "dev"
		}
		consumes: ["db"]
		ports: publish: "8000/http"
		env: {
			CB_HOST:     "@{service.db.address}"
			CB_BUCKET:   "@{service.db.data.bucketName}"
			CB_USERNAME: "@{service.db.secrets.admin.username}"
			CB_PASSWORD: "@{service.db.secrets.admin.password}"
		}
	}
}
```

This container is built using the Dockerfile in the examples folder. Once built, the container consumes the Couchbase service using the address and credentials provided through via the dedicated variables.

This example can be run with the following command (to be run from the *examples* folder)

```
acorn run -n app
```

After a few tens of seconds an http endpoint will be returned. Using this endpoint we can access the application and see the counter incremented on each reload of the page.

## About Acorn Sandbox

Instead of managing your own Acorn installation, you can deploy this application in the Acorn Sandbox, the free SaaS offering provided by Acorn. Access to the sandbox requires only a GitHub account, which is used for authentication.

[![Run in Acorn](https://acorn.io/v1-ui/run/badge?image=ghcr.io+acorn-io+couchbase+examples:v%23.%23.%23-%23)](https://acorn.io/run/ghcr.io/acorn-io/couchbase/examples:v%23.%23.%23-%23)

An application running in the Sandbox will automatically shut down after 2 hours, but you can use the Acorn Pro plan to remove the time limit and gain additional functionalities.

