# RAG App


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
