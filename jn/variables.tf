variable "image" {
  default="jupyter/minimal-notebook:latest"
}

variable "ingress_domain" {
  default = "notebook.dev.rafay-edge.net"
}

variable "name" {}
variable "project" {}
variable "username" {}
variable "cluster_name" {}
variable "route53_zone_id" {
    default="Z06542572EP0CEJWIKH3"
}
variable "rafay_rest_endpoint" {
  default = "nvidia.rafay.dev"
}

variable "deploy_notebook" {
    default = "no"
}

variable "notebook_profiles" {
    description = "(Optional) Profiles of Notebook."
    type = list(any)
    default = [
        {
            "name" : "Minimal environment",
            "image": "jupyter/minimal-notebook:latest"
        },
        {
            "name": "Datascience environment",
            "image": "jupyter/datascience-notebook:latest"
        },
        {
            "name": "Spark environment",
            "image": "jupyter/all-spark-notebook:latest"
        },
        {
            "name": "Tensorflow environment",
            "image": "jupyter/tensorflow-notebook:latest"
        }
    ]
}

variable "notebook_profile" {
    default = "Minimal environment"
}

variable "cpu_request" {
    default = "1"
}
variable "memory_request" {
    default = "1Gi"
}
variable "cpu_limit" {
    default = "2"
}
variable "memory_limit" {
    default = "4Gi"
}
variable "gpu_limit" {
    default = "1"
}