# =============================================================
# Fichier : s3.tf
# Objet   : Bucket S3 hébergeant le site statique MediTrack Online
#           Accès public bloqué : seul CloudFront peut lire le contenu
# =============================================================

# --- Bucket principal ----------------------------------------
resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.project_name}-static-site"
  }
}

# --- Blocage de tout accès public direct ---------------------
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Chiffrement au repos (SSE-S3 / AES-256) -----------------
resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- Versioning : protection contre les suppressions ---------
resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# --- Politique du bucket : lecture réservée à CloudFront -----
# Seule la distribution CloudFront (via OAC) est autorisée à lire les objets du bucket.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  # Dépendance explicite : garantit que CloudFront est bien créé
  # (et son ARN connu) avant d'écrire la policy S3.
  depends_on = [aws_cloudfront_distribution.site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontReadOnly"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site.arn
          }
        }
      }
    ]
  })
}

# --- Téléversement automatique des fichiers du site ----------
# Terraform pousse les fichiers du dossier ../site vers S3.
resource "aws_s3_object" "site_files" {
  for_each = fileset("${path.module}/../site", "**/*")

  bucket = aws_s3_bucket.site.id
  key    = each.value
  source = "${path.module}/../site/${each.value}"
  etag   = filemd5("${path.module}/../site/${each.value}")

  # Type MIME correct selon l'extension du fichier
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
  }, element(split(".", each.value), length(split(".", each.value)) - 1), "application/octet-stream")
}
