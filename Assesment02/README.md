Assessment Kubernetes Manifests

Overview
--------
This package contains a set of Kubernetes manifests that implement a simple, production-minded layout:
- A dedicated namespace.
- TLS-enabled ingress for external traffic termination .
- ClusterIP service exposing the application within the cluster.
- Deployment with liveness/readiness probes, resource requests/limits, and non-root security context.
- PersistentVolume and PersistentVolumeClaim intended for an NFS-backed file system (example: EFS).
- ConfigMap for application configuration.
- Horizontal Pod Autoscaler.

Files
-----
Apply manifests in the following order to ensure proper creation of storage and namespace:

1. 00-namespace.yaml
2. 01-secret-tls.yaml   (replace base64 placeholders with real TLS cert and key)
3. 02-configmap.yaml
4. 03-storageclass-efs.yaml (update with your AWS EFS FileSystemId)
5. 04-pvc.yaml
6. 05-deployment.yaml
7. 06-service.yaml
8. 07-ingress.yaml
9. 08-hpa.yaml

Notes and best practices
------------------------
- Replace placeholder values (TLS, NFS server) with valid production values before applying.
- Use a real certificate managed by your platform (cert-manager, cloud provider) in production.
- For cloud-managed EFS, consider using a dynamic provisioner and a matching StorageClass instead of a static PV.
- Keep secrets in an external secret manager if you require stronger lifecycle controls.
- Tune resource requests and limits based on real load testing.
- Use network policies to restrict traffic where applicable.
- Consider enabling PodDisruptionBudgets and read-only root filesystem for extra safety.

Applying
--------
Run:
kubectl apply -f <file> ...

Example:
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-secret-tls.yaml
kubectl apply -f 02-configmap.yaml
kubectl apply -f 03-pv-efs.yaml
kubectl apply -f 04-pvc.yaml
kubectl apply -f 05-deployment.yaml
kubectl apply -f 06-service.yaml
kubectl apply -f 07-ingress.yaml
kubectl apply -f 08-hpa.yaml

