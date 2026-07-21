# =============================================================
# Fichier : variables.tf
# Objet   : Variables d'entrée du projet MediTrack
# =============================================================

variable "aws_region" {
  description = "Région AWS de déploiement"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environnement cible (test ou production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["test", "production"], var.environment)
    error_message = "L'environnement doit être 'test' ou 'production'."
  }
}

variable "project_name" {
  description = "Nom court du projet, utilisé pour nommer les ressources"
  type        = string
  default     = "meditrack"
}

variable "bucket_name" {
  description = "Nom (globalement unique) du bucket S3 du site statique"
  type        = string
  default     = "meditrack-online-static-site"
}

variable "vpc_cidr" {
  description = "Plage d'adresses IP du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Plage d'adresses IP du sous-réseau public"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Type de l'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Nom de la paire de clés SSH générée par Terraform pour l'accès EC2"
  type        = string
  default     = "meditrack-key"
}

variable "admin_ip" {
  description = "Adresse IP publique de l'administrateur en SSH"
  type        = string
  default     = "0.0.0.0/32"
}
