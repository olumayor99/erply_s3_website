resource "aws_s3_bucket" "erply_s3_website" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_website_configuration" "erply_s3_website" {
  bucket = aws_s3_bucket.erply_s3_website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "erply_s3_website" {
  bucket = aws_s3_bucket.erply_s3_website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "erply_s3_website" {
  bucket     = aws_s3_bucket.erply_s3_website.id
  policy     = data.aws_iam_policy_document.erply_s3_website.json
  depends_on = [aws_s3_bucket.erply_s3_website]
}

data "aws_iam_policy_document" "erply_s3_website" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    effect = "Allow"

    resources = [
      aws_s3_bucket.erply_s3_website.arn,
      "${aws_s3_bucket.erply_s3_website.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_acl" "erply_s3_website" {
  bucket     = aws_s3_bucket.erply_s3_website.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.erply_s3_website]
}

locals {
  content_types = {
    css  = "text/css"
    html = "text/html"
    js   = "application/javascript"
    json = "application/json"
    txt  = "text/plain"
    png  = "image/png"
    svg  = "image/svg+xml"
  }
}

resource "aws_s3_object" "erply_s3_website" {
  for_each     = fileset("../Landing-Page-React/build/", "**/*.*")
  bucket       = aws_s3_bucket.erply_s3_website.id
  key          = each.value
  source       = "../Landing-Page-React/build/${each.value}"
  etag         = filemd5("../Landing-Page-React/build/${each.value}")
  acl          = "public-read"
  content_type = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  depends_on = [aws_s3_bucket_policy.erply_s3_website]
}

resource "aws_s3_bucket_public_access_block" "erply_s3_website" {
  bucket                  = aws_s3_bucket.erply_s3_website.id
  block_public_policy     = false
  restrict_public_buckets = false
  block_public_acls       = false
  ignore_public_acls      = false
}

resource "aws_s3_bucket_ownership_controls" "erply_s3_website" {
  bucket = aws_s3_bucket.erply_s3_website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.erply_s3_website]
}