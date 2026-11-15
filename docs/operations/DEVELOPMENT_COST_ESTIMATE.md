# Development hosting estimate — not approved

Prepared 15 November 2026. **No billing account has been linked or paid resource provisioned by the agent.** Supabase/Firebase projects were created by the owner. Paid hosting remains behind two false-by-default gate variables.

## Proposed configuration and workload

Google project elora-dev-9f6b9, Mumbai/asia-south1. One integration API plus at most five 48-hour previews. Each Cloud Run service: request-based billing, 1 CPU, 512 MiB, concurrency 20, min 0/max 1. No Cloud SQL, inference, LLM, speech or paid weather resource is included.

Planning workload across all services: 100,000 requests/month averaging 0.5 seconds of one CPU and 0.5 GiB; 30 builds of five minutes; at most 5 GiB retained container artifacts, 1 GiB development images and 1 GiB outbound traffic. Six active database-secret versions, fewer than 10,000 secret reads, and less than 1 GiB metadata logs. Actual workload/region SKUs must be checked against the billing account before enabling gates.

## Monthly planning estimate (USD, before tax)

| Item | Calculation/assumption | Allowance |
|---|---|---:|
| Cloud Run active requests | 50,000 CPU-seconds x conservative planning rate $0.000040 + 25,000 GiB-seconds x $0.000004 + $0.04 requests | $2.14 |
| Cold starts/retries reserve | Another full active-request allowance | $2.14 |
| Cloud Build | 150 minutes x published e2-standard-2 rate $0.006, before any promotional free allowance | $0.90 |
| Artifact Registry | 5 GiB x $0.10/GiB-month, before the account's free storage allowance | $0.50 |
| Private image storage, operations and outbound traffic | Planning allowance for the stated small workload; verify Mumbai storage and destination-specific egress SKUs | $1.00 |
| Secret Manager | Six versions x approximately $0.06/month, before free versions/access allowance | $0.36 |
| Metadata logs | Planning allowance; review actual account free allocation | $0.50 |
| **Planning subtotal** | Conservative workload estimate; not a provider quote or maximum | **$7.54** |
| **Proposed monthly approval threshold** | Rounded contingency | **$10.00** |

The conservative Cloud Run unit rates above are planning assumptions, not quoted Mumbai SKUs. Published reference request-based rates are $0.000024/CPU-second, $0.0000025/GiB-second and $0.40/million requests; regional pricing varies. Reconcile the estimate with the selected billing currency/region in the provider calculator before actual provisioning.

Cloud Run, Cloud Build, Artifact Registry and Secret Manager offer account-level allowances. This estimate does not assume those remain unused by other projects. Supabase stays on Free; paid upgrade is a separate decision. Firebase email/Google auth is used without phone/SMS or Identity Platform upgrades. GitHub Actions minutes/storage must also be checked against the private repository's remaining included allocation; CI cost is not included in this Google Cloud subtotal.

## Approval and controls

Owner must approve the configuration, monthly amount/currency, billing owner and provider terms before gates are enabled. Set budget alerts at 50%, 80% and 100%; alerts and max-instance limits are **not spending hard caps**. If spend rises unexpectedly, disable deployment and stop development services while investigating. Images/objects are synthetic; preserve wanted fixtures before preview expiry. Apply artifact cleanup and a private bucket lifecycle before hosting.

The upper spend is not bounded by this estimate: continuous requests, repeated builds, egress or retention growth can exceed it. No paid model service, production availability promise or 100-user release benchmark is implied by this development sizing.

Primary pricing references checked on 15 November 2026:
- [Cloud Run](https://cloud.google.com/run/pricing)
- [Cloud Build](https://cloud.google.com/build/pricing)
- [Artifact Registry](https://cloud.google.com/artifact-registry/pricing)
- [Cloud Storage](https://cloud.google.com/storage/pricing)
- [Secret Manager](https://cloud.google.com/secret-manager/pricing)
- [Supabase](https://supabase.com/pricing)
