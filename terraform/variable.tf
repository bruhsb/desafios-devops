// Arquivo contendo as variaveis de configuração do projeto.

// Definição da Imagem a ser utilizada

// GCP ENVs

variable "gcp_project" {} // Projeto no GCP ao qual será implementado a solução

variable "gcp_region" {
  type    = "string"
  default = "us-central1" // Ragião a ser utilizada
}

variable "service_account_json" {} // Chave JSON com os dados de acesso da conta de serviço

// Configurações de Rede

variable "vpc" {
  type    = "string"
  default = "default"
}

variable "ssh_allowed_range_ip" {
  type    = "string"    // Range de IP a ser liberado
  default = "0.0.0.0/0"
}

variable "ssh_denied_range_ip" {
  type    = "string"    // Range de IP a ser bloqueado
  default = "0.0.0.0/0"
}

variable "tags_network" {
  type    = "list"
  default = ["http-server", "https-server", "allowed-ssh", "denied-ssh"] // Tags de Rede a serem aplicadas na Intancias
}

variable "key_pub" {
  default = "~/.ssh/id_rsa.pub" // Chave pública para acesso por SSH
}

// Configurações de GCE

variable "gce_instance_name" {
  default = "webserver"
}

variable "gce_instance_type" {
  default = "n1-standard-1"
}

variable "gce_instance_disk_type" {
  default = "pd-standard" // pd-standard ou pd-ssd
}

variable "size_root_disk" {
  default = "50"
}
