# Interim development plan

Baseline: 15 November 2026, development day one. Four workdays: **16–19 November 2026**. Integration/rehearsal: **20–22 November**. Individual/group presentation: **23 November**. Final delivery: **April 2027**, exact date TBD.

## Status and evidence

The [shared CPM and capacity forecast](TEAM_DEPENDENCIES.md) adds cross-developer dependencies to this original baseline. Use its [GitHub delivery index](https://github.com/Tenzrr/Elora/issues/43) for current work items. On 17 November, Dev 4 PRs #39–#42 are open/in review; that does not establish a working live LLM demonstration. Other individual completion evidence has not been supplied to this planning exercise. The three-hour daily capacity scenario forecasts later readiness than the original rehearsal target; validate remaining effort and reduce the interim slice before committing to the presentation.

Requirements/report preparation is completed analysis work. October feature prototypes were removed from the development baseline. Reports retain their intentional submission-state completion wording. This tracker starts every individual deliverable as **Not started — completion evidence not yet recorded**.

Target approximately 20% of each core module; owners must map the demonstrated subset to their full SRS scope. No percentage is established by shared setup, mocks, commit counts or documentation. Dev 3–5 CNNs remain later learning/release work, not a four-day requirement.

## Deliverables

Open your four-day dependency table and longer-term milestones through the [team guide](../../WORK_DISTRIBUTION.md).

| Owner | November 16–19 deliverable | Evidence | Status |
|---|---|---|---|
| Dev 1 — Athauda K. G., `Kavee-ginty` | One tomato disease baseline; minimal upload/analysis API using shared contracts; connect inference if ready | Dataset/split manifest, held-out evaluation, limitations, prediction example | Not started |
| Dev 2 — Dulaksha Dulan, `dulakshadulan` | Citrus selection/submission and categorical result display; dataset feasibility | Working flow, response fixture, explicitly labelled samples | Not started |
| Dev 3 — Perera H.D.S, `Dimanya-Perera` | Real location-based weather and one explained advisory | Source/time, rule inputs, stale/unavailable handling | Not started |
| Dev 4 — Herath P.H.S.N, `SadeepaNHerath` | Chat UI/backend LLM response and one typed tool interface | Conversation, bounded errors, prompt boundaries; tool execution is stretch | Not started |
| Dev 5 — Sansayan K., `sansajan3103` | Authenticated create/list persisted text posts using supplied identity | Working flow and two-user ownership checks | Not started |

Dev 2 does not need CNN training solely for symmetry. Samples cannot be presented as real inference. The larger SRS demonstration and release acceptance remain beyond this interim subset.

## Dependencies and dates

Shared preparation supplies authentication, Android theme/localization, API errors, profile and plant identifiers, migrations, image validation, contracts and checks. Follow the [development setup guide](../operations/DEVELOPMENT_SETUP.md) to run FastAPI locally against your assigned Supabase workspace and the shared Firebase project. Cloud API hosting and previews are follow-up work. The team uses the shared Android tab assignments in the team guide.

| Date | Exit checkpoint |
|---|---|
| November 16 | Run shared foundation, confirm contracts, start smallest flow; Dev 1 starts training |
| November 17 | Primary behavior works locally |
| November 18 | Components connected; validation recorded |
| November 19 | Individual demonstration, focused PR, remaining work |
| November 20–21 | Reviewed integration and fixes |
| November 22 | Freeze demo scope, rehearse and record backups |
| November 23 | Combined demo and individual evaluation |

Dev 1 coordinates initial integration; Dev 3 reviews shared changes. Each owner reviews affected module contracts. PRs record requirement IDs, checks, dependencies and limitations. Change status only with implementation and demonstration/test evidence.

## Following milestones

December: core flows/persistence and initial model baselines. January: actual services/models, cross-module integration and remaining model learning work. February: remaining features and evaluation. March: feature freeze, acceptance tests, defects and documentation. April: validation, presentation and handover. Public launch separately requires every SRS release gate.
