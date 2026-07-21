# =============================================================
# Fichier : cloudfront.tf
# Objet   : Distribution CloudFront diffusant le site statique
#           - HTTPS obligatoire (redirection HTTP -> HTTPS)
#           - Certificat TLS géré par AWS
#           - Accès au bucket S3 via Origin Access Control (OAC)
# =============================================================

# --- Origin Access Control : identité CloudFront -> S3 -------
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project_name}-oac"
  description                       = "Acces securise de CloudFront au bucket S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- Distribution CloudFront ---------------------------------
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution du site statique MediTrack"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Europe + Amérique du Nord

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${var.bucket_name}"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # SÉCURITÉ : tout accès HTTP est redirigé vers HTTPS
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Pas de restriction géographique
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificat TLS par défaut de CloudFront (*.cloudfront.net)
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  # Page d'erreur personnalisée
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  tags = {
    Name = "${var.project_name}-cloudfront"
  }
}
