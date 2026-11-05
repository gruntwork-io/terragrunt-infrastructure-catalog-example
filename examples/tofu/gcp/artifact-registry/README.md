# GCP Artifact Registry Example

This is an example of how to use the [gcp/artifact-registry module](/modules/gcp/artifact-registry).

## Quick start

1. Log in to GCP with `gcloud auth application-default login`, select the project to deploy into with
   `gcloud config set project`, and export its ID: `export GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project)"`.
2. Enable the Artifact Registry API: `gcloud services enable artifactregistry.googleapis.com`.
3. Run `tofu init`.
4. Run `tofu apply -var name=acme-example`, replacing `acme-example` with your own name (it must be 1-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit, and unique in its location).
5. When you're done testing, run `tofu destroy -var name=acme-example` with the same name.
