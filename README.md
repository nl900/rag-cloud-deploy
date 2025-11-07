# RAG App

## Architectural decisions

### Container
Chose Python 3.12-slim image because this is a Python-specific base image ensuring all standard Python libraries and 
tools are provided out of the box.
While smaller Python-specific images like python:3.12-alpine could work for the sample app, a full RAG application would 
require additional ML dependencies that may not be compatible with it.
Multi-stage docker build is employed to create a final mininal image for production.

### Secrets and Config Management
Neo4j connection credentials and other sensitive config in Secrets and is injected via envFrom. This increases complexity
but improves security and avoid hard-coding credentials.

### Resource management
Defining CPU and memory requests and limits in deployment manifests adds more complexity but ensure but can scale safely
to ensure high availability.

### Logging and observability


## Assumptions
- No sensitive data 
- Secrets for sensitive information eg Neo4j password
- The /query endpoint represents what a real RAG system would expose


## Running the RAG App with Docker
Make sure you are in the project directory containing the `Dockerfile`:

```bash
docker build -t rag-app:latest .
docker run -d --name rag-app -p 8000:8000 rag-app:latest
```

Test endpoint
```bash
curl http://localhost:8000/health
```

The app can also be run in a local Kubernetes cluster using kind

Create kind cluster
```bash
kind create cluster --name rag-dev
```

Load the image to the kind cluster
```bash
kind load docker-image rag-app:latest --name rag-dev
```

Apply Kubernetes manifests
```bash
kubectl apply -k k8s/envs/dev/
```

Ensure the pods are running and check logs

```bash
kubectl logs <pod-name>
```