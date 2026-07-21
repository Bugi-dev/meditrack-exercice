# MediTrack Cloud Deployment — GreenOps Solutions

Automatisation du déploiement de l'infrastructure AWS du site **MediTrack Online** (suivi et maintenance du matériel médical) avec **Terraform** et **Ansible**.

## Architecture

```
Utilisateurs ──HTTPS──> CloudFront ──OAC──> Bucket S3 (site statique, chiffré)
                                   
Admin ──SSH (IP restreinte)──> EC2 t3.micro (Nginx, EBS chiffré)
                                └── dans un VPC dédié 10.0.0.0/16
```

| Ressource | Rôle |
|---|---|
| VPC + sous-réseau public | Réseau isolé et sécurisé |
| Bucket S3 | Hébergement des fichiers statiques (accès public bloqué) |
| CloudFront + OAC | Diffusion HTTPS du site, redirection HTTP→HTTPS |
| EC2 t3.micro | Serveur web Nginx optionnel (EBS chiffré) |

## Structure du dépôt

```
├── terraform/          # Infrastructure as Code (provisionnement AWS)
├── ansible/            # Configuration du serveur EC2 (Nginx, sécurité)
└── site/               # Fichiers statiques du site MediTrack Online
```

## Prérequis

- Terraform >= 1.5, Ansible >= 2.15, AWS CLI v2
- Un utilisateur IAM dédié `meditrack-deployer` avec les politiques gérées AWS : `AmazonVPCFullAccess`, `AmazonEC2FullAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess` (moindre privilège : uniquement les 4 services du projet)

## Déploiement

```bash
# 1. Provisionnement de l'infrastructure
cd terraform
terraform init
terraform plan          # vérification du plan d'exécution
terraform apply         # création des ressources

# 2. Configuration du serveur EC2 (inventory.ini généré par Terraform)
cd ../ansible
ansible-playbook playbook.yml

# 3. Vérification
terraform -chdir=../terraform output cloudfront_url
curl -I https://<id>.cloudfront.net   # doit retourner HTTP/2 200
curl -I http://<id>.cloudfront.net    # doit retourner 301 (redirection HTTPS)
```

## Destruction

```bash
cd terraform && terraform destroy
```

---
Projet réalisé dans le cadre de l'étude de cas GreenOps Solutions.
