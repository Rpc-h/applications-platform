# application-platform

This project aims to provide you with a fully-automated Kubernetes platform with focus on monitoring, security, accessability, and ease-of-use.

# Setup

## Preparation

Make sure you have:
- A Github account with escalated permissions to set secrets.
- A GCP service account with escalated permissions to create resources. For example, for only the duration of the pipeline, you can attach the service account with `roles/owner` role. Note: please remove the escalated permissions when done with pipeline steps `day-0` and `day-1` for security reasons.
- A GCP storage bucket for storing Terraform state.
- GCP APIs enabled:
  - `compute.googleapis.com`
  - `container.googleapis.com`
  - `dns.googleapis.com`
- A new RSA keypair with no passphrase for ArgoCD to access the Github repo. The public key of this keypair has to be then uploaded to the deploy keys of the repository; the private key has to be set as a secret variable `ARGOCD_CREDENTIALS_KEY`. This key should not be used by any other service accounts / users; hence do not bother storing this key. You can generate the keypair by running:

```shell
ssh-keygen -b 2048 -t rsa -f /tmp/id_rsa -q -N "" -C rpch-alligator
```

## Secret variables

We try to keep as little secret variables as possible by design. For the sake of convenience, define the following secrets in your Github secrets section:

- `GOOGLE_APPLICATION_CREDENTIALS` = Base64-encoded GCP service account credentials. The values are also stored in Bitwarden (https://vault.bitwarden.com/#/vault?collectionId=27d47d9e-9155-446a-8275-af8600ad0076) under the secret `Terraform Service Account`.
- `GOOGLE_PROJECT` = GCP project ID.
- `GOOGLE_REGION` = GCP project default region.
- `GOOGLE_BUCKET` = GCP bucket for storing Terraform state.
- `ARGOCD_CREDENTIALS_KEY` = Base64-encoded ArgoCD credentials private key from the previously generated keypair. The values are also stored in Bitwarden (https://vault.bitwarden.com/#/vault?collectionId=27d47d9e-9155-446a-8275-af8600ad0076) under the secret `Terraform Service Account`.

## Non-secret variables

For non-secret variables, simply edit/add them in the `.env` file, which gets sourced during pipeline runs, e.g.:

```dotenv
TF_VAR_name="rpch-alligator"
TF_VAR_domain="rpch.tech"
TF_VAR_argocd_repo_url="git@github.com:Rpc-h/infrastructure.git"
TF_VAR_argocd_credentials_url="git@github.com:Rpc-h"
```

## Installation

### Github

Run the `day-0-apply` workflow in Github to install `day-0` resources such as:
- GKE Kubernetes cluster and node pools.
- IAM service accounts and bindings for the Kubernetes cluster.
- VPC networks and firewall rules for the Kubernetes cluster.

After successful completion of `day-0-apply`, run the `day-1-apply` workflow in Github to install `day-1` resources such as:
- ArgoCD helm chart and the initial ArgoCD app-of-apps.
- IAM service accounts and bindings for `day-2` applications, e.g. `cert-manager`, `external-dns`, etc.

### Local

To run Terraform locally, change into the day you want to run, generate new service account credentials or re-use existing ones, export some env variables and initialize the backend config with the specific bucket:

```shell
cd day-0 #TODO - change this to the day you want to run

gcloud iam service-accounts keys create credentials.json --iam-account rpch-staging-initial@rpch-375921.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=${PWD}/credentials.json
export TF_VAR_google_project="rpch-375921"
export TF_VAR_google_region="europe-west6"

terraform init -backend-config="bucket=rpch-alligator-terraform"
terraform plan
```

## Uninstallation

Run the `day-1-destroy` workflow in Github to destroy `day-1`. After successful completion of `day-1-destroy`, run the `day-0-destroy` workflow in Github to destroy `day-0`. Note that some of the `day-2` cloud provider resources created by your apps, such as load balancers and DNS entries, might interfere with the current destruction of `day-1` and `day-0`. Either make sure everything in `day-2` is uninstalled cleanly, or you might have to do remove the stuck resources manually.

# Usage

## Access

1. Ensure your administrator has given enough permissions, e.g. your IAM user is assigned with `roles/container.developer` role.
2. Install Google Cloud CLI as described here: https://cloud.google.com/sdk/docs/install-sdk.
3. Acquire the cluster related info by running `gcloud container clusters list`.
4. Follow the instructions on how to access the Kubernetes cluster here: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl. Run `gcloud auth login` and follow the on-screen instructions and pick the correct Google project. Next run `gcloud  get generate
5. Verify you're able to access the cluster and see the nodes by running: `kubectl get nodes`.

## Applications

These are just some convenience commands for developers that might come in handy. Please see the official upstream docs of the respective applications for more info.

### Authelia

To generate `authelia` password, run the following command:

```shell
export AUTHELIA_PASSWORD="your-password"
docker run authelia/authelia:latest authelia crypto hash generate argon2 --password ${AUTHELIA_PASSWORD}
```

### ArgoCD

To retrieve ArgoCD password run:

```shell
kubectl -n argocd get secrets argocd-initial-admin-secret -o yaml | yq -r '.data["password"]' | base64 -d
```

### Grafana

To retrieve Grafana password run:

```shell
kubectl -n monitoring get secrets kube-prometheus-stack-grafana -o yaml | yq -r '.data["admin-password"]' | base64 -d
```

### Sealed Secrets

Make sure you have the `kubeseal` binary installed: https://github.com/bitnami-labs/sealed-secrets. To generate a sealed secret run:

```shell
export NAMESPACE=your-namespace
export SECRET_NAME=your-secret

cat << EOF > /tmp/env
your-key=your-value
your-another-key=your-another-value
EOF

kubectl create secret generic -n $NAMESPACE $SECRET_NAME --from-env-file /tmp/env -oyaml --dry-run=client > /tmp/${SECRET_NAME}-secret.yaml
cat /tmp/${SECRET_NAME}.yaml | kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets -oyaml | tee /tmp/${SECRET_NAME}-sealed-secret.yaml
```

Now you can copy the sealed-secret file to where you need it.

#### Prometheus

To generate the sealed secret execute the following command:

```shell
export HOPRD_API_TOKEN=XXXXXX
sed 's#__SCRAPE_USERNAME__#'"$HOPRD_API_TOKEN"'#g' ./prometheus-scrape-config.yaml | kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets --format yaml > ./day-2/monitoring/kube-prometheus-stack/sealed-secrets/prometheus-scrape-config.yaml
```