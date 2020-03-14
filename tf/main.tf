terraform {
  backend "s3" {
    bucket = "kimhyonju-portfolio-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
  required_version = "= 0.12.23"
}

provider "aws" {
  version = "= 2.52.0"
}

resource "aws_s3_bucket" "kimhyonju-portfolio" {
  acl           = "private"
  bucket        = "kimhyonju-portfolio"
  force_destroy = false
  region        = "ap-northeast-1"
}

resource "aws_s3_bucket_policy" "kimhyonju-portfolio" {
  bucket = "${aws_s3_bucket.kimhyonju-portfolio.id}"
  policy = <<POLICY
    {
      "Version": "2012-10-17",
      "Id": "PolicyForCloudFrontPrivateContent",
      "Statement": [
        {
          "Action": "s3:GetObject",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E2TQMNU2GUNNZ4"
          },
          "Resource": "arn:aws:s3:::kimhyonju-portfolio/*",
          "Sid": " Grant a CloudFront Origin Identity access to support private content"
        }
      ]
    }
POLICY
}

locals {
  s3_origin_id = "S3-kimhyonju-portfolio"
}
resource "aws_cloudfront_distribution" "kimhyonju-portfolio_distribution" {
  aliases                        = []
  enabled                        = true
  http_version                   = "http2"
  is_ipv6_enabled                = true
  price_class                    = "PriceClass_All"
  retain_on_delete               = false
  tags                           = {}
  wait_for_deployment            = true

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "${local.s3_origin_id}"
    trusted_signers        = []
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  origin {
    domain_name = "${aws_s3_bucket.kimhyonju-portfolio.bucket_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E2TQMNU2GUNNZ4"
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
