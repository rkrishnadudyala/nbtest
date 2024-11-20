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

provider "aws" {
  region  = "us-west-2"
}

locals {
  cluster_key = "cluster.${var.username}"
  namespace_key = "namespace.${var.username}"
  token = one(random_string.token[*].result)
}

/*

data "aws_lambda_invocation" "cluster" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  function_name = "km-redis"
  input = templatefile("input.json", {cluster_key= local.cluster_key})
}

data "aws_lambda_invocation" "namespace" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  function_name = "km-redis"
  input = templatefile("input.json", {cluster_key= local.namespace_key})
}

resource "rafay_namespace" "namespace" {
  count = length(jsondecode(data.aws_lambda_invocation.namespace.result)["remaining"]) > 0 ? 0 : 1
  metadata {
    name    = var.name
    project = var.project
  }
  spec {
    drift {
      enabled = false
    }
    placement {
      labels {
        key   = "rafay.dev/clusterName"
        value = length(jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"]) > 0 ? jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"][0] : null
      }
    }
  }
}*/

resource "rafay_workload" "jupyter-notebook" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  metadata {
    name    = var.name
    project = var.project
  }
  spec {
    namespace = var.name
    placement {
      labels {
        key   = "rafay.dev/clusterName"
        value = var.cluster_name
        #value = length(jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"]) > 0 ? jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"][0] : null
      }
      #selector = "rafay.dev/clusterName=length(jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"]) > 0 ? jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"][0] : null"
    }
    version = "v-${random_string.resource_code[0].result}"
    artifact {
      type = "Yaml"
      artifact {
        paths {
          name = "file://jupyter_notebook.yaml"
        }
      }
    }
  }
  #depends_on = [rafay_namespace.namespace,local_file.jupyter_notebook,aws_route53_record.jupyter]
  #depends_on = [local_file.jupyter_notebook,aws_route53_record.jupyter]
}

resource "rafay_access_apikey" "sampleuser" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  #count = jsondecode(data.aws_lambda_invocation.example.result)["remaining"] > 0 ? 1 :0
  user_name = var.username
}

/*
resource "null_resource" "get_ingress_ip" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  triggers = {
    always_run = "${timestamp()}"
  }
 # count = jsondecode(data.aws_lambda_invocation.example.result)["remaining"] > 0 ? 1 :0
  provisioner "local-exec" {
    command     = "./get-ingress-ip.sh"
    environment = {
      #CLUSTER_NAME= length(jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"]) > 0 ? jsondecode(data.aws_lambda_invocation.cluster.result)["remaining"][0] : null
      CLUSTER_NAME= var.cluster_name
      RAFAY_REST_ENDPOINT= "${var.rafay_rest_endpoint}"
      RAFAY_API_KEY="${rafay_access_apikey.sampleuser[0].apikey}"
      PROJECT="${var.project}"
    }
  }
  depends_on=[rafay_access_apikey.sampleuser]
}

data "local_file" "ingress_ip" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  #count = jsondecode(data.aws_lambda_invocation.example.result)["remaining"] > 0 ? 1 :0
  filename = "ingress-ip"
  depends_on = [null_resource.get_ingress_ip]
}

resource "aws_route53_record" "jupyter" {
  count = var.deploy_notebook == "yes" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "${var.name}.${var.ingress_domain}"
  type    = "A"
  ttl     = 300
  records = [data.local_file.ingress_ip[0].content]
}*/
