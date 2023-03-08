resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [
    kubernetes_storage_class.main
  ]
}

resource "random_password" "main" {
  length      = 16
  special     = false
  min_numeric = 4
  min_upper   = 4
  keepers = {
    #Fix so password changes only when changing the project
    "project" = var.google_project
  }
}

#This secret is for argocd-sugar plugin only.
resource "kubernetes_secret" "argocd" {
  metadata {
    name      = "argocd-sugar"
    namespace = kubernetes_namespace.argocd.id
  }

  data = {
    ARGOCD_ENV_GOOGLE_PROJECT = var.google_project
    ARGOCD_ENV_GOOGLE_REGION  = var.google_region
    ARGOCD_ENV_CLUSTER_NAME   = var.name
    ARGOCD_ENV_DOMAIN         = var.domain
    ARGOCD_ENV_RANDOM_STRING  = random_password.main.result
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.21.0"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  recreate_pods    = true
  wait             = false

  values = [
    file("./config/argocd/values.yaml")
  ]

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.domain}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${var.domain}"
  }

  set {
    name  = "configs.repositories.private-repo.url"
    value = var.argocd_repo_url
  }

  set {
    name  = "configs.credentialTemplates.ssh-creds.url"
    value = var.argocd_credentials_url
  }

  set_sensitive {
    name  = "configs.credentialTemplates.ssh-creds.sshPrivateKey"
    value = base64decode(var.argocd_credentials_key)
  }

  depends_on = [
    kubernetes_secret.argocd
  ]
}

resource "kubectl_manifest" "argocd" {
  force_new          = true
  override_namespace = helm_release.argocd.namespace

  #Not reading from file because I need the dynamic repoURL
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: main
  namespace: argocd

spec:
  project: default
  source:
    repoURL: ${var.argocd_repo_url}
    targetRevision: main
    path: day-2
    plugin:
      env:
        - name: "DIRECTORY_RECURSE"
          value: "true"

  destination:
    server: https://kubernetes.default.svc
    namespace: main

  # Ignore Kyverno automatically generated and updated Cluster Policies that result on always "Out of sync" state
  ignoreDifferences:
    - group: kyverno.io
      kind: ClusterPolicy
      jqPathExpressions:
        - .spec.rules[] | select(.name|test("autogen-."))

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: true
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
YAML

  depends_on = [
    helm_release.argocd
  ]
}