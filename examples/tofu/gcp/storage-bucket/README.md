# GCP Storage Bucket Example

This is an example of how to use the [gcp/storage-bucket module](/modules/gcp/storage-bucket).

## Quick start

1. Log in to GCP with `gcloud auth application-default login`, select the project to deploy into with
   `gcloud config set project`, and export its ID: `export GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project)"`.
2. Run `tofu init`.
3. Run `tofu apply -var name=acme-example`, replacing `acme-example` with your own name (it must be 3-63 lowercase letters, digits, hyphens and underscores, starting and ending with a letter or digit, and unique across all of GCP).
4. When you're done testing, run `tofu destroy -var name=acme-example` with the same name.
