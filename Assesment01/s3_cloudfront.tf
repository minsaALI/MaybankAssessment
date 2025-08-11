resource "aws_s3_bucket" "static" {
  bucket = "${var.name_prefix}-static-bucket-0000" # change to unique bucket name
  acl    = "private"
  force_destroy = false
  tags = { Name = "${var.name_prefix}-s3" }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name = "${var.name_prefix}-oac"
  description = "Origin Access Control for CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  origins {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id   = "s3-${aws_s3_bucket.static.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${aws_s3_bucket.static.id}"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Name = "${var.name_prefix}-cdn" }
}
