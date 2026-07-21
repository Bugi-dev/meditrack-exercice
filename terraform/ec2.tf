# =============================================================
# Fichier : ec2.tf
# Objet   : Instance EC2 légère (serveur web Nginx configuré ensuite par Ansible) avec volume EBS chiffré
# =============================================================

# --- Récupération de la dernière AMI Ubuntu 22.04 LTS --------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Instance EC2 --------------------------------------------
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.meditrack.key_name

  depends_on = [time_sleep.wait_for_key_pair]

  # SÉCURITÉ / CONFORMITÉ RGPD-HDS :
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "${var.project_name}-web-server"
    Role = "nginx-web"
  }
}

# --- IP publique fixe (Elastic IP) ---------------------------
# Garantit une adresse stable pour l'inventaire Ansible.
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-web-eip"
  }
}
