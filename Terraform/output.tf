output "s3_website_endpoint" {
  value = aws_s3_bucket.erply_s3_website.website_endpoint
}

output "s3_website_domain" {
  value = aws_s3_bucket.erply_s3_website.website_domain
}