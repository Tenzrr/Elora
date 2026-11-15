# Elora implementation guidance

Supporting guidance reconciled on 15 November 2026. The [finalized SRS](Elora_SRS.md) controls scope. This document neither amends it nor claims implementation. The earlier proposal is preserved in the [historical archive](../archive/README.md).

## Shared direction

- Flutter Android first; Material 3, Riverpod and GoRouter. English, Sinhala and Tamil are release requirements.
- FastAPI/Python 3.12; PostgreSQL 16/pgvector, SQLAlchemy and Alembic. Firebase owns identity; the API verifies ID tokens, active status and resource ownership. No custom password database or seven-day HS256 tokens.
- Shared identity, plant IDs, networking, navigation, localization, upload validation, schemas and migrations precede dependent features.
- Twelve server categorical models and six optional downloadable quantised disease variants for Android. Compare EfficientNetB0 with a simple baseline; follow signed manifests and matched preprocessing.
- LangChain tools, LangGraph state and redacted LangSmith evaluation. Choose generation, embedding/dimensions and speech settings through BR-09/BR-14 before freezing production configuration. Previous fixed model IDs/vector dimensions are superseded.
- Google Cloud Run API/private inference, Cloud SQL, private storage, dispatch/recovery and monitoring follow the SRS. Validate cost, service availability, terms and sizing; approve an itemized estimate before paid provisioning.

## Integration boundaries

- Implement the finalized `/api/v1` inventory; historical module-specific upload routes are not compatibility requirements.
- Shared scans use multipart `image`, crop/task/subtype context, durable asynchronous jobs, explicit abstention, versioned results and the SRS media limits. Upgrade the existing descriptive model JSON to enforceable schemas before dependent feature integration.
- Android disease packages need signed manifests/checksums, compatibility checks and atomic activation. Synchronize local results once under the original owner/operation ID, retaining on-device origin. Quality inference stays server-side; offline photos may be queued.
- Withhold disease predictions below 60% calibrated confidence and for unusable/out-of-domain inputs. Passing 60% alone does not establish domain validity. Validate quality thresholds separately.
- Use dataset-backed quality categories. Additional numeric scan outputs require REQ-2.8 evidence/approval. Farming volume, harvest and market estimates are separate reviewed methods under REQ-3.9–3.15 and BR-13, not conversions of model confidence.
- Weather freshness, regional opt-in aggregation, irrigation comparisons, crop/intercrop advice and harvest observations follow REQ-3. Missing inputs or unapproved methods produce unavailable estimates.
- Assistant voice, photos, PDF/text attachments and FAQ follow REQ-4 and BR-14. Typed writes require explicit confirmation, ownership, revision and idempotency checks. Retrieved/file content never grants tool authority.
- Accounts, diary, social controls and restricted report review follow REQ-5. Posting XP, private forest, opt-in leaderboard and regional statistics follow BR-01/BR-13. Earlier instructions forbidding all posting XP are superseded.

## Preparation and evidence

1. Finish cleanup and align shared branches.
2. Prepare shared auth/profile/plants, Android basics, migrations, networking and image validation. Each developer runs FastAPI locally with the [development Supabase/Firebase setup](../operations/DEVELOPMENT_SETUP.md). Dev 1 owns these development projects. Plan hosted API deployment, branch previews and cloud image storage separately.
3. Deliver the [four-day checkpoint](../project-management/INTERIM_PLAN.md), separately from public-release scope.
4. Complete remaining features, all twelve server/six device model variants, independent evaluation, security/load/localization and operational release gates.

Submit dataset manifests, generated schemas, model cards/metrics and focused PRs linked to requirement IDs. PERF-3/QUAL-1 numbers are provisional objectives, not achieved measurements. Follow the final SRS issues list and release checklist.
