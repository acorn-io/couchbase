## Couchbase Database

Couchbase is a high-performance, distributed NoSQL database designed for large-scale, interactive applications, offering features like flexible data modeling (JSON), full-text search, real-time analytics, and SQL-like querying capabilities (N1QL). It is known for its easy scalability, consistent high performance, and efficient replication and synchronization for mobile and edge computing.

## Couchbase as an Acorn Service

This Acorn provides a couchbase database as an Acorn Service. It can be used to easily get a Couchbase database for your application during development. The current service runs a single Couchbase container backed by a persistent volume and define credentials for an admin user.

The Acorn image of this service is hosted in GitHub container registry at [ghcr.io/lucj/acorn-couchbase](ghcr.io/lucj/acorn-couchbase). 

Currently this Acorn has the following configuration options:
- *version*: version of the database (*7.2.3* by default)
- *dbUser*: name of the admin user (empty by default)
- *clusterName*
- *bucketName*

