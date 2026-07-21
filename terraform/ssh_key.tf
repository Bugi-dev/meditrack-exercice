# =============================================================
# Fichier : ssh_key.tf
# Objet   : Génération automatique de la paire de clés SSH utilisée pour l'accès à l'instance EC2 (Ansible).
# =============================================================

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- Import de la clé publique dans AWS -----------------------
resource "aws_key_pair" "meditrack" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

# --- Sauvegarde locale de la clé privée (usage pour Ansible) -------
resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/${var.ssh_key_name}.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0400"
}

# --- Délai de propagation ---------------------------------------
# Une paire de clés tout juste créée met parfois quelques secondes
# à être disponible pour RunInstances (cohérence à terme AWS).
# Ce délai évite l'erreur "InvalidKeyPair.NotFound" au premier apply.
resource "time_sleep" "wait_for_key_pair" {
  depends_on      = [aws_key_pair.meditrack]
  create_duration = "15s"
}
