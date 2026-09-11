variable "project_id" {}
variable "region" {}
variable "iam_members" {}

provider "google" {
  project = var.project_id # Wajib ada di provider
  region = var.region
}

module "iam_foundation" {
  source      = "../../modules/iam"
  project_id  = var.project_id   # <-- Lempar ID ke dalam modul
  iam_members = var.iam_members
}