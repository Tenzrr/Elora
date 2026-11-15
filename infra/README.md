# Development deployment gate

Nothing in this directory provisions a billable service until BILLING_APPROVED=true and CLOUD_SERVICES_READY=true. The Google project is `elora-dev-9f6b9`, region `asia-south1`. Supabase is development-only; the final SRS is unchanged.

## Resources requiring the owner's cost approval

- One Cloud Run integration API and at most five separate preview services; each 1 CPU, 512 MiB, concurrency 20, min 0/max 1.
- Artifact Registry Docker repository `elora-api` and Cloud Build.
- A private, uniform-access image bucket with public access prevention.
- Secret Manager entries for scoped database URLs.
- Workload identity for GitHub deployment and distinct API runtime service accounts.
- No Cloud SQL instance, model-serving service, Cloud Tasks, paid weather or paid LLM is provisioned by the foundation.

## Coordinator bootstrap after approval

Enable Run, Cloud Build, Artifact Registry, Secret Manager, IAM Credentials and Security Token Service APIs in the development project. Create the Docker repository in the chosen region and a uniquely named private image bucket. Configure object lifecycle/soft-delete policy and artifact retention; remove stale preview images during preview retirement. Pin the approved resource configuration and record actual monthly limits in the estimate.

Configure a dedicated GitHub deployment identity through Workload Identity Federation, restricted to this repository and approved deployment workflows, and a protected GitHub environment `development` with maintainer approval. Keep provisioning authority out of ordinary API runtime identities. The deployer needs development-project Cloud Run administration, Cloud Build submission, repository access, secret management, runtime service-account creation/binding, and permission to attach the runtime identity. Cloud Build's actual build identity needs source-object access, artifact writer and logging permissions. These roles must be reviewed against the selected billing/project policy before enabling deployment.

Runtime identities are created per integration/preview service; they receive Firebase Auth Viewer, their own database secret access and bucket access conditioned to `private/<workspace>/`. Signed object URLs require signing permission on their own identity. They receive no Supabase admin credential and cannot read another workspace's database secret.

Repository variables:
```text
BILLING_APPROVED=false
CLOUD_SERVICES_READY=false
CLOUD_PROJECT_ID=elora-dev-9f6b9
CLOUD_REGION=asia-south1
SUPABASE_PROJECT_REF=idptcxheihiakwttvkgo
ASSET_BUCKET=<approved-private-bucket>
WIF_PROVIDER=<provider-resource-name>
DEPLOY_SERVICE_ACCOUNT=<reviewed-deployer-email>
```

Protected environment secret: `DEV_DATABASE_ADMIN_URL`, the Supabase session-pooler coordinator URL. Never put it in workflow YAML, ordinary developer configuration or Flutter.

## Operation

- After successful CI on merged `develop`, the integration deployment workflow migrates the workspace and deploys a candidate revision without moving stable traffic. A health check precedes traffic promotion.
- Request a preview through manual workflow dispatch with an internal PR number and the full reviewed commit SHA. A reviewer must approve that exact commit, including workflow and migration code, before granting privileged credentials. Restrict workload identity to the designated workflow on the default branch and dispatch from that branch. Fork PRs are rejected.
- Migration/deployment/cleanup workflows share one concurrency group. Review additive migrations for old-code compatibility before integration rollout; failed migrations do not trigger deployment.
- Preview services are labelled with a 48-hour expiry and retired by hourly/PR-close cleanup after checking PR state. Close/expired synthetic preview data is disposable. Integration and dev1–dev5 cannot be retired by this tool.
- Existing runtime credentials are reused on redeploy so the previous healthy revision remains usable. Review rollback by selecting the last healthy Cloud Run revision; never blindly downgrade a shared database.
- An empty labelled secret records each preview before database/build work starts. Its 48-hour expiry allows cleanup of failed first deployments too. Cleanup removes preview objects, role/schema, service account, artifact package and secret, deleting the ledger last so interrupted cleanup can retry. No live rollout/cleanup verification is claimed until services are configured.
- GitHub workflow dispatch/workflow_run registration requires these workflow files on the repository default branch. Initial smoke deployment can be run by the coordinator from this branch in Cloud Shell after approval. Promote reviewed foundation changes before enabling normal automation.

## Verification before enabling

Review the itemized cost estimate; approve billing ownership/budget. Then provision and record exact resource IDs/roles, test identity and database connectivity, deploy integration, exercise real profile/plant calls with two test users, create a preview, verify schema/bucket isolation, test migration/health failure and rollback, and retire it. Keep both gate variables false until bootstrap and permissions are verified. Do not treat static CI or absent credentials as a passed cloud test.
