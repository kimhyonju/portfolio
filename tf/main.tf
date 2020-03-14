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
