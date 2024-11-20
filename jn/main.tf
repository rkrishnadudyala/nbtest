resource "random_string" "resource_code" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  length  = 4
  special = false
  upper   = false
  keepers = {
    id = "${file("jupyter_notebook.yaml")}"
  }
}

resource "random_string" "token" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  length = 32
  special = false
  upper   = false
}

locals {
  cluster_key = "cluster.${var.username}"
  token = one(random_string.token[*].result)
}

resource "local_file" "jupyter_notebook" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  content = templatefile("${path.module}/templates/jupyter-notebook.tftpl", {
    image = [for v in var.notebook_profiles: v.image if v.name == var.notebook_profile][0]
    token = random_string.token[0].result
    ingress_host = "${var.name}.${var.ingress_domain}"
    cpu_request = var.cpu_request
    memory_request = var.memory_request
    cpu_limit = var.cpu_limit
    memory_limit = var.memory_limit
    gpu_limit = var.gpu_limit
  })
  filename = "jupyter_notebook.yaml"
}

data "rafay_download_kubeconfig" "kubeconfig_cluster" {
  cluster = var.cluster_name
}

resource "local_file" "kubeconfig" {
  lifecycle {
    ignore_changes = all
  }
  depends_on = [data.rafay_download_kubeconfig.kubeconfig_cluster]
  content    = data.rafay_download_kubeconfig.kubeconfig_cluster.kubeconfig
  filename   = "/tmp/test/host-kubeconfig.yaml"
}

provider "kubernetes" {
  config_path = "/tmp/test/host-kubeconfig.yaml"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.name
  }

  depends_on = [local_file.kubeconfig]
}

resource "null_resource" "apply_manifest" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/jupyter_notebook.yaml --kubeconfig=/tmp/test/host-kubeconfig.yaml -n ${var.name}"
  }


  depends_on = [local_file.kubeconfig, kubernetes_namespace.namespace]
}
