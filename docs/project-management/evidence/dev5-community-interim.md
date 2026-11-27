# Dev 5 — Community Interim Demo Evidence

**Issue:** #49 — Prepare demo evidence and PR
**Feature:** Private authenticated Community text drafts
**Branch:** `dev5/community-feed-v2`

## 1. Interim scope

This evidence covers the private, authenticated text-draft
implementation requested for the interim demonstration.

Public publishing, public feed access and Community Rules acceptance
are not included in this interim slice. They are deferred to the next
Community phase as clarified by D1.

## 2. Working flow evidence

### Backend
- `POST /api/v1/community/posts` creates a private draft.
- The server derives the author from the verified Firebase identity.
- The request accepts post text, not a caller-supplied owner ID.
- `GET /api/v1/community/posts` returns only the authenticated
  user's own drafts.
- Drafts have `published_at = null`.

### Android
- The Community screen provides a text composer and preview.
- Users can save a private draft.
- The user's own drafts are displayed in the list.
- Refresh and application restart persistence were manually checked.

### Manual demonstration
- Account 1 created `Dev5 private draft test - Account 1`.
- The draft remained visible after refreshing the Community screen.
- The draft remained visible after force-stopping and reopening the app.
- Account 2 initially saw no Account 1 draft and created
  `Dev5 private draft test - Account 2`.
- After switching back to Account 1, only Account 1's own draft
  was displayed.

Attach the corresponding Android screenshots to the PR.

## 3. Migration evidence

- Migration: `backend/migrations/versions/0003_community_posts.py`
- Revision: `0003`
- Parent revision: `0002`
- Creates the `app.community_posts` table and ownership relationship.
- The migration was applied in the Dev5 workspace, as confirmed by D1.
- Do not rerun this migration for the interim PR.

Attach or reference D1's migration-application confirmation in the PR.

## 4. Ownership checks and REQ-5

- Backend derives the post owner from the verified Firebase identity.
- The list query is restricted to the current user's records.
- Account 1 and Account 2 were manually checked for draft isolation.
- `test_client_cannot_spoof_post_owner` checks that a client cannot
  impersonate another post owner.
- `test_create_post_uses_server_identity_and_is_private` checks
  server-derived ownership and private draft creation.

This demonstrates the interim ownership and privacy controls relevant
to the Community requirements in REQ-5. It does not claim that the
complete public Community workflow in REQ-5 is finished.

## 5. Automated validation

- Focused backend Community tests: 5 passed.
- Full backend suite: 78 passed, 1 skipped.
- Flutter tests: 25 passed.
- `flutter analyze`: no issues found.
- Debug APK build: successful.

The PostgreSQL integration test was skipped locally because
`TEST_DATABASE_URL` was not configured. Do not point it at the shared
Dev5 workspace; the CI workflow provides a disposable PostgreSQL
test database.

## 6. PR evidence to attach

- Account 1 private draft screenshot.
- Account 1 draft after refresh.
- Account 1 draft after Android application restart.
- Account 2 private draft screenshot.
- Account 1 screen after switching back from Account 2.
- D1 confirmation that migration 0003 was applied.
- Relevant test results.

## 7. Interim completion boundary

This evidence covers private draft creation, persistence, Android
integration and author ownership isolation only.

Public publishing, Community Rules acceptance and the wider public
Community feature remain deferred to the next phase.
