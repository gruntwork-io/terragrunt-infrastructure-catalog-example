# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "bucket" {
  bucket        = var.name
  force_destroy = var.force_destroy
}

# ---------------------------------------------------------------------------------------------------------------------
# ENABLE VERSIONING
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BLOCK PUBLIC ACCESS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "public_access" {
  count                   = var.block_public_access ? 1 : 0
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
