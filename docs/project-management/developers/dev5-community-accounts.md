# Dev 5 · Community and User Accounts

**Sansayan K.** · `sansajan3103` · workspace `dev5` · Android **Community**

Own the community and account feature slice. Train the chrysanthemum disease and Bud/Open flower quality CNNs later. Work in `mobile/lib/features/community/`, `backend/app/modules/community/` and the chrysanthemum model directories under `ai/models/`. Reuse shared Firebase identity, profile and plant APIs.

## Four-day plan

For current issue IDs, cross-developer blockers and capacity, use the [Dev 5 issue map](../dev5-issue-map.md) and [common CPM](../TEAM_DEPENDENCIES.md). Dev 5 owns private diary/care logs, the shared outbox and notification preferences; coordinate task/occurrence IDs with Dev 3. The table below preserves the original four-day baseline; its technical paths do not account for one developer's limited hours.

| Task | Depends on | Planned window | Working days | Exit evidence |
| --- | --- | --- | ---: | --- |
| A · Agree on the text-post shape, owner identity and migration approach | — | Nov 16 | 1 | Create/list contract, persistence plan and authorization cases |
| B · Build authenticated create/list with persisted text in your workspace | A | Nov 17 | 1 | Stored post, stable author derived from Firebase identity and rejected unauthenticated create |
| C · Connect the Android composer and list; check two accounts | B | Nov 18 | 1 | Posts survive refresh/restart and each author is correctly recorded; submitted identity cannot impersonate anyone |
| D · Demonstrate text posting and submit one focused PR | C | Nov 19 | 1 | Working flow, migration evidence and ownership checks tied to REQ-5 |

Critical path **A → B → C → D**. Use synthetic posts in the development workspace. Keep general community exposure behind the SRS rules-acceptance and explicit-publish requirements.

## After the interim

- **December–January.** Extend the post lifecycle, previews, community rules, feeds and social controls. Coordinate diary, notifications and rewards with the relevant owners. Start local data collection for chrysanthemum stage labels.
- **February–March.** Add reporting/restricted review, privacy and account workflows, post XP, private forest, opt-in leaderboard and approved coarse-area statistics. Verify moderation, replay safety, separation from private records, and the chrysanthemum dataset/model gates.
- **April 2027.** Hand over account, community and moderation evidence and the chrysanthemum model results.

Read the [team guide](../../../WORK_DISTRIBUTION.md), [interim tracker](../INTERIM_PLAN.md), and [SRS](../../specifications/Elora_SRS.md) REQ-5 and BR-01/06/08/13.
