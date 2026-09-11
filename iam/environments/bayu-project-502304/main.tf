variable "project_id" {}
variable "region" {}
variable "iam_members" {}
variable "target_id" {}
variable "target_type" {}

provider "google" {
  project = var.project_id # Wajib ada di provider
  region = var.region
}

# module "iam_foundation" {
#   source      = "../../modules/iam"
#   project_id  = var.project_id   # <-- Lempar ID ke dalam modul
#   iam_members = var.iam_members
# }

module "iam_foundation" {
  source      = "../../modules/iam"
  
  target_type = var.target_type
  target_id   = var.target_id
  iam_members = var.iam_members
}