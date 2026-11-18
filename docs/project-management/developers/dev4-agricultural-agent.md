# Dev 4 · Personalized Agricultural Agent

**Herath P.H.S.N** · `SadeepaNHerath` · workspace `dev4` · Android **Chat**

Own the assistant and its tool, retrieval and interaction boundaries. Train the rose disease and growth-stage quality CNNs later. Work in `mobile/lib/features/agricultural_agent/`, `backend/app/modules/agricultural_agent/`, `ai/agent/` and the rose model directories under `ai/models/`.

## Four-day plan

For current issue IDs, cross-developer blockers and capacity, use the [Dev 4 issue map](../dev4-issue-map.md) and [common CPM](../TEAM_DEPENDENCIES.md). Real confirmed-action integration depends on Dev 3's care service and Dev 5's care-log service; chat, interfaces and confirmation UI can proceed earlier with labelled fixtures. The table below preserves the original four-day baseline; its technical paths do not account for one developer's limited hours.

| Task | Depends on | Planned window | Working days | Exit evidence |
| --- | --- | --- | ---: | --- |
| A · Confirm development LLM access, chat contract and one read-only tool interface | — | Nov 16 | 1 | Development configuration and typed tool inputs/outputs agreed |
| B · Connect one authenticated Android text turn to a backend LLM response | A | Nov 17 | 1 | Successful turn through the app with provider settings kept on the server |
| C · Add the typed interface and verify prompt boundaries and failure handling | B | Nov 18 | 1 | Typed interface and bounded error behaviour; actual tool execution is stretch |
| D · Demonstrate a response and failure case, then submit one focused PR | C | Nov 19 | 1 | Conversation, test evidence and unexplored cases tied to REQ-4 |

Critical path **A → B → C → D**. Raise provider access problems on Nov 16. A labelled fixture can unblock UI progress while live access is resolved. Record separately whether a real model response was demonstrated.

## After the interim

- **December–January.** Add private threads, typed read tools and cited retrieval from approved sources. Coordinate plant, scan and weather interfaces with their owners. Prepare rose datasets and model baselines.
- **February–March.** Implement confirmed actions, speech, attachments and reviewed FAQ. Compare generation, embedding and speech settings using the three-language review. Verify consent, trace redaction, tool limits, replay protection and resistance to untrusted content. Evaluate the rose models separately from chat.
- **April 2027.** Hand over provider decisions, language and safety results, and rose model evidence.

Read the [team guide](../../../WORK_DISTRIBUTION.md), [interim tracker](../INTERIM_PLAN.md), and [SRS](../../specifications/Elora_SRS.md) REQ-4 and BR-05/09/14.
