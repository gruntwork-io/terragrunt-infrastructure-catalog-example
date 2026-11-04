# GCP Firestore Database Example

This is an example of how to use the [gcp/firestore-database module](/modules/gcp/firestore-database).

## Quick start

1. Log in to GCP with `gcloud auth application-default login`, select the project to deploy into with
   `gcloud config set project`, and export its ID: `export GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project)"`.
2. Enable the Firestore API: `gcloud services enable firestore.googleapis.com`.
3. Run `tofu init`.
4. Run `tofu apply -var name=acme-example`, replacing `acme-example` with your own name (it must be 4-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit, and unique in the project).
5. When you're done testing, run `tofu destroy -var name=acme-example` with the same name.
