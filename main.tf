provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "argo_rollouts_namespace" {
  metadata {
    name = "argo-rollouts"
  }
}

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = "2.36.0"
  namespace  = kubernetes_namespace.argo_rollouts_namespace.metadata[0].name

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      kubectl wait --for=condition=available deployment -n ${kubernetes_namespace.argo_rollouts_namespace.metadata[0].name} argo-rollouts --timeout=300s
    EOT
  }

}

resource "kubernetes_namespace" "ingress_nginx_namespace" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "./helm-charts/ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx_namespace.metadata[0].name

  values = [
    file("./helm-charts/ingress-nginx/values.yaml")
  ]
}

resource "helm_release" "redis" {
  name       = "redis"
  chart      = "./helm-charts/redis"
  namespace  = "default"

  values = [
    file("./helm-charts/redis/values.yaml")
  ]
}

resource "helm_release" "rollouts_demo" {
  name       = "rollouts-demo"
  chart      = "./helm-charts/rollouts-demo"
  namespace  = "default"

  depends_on = [
    helm_release.argo_rollouts,
  ]

  values = [
    file("./helm-charts/rollouts-demo/values.yaml")
  ]

  provisioner "local-exec" {
    command = "kubectl argo rollouts set image rollouts-demo rollouts-demo=argoproj/rollouts-demo:blue"
    on_failure = continue
  }
}
