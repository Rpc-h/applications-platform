# Notification Service

### Create Sealed Secret
````
export MATRIX_API_TOKEN=<Bitwarden "Riot - bot - Element - Matrix">
kubectl create secret generic notification-service --namespace monitoring --dry-run=client --from-literal=MATRIX_API_TOKEN=${MATRIX_API_TOKEN} -o yaml | kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --format yaml > day-2/monitoring/notification-service/sealed-secret.yaml
````