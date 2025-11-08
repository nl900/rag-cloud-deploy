## Architectural decisions

### Container
Python 3.12-slim image was chosen because it is smaller but still work out of the box for most Python packages due to the image
based on Debian and using glibc. As the app import neo4j and openai libraries which require C and Rust extensions, they 
are better compatible in glibc environment. Whereas an Alpine variant uses musl libc, though smaller less compatible 
which may cause installation errors or runtime crashes with external dependencies. Further, it is assumed that the app will
make calls to neo4j and openai  which means it's I/O bound and glibc is more optimised than musl which Alpine uses. Further, 
since this is run using Kubernetes which is built on Debian/Ubuntu which are glibc based Linux distributions, the Python:slim 
which is also Debian-based ensures it's most compatible. <br>
Multi-stage build separate build and run. The necessary tools used to compile and install Python dependencies are downloaded
then discarded. The final runtime image contain only the app, Python and the bare minimal libraries necessary to run the app,
keeping the final build image as small as possible, reducing attack surface and more secure. Similarly, cleaning up the
package manager caches reduce the possbility of leftover sensitive files included in the image. <br>
Creating a non-root user and assigning a fixed UID ensures compatibility with Kubernetes security policies that may require 
numeric UIDs. Switching to this non-root user to run all subsequent commands including container entrypoint  ensures
the app runs without root privileges in case the container is compromised.
Only exposing port the app requires (8000 for FastAPI) further reduce exposure to unnecessary access.

### Secrets and Config Management
The application reads neo4j and openai connection configuration from environment variables. <br>
To avoid hardcoding the sensitive information <br>
    &nbsp;&nbsp;&nbsp; Local: use .env file and the file is passed through when running the docker <br>
    &nbsp;&nbsp;&nbsp; Local with local Kubernetes cluster: uses the secret.yaml file to define the credentials <br>
    &nbsp;&nbsp;&nbsp; Staging and production: the secrets are managed using managed secret provider eg aws secret store and injected into Kubernetes
        via the envFrom <br>
URI and port are not considered as sensitive and is passed in Kubernetes ConfigMap

### Deployment strategy


### Logging and observability
Using Python's built-in logging module, we log all query function calls and all errors using exception to show stack trace.
Write logs to standard output and error streams of the container since this is deployed on Kubernetes, it can capture the 
logs automatically. This is simple and no local files are needed inside the container.
The app already exposes Prometheus style metrics via the /metrics endpoint, so naturally makes sense to use Prometheus 
to scrape this endpoint and make it available for dashboards eg Grafana and use to setup appropriate alerts.

## Assumptions
- The /query endpoint represents what a real RAG system would expose
- The app will query a neo4j 


## Improvements
- structured JSON logging to integrate with a centralized log collector.
- Error handling and retry logic for external service integrations (openai and neo4j)

## Running the RAG App with Docker
Make sure you are in the project directory containing the `Dockerfile`:

```bash
docker build -t rag-app:latest .
docker run --env-file .env -p 8000:8000 rag-app:latest 
```

Test endpoint
```bash
curl http://localhost:8000/health
```

The app can also be run in a local Kubernetes cluster using kind

Create kind cluster
```bash
kind create cluster --name <cluster-name>
```

Load the image to the kind cluster
```bash
kind load docker-image rag-app:latest --name <cluster-name>
```

Apply Kubernetes manifests
```bash
kubectl apply -k k8s/envs/dev/
```

Ensure the pods are running and check logs

```bash
kubectl logs <pod-name>
```
