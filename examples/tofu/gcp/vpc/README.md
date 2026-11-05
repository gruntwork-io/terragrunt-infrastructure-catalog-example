# GCP VPC Network Example

This is an example of how to use the [gcp/vpc module](/modules/gcp/vpc).

## Quick start

1. Log in to GCP with `gcloud auth application-default login`, select the project to deploy into with
   `gcloud config set project`, and export its ID: `export GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project)"`.
2. Enable the Compute Engine API, which manages networks: `gcloud services enable compute.googleapis.com`.
3. Run `tofu init`.
4. Run `tofu apply -var name=acme-example`, replacing `acme-example` with your own name (it must be lowercase letters, digits and hyphens, starting with a letter, and unique in the project).
5. When you're done testing, run `tofu destroy -var name=acme-example` with the same name.
