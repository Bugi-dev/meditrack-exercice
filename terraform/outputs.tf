# =============================================================
# Fichier : outputs.tf
# Objet   : Sorties utiles après `terraform apply`
# =============================================================

output "cloudfront_url" {
  description = "URL publique du site MediTrack Online (HTTPS)"
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "s3_bucket_name" {
  description = "Nom du bucket S3 hébergeant le site statique"
  value       = aws_s3_bucket.site.id
}

output "ec2_public_ip" {
  description = "IP publique de l'instance EC2 (pour l'inventaire Ansible)"
  value       = aws_eip.web.public_ip
}

output "vpc_id" {
  description = "Identifiant du VPC créé"
  value       = aws_vpc.main.id
}

# Génération automatique de l'inventaire Ansible à partir de l'IP de l'instance EC2 (chaînage Terraform -> Ansible)
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [webservers]
    meditrack-web ansible_host=${aws_eip.web.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.module}./terraform/${var.ssh_key_name}.pem
  EOT
}
