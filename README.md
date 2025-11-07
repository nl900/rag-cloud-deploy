# RAG App

## Architectural decisions

### Container
Chose Python 3.12-slim image because this is a Python-specific base image ensuring all standard Python libraries and 
tools are provided out of the box. <br>
While smaller Python-specific images like python:3.12-alpine could work for the sample app, a full RAG application would 
require additional ML dependencies that may not be compatible with it. <br>
Multi-stage docker build is employed to create a final minimal image for production.

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
