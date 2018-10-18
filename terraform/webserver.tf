// Configuração do Plugin GCP provider
provider "google" {
  credentials = "${file("${var.service_account_json}")}" // <--- README.md
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

// Modulo para a implementação da Liberação de SSH
module "firewall-allow-ssh" {
  source        = "github.com/kickin6/terraform-google-firewall-rule"
  name          = "firewall-ssh-allow"
  project       = "${var.gcp_project}"
  network       = "${var.vpc}"
  priority      = "1000"
  protocol      = "tcp"
  ports         = ["22"]
  source_ranges = ["${var.ssh_allowed_range_ip}"]                     // <--- README.md
  target_tags   = ["allowed-ssh"]
}

// Modulo para a implementação do bloqueio de SSH
module "firewall-deny-ssh" {
  source        = "github.com/kickin6/terraform-google-firewall-rule/modules/ingress-deny-tags"
  name          = "firewall-ssh-deny"
  project       = "${var.gcp_project}"
  network       = "${var.vpc}"
  priority      = "9000"
  protocol      = "tcp"
  ports         = ["22"]
  source_ranges = ["${var.ssh_denied_range_ip}"]                                                // <--- README.md
  target_tags   = ["denied-ssh"]
}

// Modulo para a implementação da instancia no GCE
module "compute_engine" {
  source = "./compute-engine-ip"

  count_compute = 1                                                                     // contador ao lado do nome da Instancia
  count_start   = 1                                                                     // quantidade de instancias a serem criadas
  compute_name  = "${var.gce_instance_name}"
  compute_type  = "${var.gce_instance_type}"
  compute_zones = ["${var.gcp_region}-a", "${var.gcp_region}-b", "${var.gcp_region}-c"] // quais regiões são elegiveis a utilização

  tags_network      = "${var.tags_network}"
  network_interface = "${var.vpc}"
  images_name       = "centos-7"
  size_root_disk    = "${var.size_root_disk}"
  type_root_disk    = "${var.gce_instance_disk_type}"
  startup_script    = "./startup_script.sh"           // <--- README.md
  pub_key_file      = "${var.key_pub}"                // <--- README.md
  gce_ssh_user      = "centos"

  compute_labels = {
    "createdby"   = "terraform"
    "environment" = "test"
  }
}

output "instance_ip" {
  value = "${module.compute_engine.public_ip}"
}
