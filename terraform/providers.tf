# =============================================================
# Projet   : MediTrack Cloud Deployment - GreenOps Solutions
# Fichier  : providers.tf
# Objet    : Configuration de Terraform et du provider AWS
# =============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

# Le provider AWS utilise les identifiants configurés via `aws configure` (utilisateur IAM dédié "meditrack-deploy").
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "MediTrack-Cloud-Deployment"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Client      = "MediTrack"
    }
  }
}

# Provider secondaire en us-east-1 : obligatoire pour les certificats ACM utilisés par CloudFront (contrainte AWS).
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
