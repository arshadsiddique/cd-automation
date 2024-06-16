provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "redis" {
  name       = "redis"
  chart      = "./helm-charts/redis"

  values = [
    file("./helm-charts/redis/values.yaml")
  ]
}

resource "helm_release" "rollouts_demo" {
  name       = "rollouts-demo"
  chart      = "./helm-charts/rollouts-demo"

  values = [
    file("./helm-charts/rollouts-demo/values.yaml")
  ]

  provisioner "local-exec" {
    command = "kubectl argo rollouts set image rollouts-demo rollouts-demo=argoproj/rollouts-demo:blue"
    on_failure = continue
  }
}
