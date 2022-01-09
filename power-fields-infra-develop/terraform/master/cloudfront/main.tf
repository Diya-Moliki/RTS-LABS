terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource aws_cloudfront_distribution web_cfd {
  origin {
    domain_name = var.web_bucket_regional_domain
    origin_id   = "web-${var.client_name}-${var.environment}-${var.application_name}-origin"

    s3_origin_config {
      origin_access_identity = var.origin_access_identity_path
    }
  }
  origin {
    domain_name = "${var.document_attachment_bucket_name}.s3.amazonaws.com"
    origin_id   = "S3-${var.document_attachment_bucket_name}"
  }
  origin {
    domain_name = "${var.config_bucket_name}.s3.amazonaws.com"
    origin_id   = "S3-${var.config_bucket_name}"
  }
  origin {
    domain_name = "${var.public_assets_bucket_name}.s3.amazonaws.com"
    origin_id   = "S3-${var.public_assets_bucket_name}"

    s3_origin_config {
      origin_access_identity = var.public_assets_origin_access_identity_path
    }
  }

  #todo fix this
  # Currently fails on creation with alias, but succeeds on update? must create the cloudfront distribution without alias first
  # Seems to prefer having the route 53 record pointing to the CDN before declared as an alias?
  aliases = [
    var.environment != "prod" ? "${var.client_name}.${var.environment}.${var.zone}" : "${var.client_name}.${var.zone}"
  ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "${var.client_name}.${var.environment}.${var.zone} CloudFront Distribution"

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
    error_caching_min_ttl = 60
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logging.bucket_domain_name
    prefix          = ""
  }

  ordered_cache_behavior {
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    path_pattern = "/configured-assets/*"
    target_origin_id = "S3-${var.config_bucket_name}"
    viewer_protocol_policy = "https-only"
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    path_pattern = "/document-attachments/*"
    target_origin_id = "S3-${var.document_attachment_bucket_name}"
    viewer_protocol_policy = "https-only"
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    path_pattern = "/public-assets/*"
    target_origin_id = "S3-${var.public_assets_bucket_name}"
    viewer_protocol_policy = "https-only"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    target_origin_id = "web-${var.client_name}-${var.environment}-${var.application_name}-origin"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = [
        "US"
      ]
    }
  }

  tags = merge(
    var.tags,
    map("Name", "${var.zone}-cfd"),
    map("Tier", "web")
  )

  web_acl_id = var.environment == "uat" || var.environment == "demo" || var.environment == "prod" ? "" : aws_waf_web_acl.waf_acl.id
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }

  depends_on = [
    aws_acm_certificate_validation.cert_val
  ]

}

# Modify existing distribution with aliases, assuming original resource is created without them
# resource "null_resource" "cloudfront_alias" {
#   provisioner "local-exec" {
#     command = "aws cloudfront update-distribution --id ${aws_cloudfront_distribution.web_cfd.id} --if-match ${aws_cloudfront_distribution.web_cfd.id} --distribution-config file://files/cf_distribution.json"
#   }
# }