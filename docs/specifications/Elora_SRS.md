Software Requirements

Specification

for

Elora

In24-S3-CM2900 - Industry Based AI Software Project

Department of Computational Mathematics

Faculty of Information Technology

University of Moratuwa

Supervisor: Dr. I.T.S. Piyatilake

Industry Partner: Xenergy

v 1.0

Prepared by Team Tenzr

15th November 2026

Perera H.D.S

245529J

Athauda K.G

245504E

Herath P.H.S.N

245514J

Wijerathna S.D.D

245547L

Sansayan K.

245536D

Table of Contents

Table of Contents .....................................................................................................................

ii

Revision History .......................................................................................................................

ii

1.   Introduction ........................................................................................................................

1

1.1   Purpose .......................................................................................................................................

1

1.2   Document Conventions ...............................................................................................................

1

1.3   Intended Audience and Reading Suggestions .............................................................................

1

1.4   Project Scope ..............................................................................................................................

1

1.5   References ...................................................................................................................................

3

2.   Overall Description ............................................................................................................

4

2.1   Product Perspective .....................................................................................................................

4

2.2   Product Features .........................................................................................................................

5

2.3   User Classes and Characteristics ................................................................................................

5

2.4   Operating Environment ...............................................................................................................

6

2.5   Design and Implementation Constraints .....................................................................................

6

2.6   User Documentation ...................................................................................................................

7

2.7   Assumptions and Dependencies .................................................................................................

7

3.   System Features ..................................................................................................................

8

3.1   Crop Health Analysis ..................................................................................................................

8

3.2   Produce Quality Assessment ......................................................................................................

9

3.3   Predictive Farming Analytics .....................................................................................................

10

3.4   Personalized Agricultural Agent .................................................................................................

12

3.5   Community and User Accounts ..................................................................................................

14

4.   External Interface Requirements .....................................................................................

17

4.1   User Interfaces ............................................................................................................................

17

4.2   Hardware Interfaces ....................................................................................................................

18

4.3   Software Interfaces .....................................................................................................................

19

4.4   Communications Interfaces ........................................................................................................

23

5.   Other Nonfunctional Requirements .................................................................................

24

5.1   Performance Requirements .........................................................................................................

24

5.2   Safety Requirements ...................................................................................................................

24

5.3   Security Requirements ................................................................................................................

25

5.4   Software Quality Attributes ........................................................................................................

25

6.   Other Requirements ...........................................................................................................

26

Appendix A: Glossary ..............................................................................................................

32

Appendix B: Analysis Models .................................................................................................

33

Appendix C: Issues List ...........................................................................................................

45

Revision History

Name

Date

Reason For Changes

Version

Team Tenzr

15 Nov 2026

Initial academic baseline, aligned with the Interim Report and agreed scope.

1.0

1. Introduction

1.1 Purpose

Version 1.0 of this SRS specifies how Elora must work and how the team will verify it. It covers the Android app, backend, twelve crop models, assistant, data storage, external services and operating procedures. The product owner approves the scope and the evidence required for public release.

1.2 Document Conventions

SHALL marks a requirement that can be tested. SHOULD marks a preference. If the team does not follow a preference, it records the reason. Implementation priorities set the order of work. All listed launch features are required.

The 99 requirement IDs consist of 70 functional requirements (REQ) and 29 nonfunctional requirements (PERF, SAFE, SEC, QUAL, DATA and OPS). Business rules (BR) specify operating limits and rules. Acceptance criteria (AC) describe how to test particular requirements.

A baseline is the starting point for development. A release gate is a check or approval that must be completed before launch.

Interfaces use ISO 8601 timestamps in UTC. The app displays local times in the Asia/Colombo time zone. Model confidence ranges from 0 to 1. This value expresses confidence in the prediction and cannot measure disease severity, quality or ripeness.

The API crop identifiers are tomato, chilli, citrus, banana, roses and chrysanthemum. The two scan tasks are disease and quality. A quality scan classifies a visible condition or growth stage supported by its dataset.

1.3 Intended Audience and Reading Suggestions

Sections 1–3 explain the scope and main features. Section 3 includes functional acceptance criteria. Sections 4–6 specify interfaces, constraints and business rules. Appendix B shows how the system works and how to trace tests to requirements. Appendix C lists the work and approvals still needed before launch. Agricultural and language reviewers check crop labels, guidance, wording about uncertainty and the three-language interface.

1.4 Project Scope

Implementation, academic assessment and public launch

The team will implement all 99 requirements. They cover five modules, six crops, twelve crop models, three languages and the operations needed for public launch. The Interim Report is the design reference. The decisions and constraints in this SRS resolve differences between its descriptions and diagrams.

The planned live academic demo starts with the agreed tomato workflow across all five modules. Expand it to show device-model download, offline disease inference and sync, forecast-based watering and harvest estimates, an irrigation simulation, crop and intercropping advice, regional alerts and statistics, harvest value and post-harvest history, voice and file inputs, and post XP, leaderboard and virtual forest updates. Use crop-specific scenarios where appropriate. Map every requirement to demo evidence, test results or an open check. Include basic execution tests for all twelve crop models and all three languages. Dr. I.T.S. Piyatilake confirmed the original tomato demo and verification record.

Public launch requires independent field validation and completion of the production readiness checks in Appendix C. Implementation starts with identity, scanning and garden records, then adds weather, the assistant, language support and community features, followed by integration and operational verification.

Core goals

Elora helps Sri Lankan growers recognise visible crop conditions, assess produce and flower stages, plan care around the weather, ask questions about their plants and record or share progress. The project aims to improve yields and reduce crop losses. Both outcomes still need to be measured.

Key capabilities

Module

Launch capability

Owner

Crop Health Analysis

Online scans and offline disease models, shared scan records, and tomato and chilli models

Dev 1

Produce Quality Assessment

Dataset-supported quality results; citrus disease and quality models

Dev 2

Predictive Farming Analytics

Forecast-based care, regional risk, water and harvest estimates, simulations, crop advice and harvest tracking

Dev 3

Personalized Agricultural Agent

Three-language text and voice, file analysis, reviewed FAQ and confirmed actions, plus rose models

Dev 4

Community and User Accounts

Accounts, diary, follows, bookmarks, sharing, report review, community XP, leaderboard, forest, statistics and chrysanthemum models

Dev 5

Each crop has two separately versioned models. Six approved disease models also have optional Android downloads for local inference. All quality scans and online disease scans use the server. Android launches in English, Sinhala and Tamil with the capabilities in section 3. iOS is planned for a later release.

Project benefits and exclusions

Elora connects scan results, care and harvest records, weather and reviewed guidance. It supports crop- and source-specific estimates with clear assumptions. The first release excludes payments, connected sensors, drones, unsupported grades or shelf-life outputs, private messaging between growers, an expert or laboratory request workflow, a separate web or desktop app and an admin portal. It includes a read-only page for shared posts and restricted report-review commands.

1.5 References

REF-1: SRS Document Template.pdf. Academic template supplied to Team Tenzr, 15 November 2026. Authority for section order, cover typography and Appendices A–C.

REF-2: Team Tenzr, Elora implementation decisions, v1.0, 15 November 2026. Supporting design rationale: https://docs.google.com/document/d/1W0kqOambAW5IrHayQyDvFIkOe418gxD6lplpsJ3c2Dg/edit?tab=t.cd5qjxozguqz . Required behavioural values are reproduced in section 6; this supporting document introduces no additional acceptance obligations.

REF-3: Team Tenzr, Elora dataset catalogue, v1.0, 15 November 2026. Supplementary search/provenance notes: https://docs.google.com/document/d/1W0kqOambAW5IrHayQyDvFIkOe418gxD6lplpsJ3c2Dg/edit?tab=t.1r6c3wb78ttf . Selected dataset names, URLs, labels and the required intake/evaluation procedure are included in section 6.

REF-4: Team Tenzr, Elora source repository and versioned API/model artifacts. https://github.com/Tenzrr/Elora . OpenAPI, schema fixtures and migrations shall conform to this SRS; repository implementation does not replace stated acceptance criteria.

REF-5: My Garden Figma and seven reference PNGs under docs/screens/ in REF-4. https://www.figma.com/design/i3Jq3mO3o724r7J8JjkKLv/My-Garden?m=dev . Visual reference; sample values are illustrative. Required screen behaviour is specified in section 4.1.

REF-6: Sri Lanka, Personal Data Protection Act No. 9 of 2022, as amended by Act No. 22 of 2025; Data Protection Authority legislation index and current commencement notice, accessed 15 November 2026. https://www.dpa.gov.lk/guidelines ; https://www.dpa.gov.lk/privacy-notice .

REF-7: Team Tenzr, shared/schemas/model_contract.json in REF-4 is the current descriptive model-contract example. Generate the OpenAPI and enforceable model validation artefacts during implementation. Section 4.3 defines the required scan and result contract.

REF-8: Google, User-generated content policy, Google Play Developer Policy, accessed 15 November 2026. https://support.google.com/googleplay/android-developer/answer/9876937?hl=en-GB .

REF-9: Google Cloud, Gemini 3.8 Flash model reference and model lifecycle, accessed 15 November 2026. https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-8-flash ; https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/model-versions .

REF-10: Plantix, official product description, accessed 15 November 2026. https://plantix.net/en/ . Product capabilities are provider descriptions, not an independent performance comparison.

REF-11: PlantVillage Nuru research, Accuracy of a Smartphone-Based Object Detection Model in Identifying Cassava Foliar Symptoms, 2020. https://pmc.ncbi.nlm.nih.gov/articles/PMC7775399/ . Published research comparator, not a claim of current universal crop coverage.

REF-12: Sri Lanka Department of Agriculture, FCRDI Plant Pathology Division service description, accessed 15 November 2026. https://doa.gov.lk/fcrdi-division-pathology/ . A reference service, not an asserted Elora partnership.

REF-13: Team Tenzr, Elora Interim Report, chapters 1 and 3–6, design reference. https://docs.google.com/document/d/12-olpE7F1eYZEHgXh0AcgxZq0KpAGZ9D8-8xQEjyVLA . Section 1.4 and Appendix C record the agreed release scope and remaining checks.

2. Overall Description

2.1 Product Perspective

Problem and industry context:

Growers need to see a scan result alongside the crop, location, previous observations and care history. A poor photo, a wrong label or unsupported advice can lead to the wrong treatment. Elora uses supported labels, explains uncertainty and keeps observations in the garden record so users can decide whether to act, retake the photo or seek specialist advice.

Project supervision and requirements

Xenergy is Elora’s industry partner. Mr. Lahiru Madushan and Mr. Aashik Ahamed are the industry supervisors, and Dr. I.T.S. Piyatilake is the academic supervisor at the University of Moratuwa.

Stakeholder consultation and scope validation

All five Team Tenzr developers, both Xenergy industry supervisors (Mr. Lahiru Madushan and Mr. Aashik Ahamed), and Dr. I.T.S. Piyatilake attended both project meetings.

15 September — Initial meeting. Team Tenzr presented its analysis of existing software. The participants discussed the core requirements and identified existing features to adopt in Elora.

22 October — Progress check-in. Team Tenzr presented the project plan, scope and feature set. The participants approved the team to proceed with implementation.

Team Tenzr held a one-on-one consultation with Dr. Ajantha de Silva, former Director General of Sri Lanka’s Department of Agriculture, and also consulted Mr. Najith Liyanage, Secretary of the Coconut Growers Association of Sri Lanka. Their feedback validated the relevance of Elora’s problem statement. The team also consulted Panilkanda Tea on specific questions, engaged with the Food and Agriculture Organization of the United Nations (FAO), and spoke with agricultural specialists and business practitioners.

Existing solutions and evaluation criteria

Plantix offers photo-based crop assessment, treatment information and a grower community (REF-10). PlantVillage Nuru research demonstrates offline recognition for a supported cassava task (REF-11). Elora runs both scan types online and supports offline disease scans using predownloaded crop models. Sri Lanka’s Department of Agriculture offers diagnostic and field services that Elora can cite when referring growers for specialist help (REF-12).

Use supported labels, language clarity, access to past records, connectivity needs and the safety of suggested next steps to compare the workflows. Sections 5 and 6 define the product verification and release checks.

Mobile client layer

The Flutter Android app supports camera and gallery inputs, optional device location, private cached records and a durable offline queue. Online scans use the backend. A downloaded and verified disease model can run on a compatible phone offline. The app has no provider secrets or direct database access.

Backend and intelligence layer

The FastAPI backend authenticates requests, checks ownership, saves records and calls the private crop-model service. The assistant uses LangChain tools and LangGraph to track conversation state. Weather advice follows reviewed rules. Each crop owner supplies two models, which use the shared scan and result formats.

Persistence and external services

Cloud SQL stores records and approved knowledge embeddings in PostgreSQL with pgvector. Private Cloud Storage holds images and model files. Firebase handles identity and messaging, and Open-Meteo provides forecasts and location search. Section 4.3 defines provider selection and service boundaries. When a provider fails, show the failure and available recovery options.

2.2 Product Features

Growers sign in, choose a language, set their crop interests and add plants. They can scan supported plant parts, review and save results, record care, check forecasts, schedule tasks and receive optional reminders. They can also ask the assistant questions, confirm proposed care actions and share posts. Growers manage training consent, blocks and account deletion. Authorised owners review reports through a restricted process.

2.3 User Classes and Characteristics

User class

Needs and authority

Grower

Manages only their own plants, scans, history, conversations and preferences. Can use the grower community. Technical and agricultural experience varies.

Public post recipient

May open the shared read-only post page; sees only intentionally public content. No private history or mutation authority.

Authorised operational owner

Restricted authenticated report review/removal/suspension and operational recovery. This authority is not granted to ordinary grower tokens or LLM tools. No admin portal.

Agronomy/language reviewer

Approves labels, guidance, terminology and evaluation artefacts. Does not automatically gain production private-data access.

Developer or integration coordinator

Uses development/staging and reviewed deployment tooling; production access follows least privilege.

2.4 Operating Environment

Hardware

The app requires an Android phone with a camera and local storage. GPS is optional. The initial cloud deployment runs crop models on CPUs. Before launch, test lower-end and mid-range phones representative of devices used in Sri Lanka. Check the camera, local storage, notifications and all three scripts, then publish the minimum Android version, RAM requirement and tested device list.

Software

Flutter stable, FastAPI/Python, PostgreSQL/pgvector, TensorFlow/Keras, Firebase and Google Cloud are the selected technology constraints in section 4.3. Exact compatible dependency versions shall be recorded in build lockfiles and the release manifest. Android target SDK and packaging shall satisfy the distribution policies applicable at submission.

Network

Sign-in refresh, server scans, new forecasts, assistant turns and community sync require internet. With an authenticated local account, growers can view cached data, add diary entries, queue photos and run disease scans without a connection if the crop model is installed. Sync resumes when the app returns to the foreground or reconnects.

2.5 Design and Implementation Constraints

Technology and integration constraints

The Flutter and FastAPI system uses twelve shared crop-model contracts. The backend serves all twelve. Android uses approved quantised variants of the six disease models for offline scans. Use PostgreSQL with pgvector and /api/v1 for the application API. Review shared changes and migrations. Sample values and mocks must never appear as real results.

Security and privacy constraints

Use managed Firebase identity and server authorisation. Private records remain private unless explicitly shared. Training use requires separate optional consent. External AI receives only necessary context. BR-04 specifies quotas; DATA-1–DATA-6 and BR-06 specify data handling. Permission refusal shall preserve manual location, gallery or other relevant alternatives where feasible.

Performance and safety constraints

Target 100 concurrent active users and 99.5% monthly application availability. Set final scan response-time targets using measurements from representative workloads. Disease/quality labels are bounded by actual validated data. Independent Sri Lankan evaluation, abstention and reviewed advice are mandatory public-release gates.

Business, distribution and regulatory constraints

Section 1.4 defines the academic demonstration and evidence. Appendix C defines the production readiness checks for public launch. Paid resources require approved spending and account ownership. Privacy notices, processing purposes, agricultural guidance and cross-border processing require review before deployment. Public community content requires report/block controls and a designated operational response process under REF-8; app-store publication remains subject to the distributor's review.

2.6 User Documentation

Documentation types

Provide user help for sign-in, taking and retaking photos, interpreting scan results, resolving offline conflicts, checking forecast age, confirming assistant actions, managing reminders, reporting or blocking users, training consent and deleting an account. Provide developer setup instructions, generated OpenAPI and model metadata, and an operations guide for deployment, rollback, backup and report review.

Delivery

Essential capture, uncertainty, consent, offline and safety help is bundled in the app in all three languages and available offline. The privacy policy, terms/community rules and detailed support information are accessible before account creation and linked from Settings. Record the published URLs in the release documentation.

Standards

Documentation shall use plain language, readable scripts and reviewed agricultural terminology. Observable outcomes shall be supported by generated API/model schemas, verification results and concise change records. Agricultural and English/Sinhala/Tamil language approvals are required before acceptance.

2.7 Assumptions and Dependencies

Assumptions

Users select the crop and supported organ; a photo may still be invalid or outside model scope. Model confidence alone does not establish an in-domain input. Weather is a location-based forecast, not measured soil state. A user can decline training consent without losing scanning access.

Dependencies

The project needs rights to use the source images, local field photos, reviewers, provider accounts and quotas, model files, tested devices and named operational contacts. The team must also collect more chrysanthemum stage photos. Section 6 records the selected datasets and the work needed to verify usage rights and model performance.

3. System Features

3.1 Crop Health Analysis

3.1.1	Description and Priority

High priority (mandatory implementation); implementation order A. Dev 1 owns the common scan workflow and the tomato/chilli disease and quality models. The disease task classifies supported visible conditions, including non-pathogen classes where the selected dataset uses them.

3.1.2	Stimulus/Response Sequences

Normal: The grower selects Tomato and Disease and takes a photo of a leaf. The server validates the photo and accepts one scan job. The app shows progress, then displays the predicted label, uncertainty and guidance. If the grower saves the result to one of their plants, it appears in that plant’s history.

Uncertain or offline: Show when a photo cannot be assessed reliably, with retake or referral guidance. Offline, use an installed model for the selected disease crop. If it is unavailable, let the grower queue the photo for the server. An offline quality photo can be queued for later. A saved local disease result stays pending until it syncs, and failures remain visible.

3.1.3	Functional Requirements

REQ-1.1: The app SHALL capture a photo or select one from the gallery, request permissions in context, and allow retry without losing unrelated work.

REQ-1.2: The system SHALL require the grower to select a crop and scan type. It SHALL explain which plant part and subtype to photograph and how to frame it. The system SHALL reject uploads that fail the format, content or size checks in section 4.3.

REQ-1.3: The server SHALL run the versioned model for online scans and persist the job and result under the shared contract. Offline disease execution SHALL use the approved local variant of the selected crop model.

REQ-1.4: The system SHALL show the label, calibrated confidence, uncertainty, model version and supported information about the condition. It SHALL clearly identify the result as a prediction from a photo.

AC-1.4: Verify separately: the primary label or abstention is valid; calibrated confidence is in 0–1 when assessed; displayed model/version matches the stored artifact; uncertainty/alternatives are labelled; and no laboratory diagnosis or unsupported severity is asserted. Every subcheck must pass.

REQ-1.5: Disease guidance SHALL use reviewed, attributed care/treatment references. Severity or a named pathogen SHALL NOT be invented from an unlabelled image property.

REQ-1.6: The system SHALL withhold a disease prediction when the calibrated score is below 60%, the photo is unusable or the input falls outside the model’s supported domain. Apply the same cutoff on server and on-device disease model variants. A score of 60% or above permits a prediction only after all other checks pass. Quality models SHALL use separately validated acceptance thresholds. Provide retake or specialist guidance when appropriate.

REQ-1.7: Users SHALL save/link results only to owned plants, view paginated filtered history, and delete their results. Unsaved photos expire under DATA-1.

REQ-1.8: Offline users SHALL be able to queue photos explicitly when a local disease model is unavailable or the requested task needs the server. The app SHALL distinguish a queued photo, a local result pending sync and a saved server record. Retries and restarts SHALL NOT create duplicates.

REQ-1.9: Production SHALL expose all six approved disease models and six quality models only after their intake/evaluation/review gates pass. No dummy probability, placeholder label or random classifier is permitted.

REQ-1.10: The Android app SHALL offer optional, per-crop downloads of the six approved quantised disease models. It SHALL verify the signed manifest, package checksum, version and device compatibility before activating a download and show the package size and offline availability.

REQ-1.11: The app SHALL save an offline disease result with its operation ID, crop, model version, execution mode, capture time and outcome. On reconnection it SHALL sync explicitly saved results once under the original account. A rejected sync SHALL remain visible and SHALL NOT silently replace the result with a server prediction.

3.2 Produce Quality Assessment

3.2.1	Description and Priority

High priority (mandatory implementation); implementation order A. Dev 2 owns quality-result presentation and the citrus disease/quality models. Other crop owners supply their quality models. Section 6 defines approved categorical outputs; flower quality is growth-stage classification. All twelve models are mandatory implementation commitments.

3.2.2	Stimulus/Response Sequences

Normal: The grower selects Citrus, Quality and Orange, then submits a fruit photo. The system returns Fresh or Spoiled if it can assess the photo reliably. It shows the uncertainty and a save option. A lime photo falls outside the validated orange category.

Unsupported estimate: If the grower asks how many days the fruit will keep, the app explains that the model classifies visible condition. It cannot estimate remaining shelf life.

3.2.3	Functional Requirements

REQ-2.1: The system SHALL execute crop-specific quality models on the server. The app SHALL allow an offline photo to be queued explicitly. Scans SHALL follow the shared input, job, source record and abstention contract.

REQ-2.2: Tomato and chilli quality SHALL use validated mappings of Unripe/Ripe/Old/Dried/Damaged; banana SHALL use Unripe/Half-ripe/Ripe/Overripe.

REQ-2.3: Citrus quality SHALL initially support orange and lemon fresh/spoiled categories, with explicit fruit subtype; unsupported citrus varieties SHALL not be advertised as validated.

REQ-2.4: Rose quality SHALL use the source's reviewed Early/Middle/Final stage definitions; chrysanthemum SHALL use Bud/Open flower after additional data and validation. The UI SHALL not silently rename these to unsupported freshness/commercial scales.

REQ-2.5: Confidence SHALL be labelled prediction confidence. The system SHALL omit unsupported quality/ripeness percentages, exact defect area, harvest dates, remaining shelf life, sugar/firmness and A/B/export grades.

REQ-2.6: Quality results SHALL save with their own task/label/version and relevant handling/growth-stage advice, not disease-specific treatment by default.

REQ-2.7: The interface SHALL state that appearance is not a food-safety guarantee, and that intended green-chilli use or cultivar differences can affect interpretation.

REQ-2.8: Additional disease severity, commercial grade, defect area or shelf-life outputs SHALL be enabled only for the crop and task covered by labelled data, an independently validated method and reviewer approval. The release SHALL show the approved condition and stage labels while these optional outputs are being evaluated.

3.3 Predictive Farming Analytics

3.3.1	Description and Priority

High priority (mandatory implementation); implementation order B, with banana model integration in order A. Dev 3 owns banana disease/quality models, forecast-informed care rules and schedules. Predictive planning does not imply a trained yield predictor or measured soil moisture.

3.3.2	Stimulus/Response Sequences

Normal: The grower opens a banana plant record and selects an area. After the forecast loads, the app explains a care suggestion based on the rain forecast. The grower can accept or edit the task and opt in to a reminder. Completing the task creates one care log.

Provider failure: If the forecast cannot refresh, show the cached forecast and its age for up to 24 hours. Stop generating new weather-based advice once the data is over two hours old. Keep the diary and tasks available and offer a retry.

3.3.3	Functional Requirements

REQ-3.1: The app SHALL let growers use device location with permission or select an area manually. Weather remains available through manual selection if GPS permission is refused. The app SHALL NOT require continuous location access.

REQ-3.2: The system SHALL show current/seven-day forecast, explicit units, selected location, forecast/retrieval times, source attribution and freshness.

REQ-3.3: Crop and growing area SHALL be required plant context. Planting date, stage, pot/ground, soil and care history SHALL be optional; recommendations SHALL explain limits of missing context.

REQ-3.4: Care recommendations SHALL use approved versioned rules and show the relevant context, forecast, action and timing. Distinguish forecasts, estimates and grower observations. Watering volumes, harvest windows and regional risk alerts SHALL follow REQ-3.9–3.11 and BR-13.

REQ-3.5: The system SHALL create/update/complete/skip/cancel plant care tasks under ownership checks and retain actual care logs separately from recommendations.

REQ-3.6: Weather responses SHALL use a 15-minute cache, visibly mark stale data and prohibit newly generated weather-dependent recommendations when forecast data is older than two hours. Cached forecasts may be displayed for at most 24 hours. BR-03 defines the units and failure behaviour.

REQ-3.7: Care reminders SHALL follow the user’s permission settings, preferences and quiet hours. The system SHALL send at most one reminder per scheduled occurrence. The in-app schedule SHALL remain available if notifications are denied or delayed.

REQ-3.8: Banana disease and quality SHALL use their approved four-class models and shared scan workflow; unsupported Fusarium/bunchy-top or shelf-life outputs SHALL not be added without data/scope review.

REQ-3.9: The system SHALL issue regional crop-risk alerts from opt-in community observations and relevant forecasts using approved aggregation rules in BR-13. Alerts SHALL identify the coarse area, crop, period and uncertainty. They SHALL NOT expose contributors, exact locations or individual reports.

REQ-3.10: The system SHALL estimate watering volume in litres per application from grower-supplied crop, stage, growing area or pot size, growing medium and a local forecast. It SHALL show the inputs and assumptions and withhold the estimate when the inputs or approved method are insufficient.

REQ-3.11: The system SHALL provide harvest windows for supported crops using reviewed crop, planting-date and growth-stage rules and relevant weather. It SHALL show a date range, its basis and uncertainty, and indicate when evidence is insufficient.

REQ-3.12: Growers SHALL be able to run an irrigation what-if comparison using valid changes to proposed timing or quantity. The system SHALL show the input changes and estimated effects using the same reviewed rules. Saving or scheduling a scenario SHALL require an explicit action.

REQ-3.13: The system SHALL suggest next crops and compatible intercrops using reviewed local season, region and growing-condition rules. It SHALL cite the relevant guidance and explain incompatible or unknown combinations.

REQ-3.14: Growers SHALL be able to create, review and manage private harvest and post-harvest observations for their plants. Records SHALL support harvest date, quantity with unit, and dated condition or storage observations. Observed changes SHALL be distinguishable from model predictions.

REQ-3.15: The system SHALL estimate harvest value using an entered or recorded quantity and a dated Sri Lankan price source with a matching crop, unit and market. Show the source, date, unit, LKR range or estimate, and assumptions. Withhold the estimate when prices or units cannot be matched.

3.4 Personalized Agricultural Agent

3.4.1	Description and Priority

High priority (mandatory implementation); implementation order B. Dev 4 owns the rose models and the three-language assistant, which uses permitted plant/scan/weather context and reviewed sources. Non-destructive care actions require explicit confirmation.

3.4.2	Stimulus/Response Sequences

Grounded question: A grower asks about yellow leaves on one of their plants. The assistant retrieves relevant history, weather and approved references. It explains possible causes and uncertainties in the selected language and may ask for a clearer photo.

Confirmed action: The assistant proposes a watering reminder and shows the plant, date and time. After the grower confirms, the server validates the request and saves the reminder once. The assistant shows the saved reminder. A retry returns the same result. Only the owner can confirm the action.

Insufficient evidence: If a source is unavailable or a dosage request lacks an approved label, explain the limitation and direct the grower to the label or a specialist. Do not guess or take an action without confirmation.

3.4.3	Functional Requirements

REQ-4.1: Users SHALL create/view/delete private threads and submit text with optional owned plant context or photo attachment. The system SHALL preserve conversational state under ownership checks.

REQ-4.2: The assistant SHALL use only authorised tools with defined input types to retrieve plant, scan and weather data. It SHALL use approved agricultural sources and credit them. It SHALL NOT execute arbitrary SQL or treat instructions in retrieved content as permission to use a tool.

AC-4.2: Test approved-source retrieval, owner-only plant/scan access with two users, rejection of cross-user IDs, a fixed typed-tool allowlist, absence of arbitrary SQL access, and resistance to instructions embedded in retrieved text. A pass requires all subcases.

REQ-4.3: Agricultural treatment recommendations SHALL cite approved sources that support the advice. When evidence is missing or conflicting, the assistant SHALL state the limitation or ask a follow-up question. It SHALL NOT invent citations or chemical recipes.

REQ-4.4: The assistant SHALL provide practical care and reviewed treatment references, directing chemical dosage/use to approved labels or specialists. It SHALL not invent dosage, mixtures or guaranteed cures.

REQ-4.5: External AI and speech services SHALL receive only the data necessary for the requested feature. Account identifiers and full gardens SHALL NOT be sent by default. Send selected media, transcripts or file excerpts only where needed and permitted by the grower’s action.

REQ-4.6: The assistant SHALL show which plant and exact details a proposed care log, reminder or permitted plant update will affect. It SHALL execute the action only after explicit, single-use confirmation. At execution, it SHALL check ownership, verify the expected record revision and prevent duplicate writes.

REQ-4.7: The system SHALL NOT execute proposals that have been cancelled, expired or changed. The assistant SHALL report whether the action was saved, failed or has an unknown outcome. Destructive actions, account actions and social publishing are excluded.

REQ-4.8: Tool/provider failure SHALL preserve the submitted turn and actual completed-action state, provide a bounded retry and prevent cross-user thread access. A turn has a 60-second backend work ceiling, at most eight tool calls and two generation retries; BR-05 defines confirmation and replay rules.

REQ-4.9: Track provider and model versions and use redacted tool outcome metadata for evaluation. The system SHALL NOT record production private prompts, photos, voice or file content in LangSmith by default.

REQ-4.10: Rose disease and stage scans SHALL use the shared crop-model workflow. The assistant SHALL NOT turn a chat photo into a diagnosis or confidence score based solely on the language model.

REQ-4.11: Before public release, select the generation model, embedding model and dimension, and speech services using the reviewed three-language benchmark in BR-09 and the media tests in BR-14. The system SHALL pin those settings, freeze the embedding configuration before building the production index and require review and reindexing if the embedding schema changes.

REQ-4.12: The Android assistant SHALL accept voice input and offer spoken replies for supported text in English, Sinhala and Tamil. It SHALL request microphone permission in context, show the transcript for correction before submission, and keep text input available when permission or speech services are unavailable.

REQ-4.13: The assistant SHALL accept owner-authorised photos and supported PDF or plain-text attachments under BR-14. It SHALL validate and safely extract content, identify the attachment used in a reply and treat extracted instructions as untrusted. It SHALL NOT grant tool access or execute actions on the basis of file content.

REQ-4.14: The assistant SHALL offer a reviewed gardening FAQ in all three languages. Entries SHALL identify their source and remain distinguishable from personalised advice.

3.5 Community and User Accounts

3.5.1	Description and Priority

High priority (mandatory implementation); implementation orders A–C. Dev 5 owns chrysanthemum models, accounts/gardens, community interactions, rewards, consent/deletion and report/block integration. All confirmed extras are required; operational owner review uses restricted tools without an admin portal.

3.5.2	Stimulus/Response Sequences

Account and diary: A verified grower adds a banana plant and records watering offline. The app marks the entry as pending. When it reconnects, the server saves one care log and one XP event if the entry qualifies. The app then updates its local record.

Community: A grower previews and publishes a post. Other growers can follow, comment or bookmark. The author can edit or delete their own post. Blocking hides each person’s posts and comments from the other while signed in and prevents interactions. Reports go to the authorised owner without revealing the reporter to the person reported.

Deletion: The grower signs in again and confirms account deletion. The system disables access and cancels pending jobs immediately. It deletes active account data within 30 days and expires backup copies within a further 30 days. If a backup is restored, the system suppresses deleted data before reopening service.

3.5.3	Functional Requirements

REQ-5.1: Users SHALL register/sign in with email/password or Google through Firebase, verify email, recover access and explicitly link identities securely. Matching email alone SHALL not merge accounts.

REQ-5.2: The backend SHALL authorize private records by verified identity and active account state. Users SHALL view/edit their profile/language/interests and manage all six supported crop types.

REQ-5.3: Users SHALL create/view/edit/delete owned plants with required crop/growing area and optional care context, and record notes/photos/watering/fertilizer/pruning logs.

REQ-5.4: Offline users SHALL view cached records, capture pending diary entries and scans, and save eligible local disease results for later sync. Apply the image and pending-operation limits in BR-02 and BR-12. Sync under the original account and surface conflicts without discarding work.

REQ-5.5: Public posts SHALL require an explicit publish action and preview. Saving a private scan/log SHALL not publish it. Posts support text, crop tags and validated photos with metadata stripped.

REQ-5.6: For You SHALL rank recent posts matching selected interests/garden crops, then other recent posts; Following SHALL show followed authors in reverse chronological order. Both SHALL use stable cursor pagination and filter blocked/unavailable content; no recommendation model is required.

REQ-5.7: Users SHALL create/edit/delete their posts/comments, like/unlike once per post, follow/unfollow, bookmark/unbookmark and retrieve private bookmarks. Uniqueness constraints SHALL prevent duplicates.

AC-5.7: Test creating, editing and deleting owned posts and comments. Check that each user can like a post only once, that follow and unfollow work, and that bookmarks remain private. Verify visibility after blocking or deletion and reject attempts to modify another user’s content. Record a pass or fail for each endpoint operation.

REQ-5.8: Sharing SHALL use a public-post link/read-only page without exposing private records. Deleted/removed posts SHALL become unavailable. The UI SHALL explain that public content can be copied or viewed without a signed-in identity.

REQ-5.9: Blocking SHALL hide each party's posts/comments from the other authenticated party, remove follows in both directions and prevent new comments/likes/follows between them. Unblocking SHALL not restore follows. Blocks SHALL not be represented as preventing anonymous access to an otherwise public post.

AC-5.9: Check that blocking hides each person’s posts and comments from the other while signed in and rejects new interactions. Check that follows are removed in both directions and stay removed after unblocking. Verify the notice that an otherwise public post remains accessible to anonymous visitors.

REQ-5.10: Users SHALL report a post, comment or user in-app with a reason and optional details, and receive an acknowledgement. The system SHALL protect reporter identity from the reported user and prevent duplicate/spam report submissions.

REQ-5.11: A designated operational owner SHALL review reports, record outcome/reason, remove content or suspend an account where appropriate, and provide a published support/appeal route. Restricted reviewed CLI/runbook operations are sufficient; ordinary API users and the LLM SHALL have no review authority. Acknowledge reports immediately, target owner triage within 24 hours, and escalate urgent safety issues promptly under the runbook.

AC-5.11: Verify reporter confidentiality, restricted owner access, acknowledgement and overdue-triage handling, removal from every feed/bookmark/share view, suspension enforcement, actor/time/reason audit and a reachable support/appeal route. Use synthetic reports for tests.

REQ-5.12: Users SHALL accept the published community rules before posting. The system SHALL enforce removals and suspensions across feeds, comments, bookmarks and public share links. Operations SHALL keep the minimum audit records required by the retention policy.

REQ-5.13: The system SHALL award XP and badges for eligible care, plant milestones and qualifying posts under BR-01. Replay SHALL NOT award points twice. Likes, comments and follows SHALL NOT earn XP.

REQ-5.14: Users SHALL configure notifications and see pending care in-app regardless of push permission. Server jobs SHALL suppress cancelled/completed/duplicate reminders.

REQ-5.15: English, Sinhala and Tamil SHALL cover core workflows, validation/errors, notifications, supported-label descriptions, help and understandable agricultural guidance, with reviewer approval.

AC-5.15: Run the same capture/save/care/chat/community/consent/deletion journeys in English, Sinhala and Tamil; separately check errors, notification text, source-linked agricultural terminology, accessibility and script clipping. Record reviewer approval for each language.

REQ-5.16: Optional training consent SHALL be separate from operational scanning/public sharing. Refusing or withdrawing consent SHALL not block scanning; withdrawal SHALL stop future training selection and follow DATA-3.

REQ-5.17: Users SHALL be able to save, retrieve and delete their own scans and request an authorised account data export. Retention and download expiry SHALL follow DATA-1 and DATA-4.

REQ-5.18: The system SHALL require recent reauthentication for account deletion and provide a request ID, status or support receipt. It SHALL follow the access and deletion deadlines in DATA-2 and prevent deleted data from reappearing after a restore under DATA-6.

REQ-5.19: Chrysanthemum disease and Bud/Open flower models SHALL use approved data, added local stage annotations and the common inference/evaluation workflow. Insufficient data SHALL not be disguised as a completed model.

AC-5.19: Verify both chrysanthemum task contracts, approved leaf-condition and Bud/Open flower labels, permitted local stage annotations, independent field metrics and abstention behaviour. Passing another crop model does not satisfy this requirement.

REQ-5.20: The system SHALL award capped XP for eligible community posts under BR-01. It SHALL grant at most one award per qualifying post and reverse the award when the post is deleted or removed.

REQ-5.21: The system SHALL display a private virtual forest based on the grower’s earned milestones and an opt-in leaderboard based on eligible XP. The leaderboard SHALL omit blocked, suspended or withdrawn accounts as applicable and expose only a chosen display name and public score.

REQ-5.22: The community SHALL show coarse-area crop statistics derived from opt-in observations only where aggregation and privacy checks in BR-13 pass. It SHALL suppress small groups and exclude removed or withdrawn inputs.

4. External Interface Requirements

4.1 User Interfaces

Primary screens and required outcomes

Interface

Required content/action

Onboarding and settings

Choose a language, sign in by email or Google, verify or recover an account, manage consent and preferences, and delete the account after signing in again.

My Garden / crop block

Dynamic crop blocks for all six crops, selected plants and condition summaries; empty-garden add-plant action. The five illustrated blocks are not a five-crop limit.

Plant detail / diary

Show the photo, crop, growing area, optional plant details, saved scans, care history and upcoming tasks. Mark work that is pending offline.

Scan camera / gallery

Crop, scan type and required plant part. Provide framing guidance and permission alternatives. Allow capture, upload or explicit queuing.

Scan result

Supported categorical label or abstention, uncertainty, model version, approved relevant guidance, save/retake action. Never show invented severity/quality numbers.

Weather / care

Show current conditions and the seven-day forecast with units, location and forecast age. Explain care recommendations and let users manage their schedule.

Assistant

Accept text and photo messages, show relevant sources, preview actions for confirmation and show whether each action succeeded, failed or has an unknown outcome.

Community

Browse For You and Following. Create and tag posts, like, comment, follow, bookmark, share, report and block.

Pending work and notifications

Show queued work and let growers retry, discard or resolve conflicts. Show reminder preferences and due care tasks.

UI/UX principles

Use the approved cream, leaf green and deep green design with Material 3. Explain loading, empty results, invalid input, denied permissions, offline mode and failures in plain language. Preserve entered work and offer a retry when appropriate. Provide screen-reader labels, scalable text, adequate contrast and touch targets. Use text or icons as well as colour to communicate status. Show “saved” or “posted” only after the server confirms it. Show locally queued work as “pending”. A separate mock-up is optional for each state.

Screen references

Follow the seven visual references in REF-5 while supporting all six crops, three languages, uncertain scan results, reporting and offline status. The illustrated XP, labels, recovery text and crop counts are examples. The behaviour specified in section 4.1 takes precedence.

4.2 Hardware Interfaces

Input

Use OS camera, gallery, touch/keyboard and optional foreground device location. Request permissions when needed with purpose text. Support hardware-dependent flash/flip only when available. Do not require continuous/background location.

Output

Use the phone display, assistive technology and optional Android notifications. Notifications must not expose exact location, private scan diagnoses or chat text on a lock screen by default.

Network

Use the device’s HTTPS networking and keep the same operation ID when retrying. Detect a dropped connection and recover when it returns. Use the actual request result to decide whether to queue or retry.

4.3 Software Interfaces

API contract

The table lists the required API routes. Define the OpenAPI request and response schemas and test fixtures before implementing each route group. IDs are opaque UUIDs. List routes use cursor pagination, with 20 items by default and 100 at most. Routes require authentication except health checks, provider-managed verification and recovery, supported public model metadata and the read-only share page. Check access to each resource, even when the caller knows its UUID.

Route group

Required operations under /api/v1

Profile/identity

POST /session verifies Firebase token and upserts profile; GET/PATCH /profile; PUT /profile/consents; POST /profile/exports creates export job and GET /profile/exports/{id} retrieves its status; DELETE /profile returns deletion request ID; Firebase SDK owns sign-in/register/reset/linking.

Plants

GET /plants and POST /plants; GET/PATCH/DELETE /plants/{id}; GET/POST /plants/{id}/logs; PATCH/DELETE /plants/{id}/logs/{log_id} with revision checks where applicable.

Models/scans

GET /models and GET /models/{id}/download for approved offline packages. POST /scans submits a server scan. GET /scans/{id} returns status or result. POST /scans/offline-results syncs a saved local disease result. GET /scans lists owned results, PATCH /scans/{id} saves or links a result, and DELETE /scans/{id} deletes it.

Weather/care

GET /locations/search, GET /weather, GET /plants/{id}/recommendations, GET/POST /plants/{id}/care-tasks and PATCH/DELETE /care-tasks/{id}. POST /plants/{id}/advisory runs a typed estimate or scenario. GET/POST /plants/{id}/harvests and GET/PATCH/DELETE /harvests/{id} manage harvest records. Use GET/POST /harvests/{id}/observations and PATCH/DELETE /harvests/{id}/observations/{observation_id} for dated observations. GET /regional/alerts lists coarse-area alerts.

Assistant

GET/POST /threads, GET/DELETE /threads/{id}, GET/POST /threads/{id}/messages, POST /threads/{id}/attachments and POST /threads/{id}/transcriptions. GET /threads/{id}/messages/{message_id}/audio returns an authorised spoken reply when available. GET /assistant/faq returns reviewed entries. POST /agent-actions/{id}/confirm or /cancel controls an owned action.

Community

GET /community/feed?tab={tab} (tab is for-you or following); GET/POST /community/posts; GET/PATCH/DELETE /community/posts/{id}; GET/POST /community/posts/{id}/comments; PATCH/DELETE /community/comments/{id}; PUT/DELETE /community/posts/{id}/like; PUT/DELETE /community/posts/{id}/bookmark; GET /community/bookmarks.

Social/safety

PUT/DELETE /community/users/{id}/follow; PUT/DELETE /community/users/{id}/block; GET /community/blocks; POST /community/reports targeting a user/post/comment; GET /community/rules. No ordinary user endpoint grants review/removal of others' content.

Devices/rewards

PUT/DELETE /devices/{id} for FCM, GET/PATCH /notification-preferences, GET /rewards for XP, level, badges and forest, GET /rewards/leaderboard and PUT /rewards/leaderboard-preference. GET /regional/statistics returns eligible aggregates.

Public sharing

Outside API prefix: GET /p/{share_token} minimal read-only HTML; missing/removed content returns unavailable. Share token is not a private-record access token.

Use the shared /scans contract for all twelve models. Crop owners maintain the individual models. Update OpenAPI, shared schemas and generated clients together when the API changes.

Database interface and entities

Only authorised backend services connect to PostgreSQL. Use migrations, ownership foreign keys, unique operation keys and indexes. Store Firebase-linked profiles, plants and care records, scan jobs and results, approved model packages, assets and consent, forecasts and advisory records, harvest observations, regional aggregates, notifications, assistant conversations and actions, approved knowledge embeddings, community interactions and reviews, rewards and leaderboard preferences, and deletion records. Elora stores no passwords. Appendix B defines ownership and key relationships.

External APIs

Firebase Auth and FCM provide identity and notifications. Use private object storage and redacted evaluation. Select and approve an Open-Meteo plan before public launch under ISS-06. Select generation, embeddings and speech services through BR-09 and BR-14. Keep provider secrets in Secret Manager. Failure of weather or assistant services must leave scan history and diary available.

Model, image and mobile OS interfaces

POST /scans accepts multipart field image, crop_slug, task, optional plant_id and supported subtype where required. Accept decoded JPEG/PNG/WebP, maximum 10 MiB and 20 megapixels; verify magic bytes, decode safely, correct orientation, strip metadata and reject malformed/decompression-bomb inputs. Android may convert other camera formats before upload.

Create a durable scan job and return 202 with job ID/status URL. Status is queued, running, completed or failed. “Completed” means a result exists and may be assessed or unable_to_assess; abstention is not a transport failure. Retries reference the same idempotent job. Poll with bounded backoff from 2 to 10 seconds; support foreground resume.

An assessed result contains scan_id, crop_slug, task, model_id, model_version, label_id, localised display label, calibrated confidence, up to three top_predictions, assessed_at, uncertainty/warnings, and relevant guidance with source references. unable_to_assess uses a null primary label/confidence and a reason such as unsupported organ/domain, poor image or insufficient calibrated certainty. Do not turn top alternatives into asserted diagnoses.

Use the dataset-supported visual labels in section 6. Additional scan metrics require the evidence in REQ-2.8. A crop image cannot confirm a laboratory diagnosis. Growth and harvest forecasts use the separate farming rules.

A model manifest specifies crop/task, organ/subtypes, labels and mappings, source/version/rights, input resolution/colour/resize/normalisation, output interpretation, calibration/thresholds/domain rejection, file checksum, framework version and evaluation card. Training and serving preprocessing must match exactly. For Keras EfficientNet, document built-in rescaling and avoid double normalisation.

For an offline model download, GET /models/{id}/download returns signed manifest and package download details for an approved Android variant. POST /scans/offline-results accepts an operation UUID, model release ID, crop, capture time, outcome, and optional permitted image and plant references. The server checks owner, operation uniqueness, model status and contract validity. It saves the origin as on_device and treats the prediction as a client-originated record. Repeating an identical operation returns its existing record. A conflicting payload returns 409. A rejected sync must leave a visible reason and recovery option. Server results use the origin server.

Validate model inputs and results using JSON Schema and Pydantic. Provide contract fixtures for all twelve models, including abstention and failure. Update the existing descriptive JSON so it can validate data before production integration.

Selected software components and provider responsibilities

Area

Selected baseline

Reason / implementation boundary

Mobile

Flutter stable / Dart, Material 3, Riverpod, GoRouter

Choose compatible stable SDK and package versions at project setup and commit the lockfiles.

Mobile integrations

Firebase Auth, FCM; official Flutter camera and image picker; SQLite local store; Android WorkManager integration

Use camera preview for the specified viewfinder and gallery picker for existing photos. Persist the offline outbox; background execution is best effort and foreground resume must work.

Localization

Flutter ARB resources, flutter_localizations / intl; bundled licensed Sinhala/Tamil-compatible fonts

Human-review all three languages; language selection is explicit and retained. Never rely only on runtime machine translation for controls or safety notices.

API

Python 3.12, FastAPI, Pydantic 2, SQLAlchemy 2, Alembic, HTTPX

One modular backend, typed contracts, migrations and integration tests. Validate dependency compatibility in the build before pinning exact versions.

Database

Managed PostgreSQL 16, pgvector, Cloud SQL

Relational ownership, social uniqueness constraints, JSON model metadata and semantic retrieval in one database. No separate vector service or Firestore product store.

Crop models

TensorFlow/Keras for twelve server models, with quantised TensorFlow Lite disease variants for Android

Compare EfficientNetB0 with a simple baseline and calibrate the chosen model. Change architecture only if evaluation supports the change. Package and independently evaluate approved quantised disease variants for offline Android inference.

Assistant

Generation and speech providers selected through the language, safety, cost and latency benchmark

Use only the provider configurations approved under BR-09 and BR-14. Keep the selection configurable and record the actual provider and model with each evaluated response.

Retrieval

Embedding model, dimensions, normalisation and distance metric selected under BR-09. Store approved vectors in pgvector.

Use reviewed text. Freeze the index schema before production and reindex on any approved schema change.

Agent orchestration

LangChain tools/retrieval, LangGraph with PostgreSQL checkpoints, LangSmith evaluation

Backend executes typed actions; the LLM has no database credentials or arbitrary SQL tool. Production LangSmith content tracing disabled by default.

Hosting

Google Cloud Run API and private inference service; Cloud SQL; Cloud Storage; Secret Manager; Artefact Registry

Managed deployment and one provider for most infrastructure. Two services isolate inference load without creating twelve model microservices. No Kubernetes, Redis or Celery baseline.

Job dispatch and scheduling

Cloud Tasks for immediate authenticated scan-job dispatch; Cloud Scheduler invokes an internal worker every minute; PostgreSQL job state

Tasks invoke inference promptly; Scheduler recovers missed dispatch and handles care reminders, retries, expiry and deletion. Claim rows atomically, use leases and idempotent processing.

Notifications

Firebase Cloud Messaging and Android local display

FCM delivery is best effort. In-app care schedules remain the source of truth; duplicate suppression and preferences belong to Elora.

Weather/location

Open-Meteo paid customer API; Open-Meteo geocoding / GeoNames attribution

Confirm the production licence and quota before launch; do not build a public launch on the free noncommercial endpoint. Local area selection remains available if GPS is denied.

Delivery/ops

GitHub Actions, Docker, Terraform, Cloud Logging/Monitoring

Run pull request checks and document infrastructure setup. Use workload identity in place of long-lived service account keys. Require approval and a rollback procedure for production deployments.

4.4 Communications Interfaces

HTTP/HTTPS

Production uses TLS 1.2+ through managed endpoints and HTTPS object access. JSON is UTF-8. Mobile APIs accept Authorisation: Bearer <Firebase ID token>, locale, request ID and idempotency key where relevant. Public /health reveals no secrets; private readiness confirms DB and required model/service configuration.

Asynchronous communications

Scan jobs and offline operations are asynchronous. Cloud Tasks dispatches accepted scan jobs promptly to an authenticated worker; PostgreSQL records job state/leases and Scheduler reconciles missed dispatch. Chat uses a complete-response HTTP contract initially; no WebSocket or SSE implementation is required. FCM carries opaque reminder identifiers, and the app fetches authorised details. Process restarts must not lose accepted jobs. Worker routes are authenticated internal operations, not grower APIs.

Data formats and errors

Use { "error": { "code": "...", "message": "...", "details": {} }, "request_id": "..." }. Map invalid input to 400/422, unauthorised to 401, forbidden to 403, missing to 404, revision/idempotency conflict to 409, oversized upload to 413, unsupported media to 415, quota to 429 and temporary dependency failure to 503. Do not return stack traces. Use explicit units. A stable idempotency key is scoped to user/operation for seven days; same key/payload returns the existing outcome, different payload returns 409. Domain constraints also prevent duplicate likes/XP/care occurrences after expiry.

Security protocols

Firebase manages credentials and linking; backend checks revocation/inactive status, resource ownership and scope for every request. Use IAM service identities between cloud components, least privilege and encrypted database transport. No custom seven-day bearer token scheme, provider key in Flutter, model-supplied SQL or unconfirmed agent mutation is permitted.

5. Other Nonfunctional Requirements

5.1 Performance Requirements

PERF-1: The system SHALL support 100 concurrent active users under a published realistic workload, not assume 100 simultaneous model executions. Initial load test: 30 minutes, 100 sessions, 5 aggregate ordinary API requests/second, 10 scans/minute and 6 assistant turns/minute; use a representative class/crop mix and record quotas/resource configuration.

PERF-2: Under the workload in PERF-1, ordinary CRUD endpoints that do not call external providers SHALL have a server p95 response time of at most one second and an unexpected 5xx rate below 1%. Exclude intentional 4xx responses and time on the client network. Record database saturation and queue growth.

PERF-3: The provisional planning objectives are p95 server inference at most 3 seconds per warmed model and p95 capture-submit-to-rendered-result at most 15 seconds for JPEG input up to 2 MiB, upload bandwidth at least 5 Mbps and round-trip latency at most 150 ms under PERF-1's workload. The benchmark SHALL measure all twelve models, upload/queue/inference/render times, p50/p95/p99 and cold starts separately. These are unmeasured objectives, not achieved results; ISS-04 governs evidence-based ratification or revision before acceptance.

PERF-4: Chat SHALL stop backend work at the 60-second limit and show a recoverable error rather than loading indefinitely. Provider evaluation SHALL record p95 end-to-end latency, time spent in each tool and output cost across all three languages. When a quota is exhausted, the system SHALL tell the user how to recover.

PERF-5: Resource, concurrency and user quotas SHALL be explicit and load-tested. Accepted scan jobs SHALL remain durable across process restarts; sustained overload SHALL produce bounded queueing/rejection rather than unbounded memory growth. A failed benchmark requires resizing/optimization/retest.

5.2 Safety Requirements

Physical/agricultural safety

SAFE-1: Advice SHALL state relevant uncertainty, avoid guaranteed diagnosis/cure and distinguish visual predictions, forecast estimates and measured facts. Reviewer checks cover every supported label and three-language safety notices.

SAFE-2: Chemical dosage/mixing instructions SHALL not be generated without approved label authority; the launch flow SHALL refer to approved labels/specialists. Unsafe or unsupported advice test cases must be rejected/limited.

SAFE-3: Freshness/ripeness/bloom categories SHALL not be presented as food-safety certification or unsupported numerical quality/shelf-life outputs.

Operational safety

SAFE-4: The system SHALL independently test both deployment variants on unseen local field images and unsupported inputs. Calibrate scores and assess the fixed 60% disease cutoff. Do not substitute a different disease cutoff without an approved change to this SRS. Select quality thresholds on validation data and freeze them before independent testing. Report per-class errors, score calibration, abstention coverage and unsupported-input acceptance.

SAFE-5: Unconfirmed assistant actions, repeated requests, worker retries and offline replay SHALL not cause duplicate care actions, posts, XP or notifications. Verify concurrent/replayed requests and interrupted responses.

5.3 Security Requirements

SEC-1: The backend SHALL verify Firebase identity and check that the account is active and its token has not been revoked. Check ownership and public visibility on every resource and grant services and operators only the permissions they need. Test isolation between two users across stored objects, chat, scans, exports, shared posts, blocks and confirmation actions.

SEC-2: The system SHALL encrypt data in transit and at rest and use Secret Manager for credentials. Do not commit credentials or include provider keys in the app. Test log and trace redaction, private storage buckets and authorisation for uploads and downloads.

SEC-3: The system SHALL validate input and media, enforce quotas, reject arbitrary object URLs and prevent injected instructions from authorising tool calls. Use parameterised database queries. Run dependency scans, secret scans and relevant security tests. Fix exploitable high or critical findings before launch.

SEC-4: Sensitive account actions SHALL require recent reauthentication. Report review/deployment access SHALL be separately authorized and audited. Deleted/suspended users SHALL be blocked even if a previously issued token has not expired.

5.4 Software Quality Attributes

QUAL-1: All twelve server models and six Android disease variants SHALL undergo section 6's grouped-original intake and independent Sri Lankan testing. Provisional objectives are full supported-class macro-F1 at least 0.85, per-class recall at least 0.80, accepted-prediction precision at least 0.90, in-domain acceptance coverage at least 0.70, 10-bin expected calibration error at most 0.10, and unsupported-input false acceptance at most 0.10 on at least 100 challenge images per model. Report sample counts and 95% uncertainty intervals. Assess the fixed 60% disease cutoff. Choose quality thresholds on validation data and freeze all configurations before independent testing and agronomy approval; ISS-03 records ratification or justified revision, not a claim that these values are achieved.

QUAL-2: Core workflows SHALL pass tests in English, Sinhala and Tamil. Check for clipped characters, inaccessible controls and blocked recovery steps. Start testing with a representative 3 GB RAM phone running Android 10 (API 29) and include newer devices and Android versions. Test the camera, offline cache and queue, permissions and notifications. Use the results to publish the minimum supported version and device characteristics under ISS-05.

QUAL-3: API/model contracts SHALL be machine-validated, documented in generated OpenAPI/JSON Schema and exercised by consumer fixtures. Shared schema/database changes require review/migration and compatible integration.

QUAL-4: The system SHALL show whether an accepted item is saved on the server or pending on the device. It SHALL recover that state after a network failure or restart. Tests SHALL cover empty data, invalid input, denied permissions, offline mode, failures, retries and conflicts.

Reliability, availability and operational acceptance

OPS-1: The system SHALL target 99.5% monthly availability over a 30-day period, allowing about 3 hours and 36 minutes of downtime. Monitor the signed-in API, profile and scan acceptance paths. Count planned downtime and dependency failures that affect these paths. Report degraded assistant and forecast service separately from core application availability.

OPS-2: Recovery point and recovery time objectives SHALL each be at most 24 hours after a serious incident. Daily backup and a prelaunch restore drill SHALL demonstrate database/object recovery and deletion suppression, with quarterly repetition.

OPS-3: Before launch, operations SHALL have approved budget/accounts, secrets, monitoring, alerts, named response/report-review contacts, runbooks, support/appeal contact, deployment/rollback procedure and tested production-like configuration. No requirement implies a purchased provider plan or a provider SLA.

OPS-4: Release artifacts SHALL identify app/API versions, dependencies, migrations, all twelve model checksums/labels/thresholds, knowledge/rule versions, provider/model configuration and evaluation approvals. Rollback SHALL preserve compatible data/contracts or include a tested recovery migration.

OPS-5: The team SHALL announce a public release date only after all Appendix C checks pass. Missing data, failed model checks, unresolved policy or privacy issues, absent reviewers and unapproved spending block launch.

6. Other Requirements

Data, privacy and retention requirements

DATA-1: Saved scans/photos and associated owned records SHALL persist until user deletion. Unsaved scan photos SHALL be removed after 30 days; unsaved result metadata SHALL expire with them. Saved means an explicit retained record, not merely a completed temporary job.

DATA-2: Account deletion SHALL disable access immediately, remove active account/private garden/photos/chat/public posts/comments and linked social relationships within 30 days, and expire remaining backup copies within a further 30 days. Deletion status/receipt SHALL be available through the support process without reactivating the account. Narrow required exceptions must be documented/disclosed.

DATA-3: The system SHALL record the purpose, version, timestamp and withdrawal status of training consent. Exclude photos without consent from training exports. When a user withdraws consent or deletes an account, remove identifiable source copies from future training sets within the active-data deletion deadline. Tell users that deletion does not automatically remove an image’s influence from a trained model. Assess requests for removal or retraining where warranted.

DATA-4: Account export SHALL provide an authorized JSON archive/index and short-lived links for owned stored photos, with no other users' private data. The asynchronous export job SHALL expire downloads after 24 hours. Training consent/public sharing/operational processing SHALL remain distinct.

DATA-5: The system SHALL apply the logging, tracing and backup retention rules in BR-06 within the deletion limits in DATA-2. Keep exact location only when necessary and exclude it from public posts by default. Strip EXIF from images. Record reuse rights and attribution for knowledge sources and datasets.

DATA-6: The system SHALL suppress deleted content before returning a restored backup to service. Keep a minimal deletion record with restricted access until all affected backups expire. Then remove the link to the user unless a disclosed exception applies. Test deletion in active storage, older object versions and restored storage.

Internationalization and documentation

The launch shall support English, Sinhala and Tamil across core workflows, validation, notifications, reviewed label descriptions and essential help. Use retained language selection, reviewed ARB resources and fonts that render all three scripts. Bundle capture, uncertainty, consent and offline help. Agricultural and language approval is a release gate.

Dataset selection and licensing

Section 6 lists a starting dataset for each of the twelve crop and task combinations. DS- identifies a dataset and REF- identifies a reference. Verify usage rights and apply the intake and evaluation rules below before using a source in production. The chrysanthemum stage dataset has only enough material to start the work, so the team must collect local images.

tomato-disease — DS-TOM-DIS. Dataset: Tomato Leaf Disease Classification Dataset in Pakistan, v2. Source: https://data.mendeley.com/datasets/3mbnb82mxd/2 . Supported labels: Early blight, late blight, Septoria leaf spot, leaf mold, yellow leaf curl virus, healthy. Dev 1; leaf input; source reports 7,200 images; CC BY 4.0 declared.

tomato-quality — DS-VEG-Q. Dataset: VegNet, v1, tomato subset. Source: https://data.mendeley.com/datasets/6nxnjbn9w6/1 . Supported labels: Unripe, ripe, old, dried, damaged. Dev 1; fruit input; crop-filter the shared collection; CC BY 4.0 declared.

chilli-disease — DS-CHI-DIS. Dataset: Chilli leaf collection (tm3v4zmh7c), v1. Source: https://data.mendeley.com/datasets/tm3v4zmh7c/1 . Supported labels: Bacterial spot, Cercospora leaf spot, curl virus, healthy leaf, nutrient deficiency, powdery mildew. Dev 1; leaf input; nutrient deficiency is a visual condition, not a measured nutrient diagnosis; CC BY 4.0 declared.

chilli-quality — DS-VEG-Q. Dataset: VegNet, v1, chili-pepper subset. Source: https://data.mendeley.com/datasets/6nxnjbn9w6/1 . Supported labels: Unripe, ripe, old, dried, damaged. Dev 1; fruit input; green chilli may be intentionally harvested green; CC BY 4.0 declared.

citrus-disease — DS-CIT-DIS. Dataset: Citrus leaves, TFDS curated four-class subset of original v2. Source: https://www.tensorflow.org/datasets/catalog/citrus_leaves . Supported labels: Black spot, canker, greening, healthy. Dev 2; 594 curated leaf images reported; original: https://data.mendeley.com/datasets/3f83gxmv57/2 ; CC BY 4.0 declared; validate supported varieties.

citrus-quality — DS-FRUIT-Q. Dataset: Spoiled and fresh fruit inspection, v1, orange/lemon subsets. Source: https://data.mendeley.com/datasets/6ps7gtp2wg/1 . Supported labels: Fresh, spoiled. Dev 2; supported fruit types are orange and lemon only until further validation; CC BY 4.0 declared; appearance is not food-safety certification.

banana-disease — DS-BAN-DIS. Dataset: BananaLSD, v1. Source: https://data.mendeley.com/datasets/9tb7k297ff/1 . Supported labels: Sigatoka, Cordana, Pestalotiopsis, healthy. Dev 3; 937 originals reported; exclude augmented derivatives from independent counts; Fusarium/bunchy-top are not supported; CC BY 4.0 declared.

banana-quality — DS-BAN-RIPE. Dataset: BananaID, v1. Source: https://data.mendeley.com/datasets/h6n5srjjyw/1 . Supported labels: Unripe, half-ripe, ripe, overripe. Dev 3; 1,960 original ripeness images reported; validate Sri Lankan cultivars; CC BY 4.0 declared.

roses-disease — DS-ROS-DIS. Dataset: Rose leaf disease collection (mdtpp2cmj4), v1. Source: https://data.mendeley.com/datasets/mdtpp2cmj4/1 . Supported labels: Black spot, downy mildew, insect affected, healthy. Dev 4; 2,048 originals reported; insect affected is not a specific pest identification; CC BY 4.0 declared.

roses-quality — DS-ROS-STAGE. Dataset: High Resolution Rose Growth Stage Image Dataset, Golap Gram, v1. Source: https://data.mendeley.com/datasets/53vyvz5yyk/1 . Supported labels: Early stage, middle stage, final stage. Dev 4; 565 images reported; reviewer-defined operational meanings required; final stage must not be relabelled senescence without evidence; CC BY 4.0 declared.

chrysanthemum-disease — DS-CHR-DIS. Dataset: Chrysanthemum leaf disease collection (dmdwhx4cdd), v1. Source: https://data.mendeley.com/datasets/dmdwhx4cdd/1 . Supported labels: Bacterial leaf condition, Septoria leaf spot, healthy. Dev 5; 2,580 images reported; bacterial category requires reviewer-approved interpretation; CC BY 4.0 declared.

chrysanthemum-quality — DS-CHR-STAGE. Dataset: Flowers detection, Manasa B P, chrysanthemum objects only. Source: https://universe.roboflow.com/manasa-b-p-tooaz/flowers-detection-huslj . Publisher labels include chrysanthemum bud and chrysanthemum flower. The proposed target labels are Bud and Open flower, subject to an annotation audit and local validation. Dev 5; 190 mixed-species images reported, not 190 per chrysanthemum class; exclude star-jasmine/ambiguous boxes. CC BY 4.0 declared on project page; original provenance and added local annotations are required.

Dataset counts and licences above are publisher declarations, not archive-audit results. Training shall retain version/DOI, original attribution, rights evidence and a source-to-normalised label map. Unsupported classes, detached-petal/species-only substitutes and research-only collections shall not be silently promoted to production coverage. REF-3 supplies supplementary alternatives, while this section defines the selected scope.

Business Rules and Operating Parameters

BR-01 — XP and badges. Award 10 XP per accepted watering, fertilising or pruning entry, up to 30 XP per day across those categories. Award 20 XP for the first photo milestone per plant each week, up to 40 XP per week. Award 5 XP for an eligible, distinct published post, up to 15 posting XP per day. A post qualifies after it is published with valid content and is neither duplicate nor removed. Use Asia/Colombo dates for daily caps. Level = 1 + floor(total XP / 500). Keep the existing first-plant, first-care and seven-distinct-care-days badges. Reverse XP for a removed or deleted earning event. The private forest adds milestones from accepted events and earned badges. The opted-in leaderboard ranks current eligible XP with stable ties, excludes blocked or ineligible accounts, and hides accounts that opt out.

BR-02 — Offline persistence. Cache up to 200 MB of images. Remove synced copies when space is needed, and keep pending originals until they sync or the user discards them. Allow up to 20 queued scans and 100 pending diary entries. Warn the user before exceeding a limit. Resume sync when the app returns to the foreground or reconnects, and try in the background when possible. Recheck the account and ownership. Increase the delay between temporary failures up to 30 minutes. Ask the user to resolve validation or revision conflicts. Keep the operation UUID unique for that user on the created record, even after the seven-day response cache expires. Never sync one user’s queue under another account.

BR-03 — Weather and notifications. Cache forecasts for 15 minutes; visibly display stale cache for at most 24 hours and prohibit new weather-dependent recommendations after two hours. Show °C, mm, km/h, humidity %, source and retrieval/forecast time. Use Asia/Colombo for displayed schedules and UTC storage. Notifications are opt-in with quiet hours 21:00–07:00; due reminders during quiet hours move to 07:00. One care occurrence creates one logical reminder; in-app schedules remain available if delivery is denied or delayed.

BR-04 — Quotas and durable scan jobs. Per user, allow up to 20 scans per hour, 100 scans per day, 30 assistant turns per hour and 10 new posts per hour. Return HTTP 429 with Retry-After when a limit is exceeded. Initially allow up to 200 queued or running scan jobs across the system. Record accepted jobs in the database, dispatch them through authenticated Cloud Tasks and check for missed dispatches. A worker has up to 120 seconds per attempt. Queued jobs expire after 15 minutes. Allow up to three attempts for temporary failures. Use atomic leases and attempt tokens to prevent duplicate processing and writes from expired attempts. PERF-3 specifies separate response-time targets.

BR-05 — Assistant and confirmation. Limit a turn to eight tool calls, two generation retries and 60 seconds of backend work. Use only authorised tools with defined inputs and approved sources. Retrieve up to five references filtered by crop and language, using a relevance threshold set through validation. Each proposed write records the user, plant, exact parameters and record revision. Confirmation works once, expires after ten minutes and becomes invalid if the parameters change. The assistant can write care logs, reminders and permitted plant updates. It cannot delete accounts or publish posts. If an outcome is unknown, retry using the same operation ID.

BR-06 — Privacy and operations. Store private assets in private buckets. Authorised links expire within 15 minutes. Strip EXIF from public photos. Keep application metadata logs for 14 days and pseudonymous security and deletion audit events for 90 days. Keep production content tracing off by default. Approved and redacted trace samples may be kept for up to seven days. Keep daily encrypted database backups for 30 days and soft-deleted objects for seven days. Apply the deletion limit in DATA-2 and the restore safeguards in DATA-6 to every copy. Test backup restoration before acceptance and quarterly after that. Check availability each minute. Aim to assess reports within 24 hours and escalate urgent cases promptly. Log removals and suspensions by the authorised owner. Review uses restricted tools without an admin portal.

BR-07 — Dataset intake. Record the source version, licence, attribution and SHA-256 file checksums. Audit at least 50 randomly selected original images per class, or all originals if fewer are available. Remove corrupt files, images of the wrong plant part and uncertain labels. Check for exact and near duplicates in copies of the dataset. Split original plant or session groups into 70% training, 15% validation and 15% internal testing. Keep each derived image with its original group and augment only the training split. If group information is unavailable, document the risk of data leakage and rely on the independent local test.

BR-08 — Independent evaluation. Use an independent Sri Lankan phone-photo protocol. The project planning floor is 50 original photos per class across at least three sites and 100 unsupported-input challenge images per model. Keep training plants and sessions out of these sets. Record actual counts and any approved changes to the test protocol. Report per-class precision, recall and F1, plus macro-F1, a confusion matrix, calibration, acceptance coverage, false acceptance of unsupported inputs, sample counts and uncertainty intervals. Fix the preprocessing, labels and calibrated thresholds before independent testing. For chrysanthemum stage training, collect at least 300 original photos per class from 30 plants across three sites. Evaluate against the provisional objectives in QUAL-1 and obtain reviewer approval before acceptance.

BR-09 — Agricultural, language and provider review. Keep source URL, title, crop, region, date, reuse rights and reviewer status for each knowledge source. Compare candidate generation and embedding combinations, including at least one alternative, using a planned set of 90 reviewed cases, 30 per language. Record the final test set and results. Check retrieval, citations, terminology, injection, unsafe treatment, confirmed actions, privacy, latency, cost and quotas. Check speech recognition and playback separately in all three languages. All prohibited chemical-prescription and unauthorised-write cases must pass. Record provider IDs, embedding dimension, normalisation, distance metric and evaluation results before building the production index.

BR-10 — Hosting and provider constraints. Begin benchmarking with Cloud Run API at 2 vCPU, 4 GiB, concurrency 20 and 1–5 instances, private inference at 2 vCPU, 8 GiB, concurrency 1 and 1–3 instances, and PostgreSQL 16 with pgvector at 2 vCPU, 8 GiB and up to five database connections per API instance. Prefer asia-south1 for supported storage and compute. Approve actual sizing, service availability, billing, quotas, and processing locations and transfers. Pin the approved provider configuration selected under BR-09. Review lifecycle notices monthly and require approval before changing providers or models.

BR-11 — Legal/privacy review. Assess applicable obligations under Sri Lanka's Personal Data Protection Act No. 9 of 2022 as amended by Act No. 22 of 2025, including purpose/lawful-basis records, notices, data requests, processor/transfer terms and incident handling. The DPA notice accessed 15 November 2026 states that specified provisions commence on 1 January 2027; commencement is not uniform for every provision. Recheck current law at deployment and record a competent compliance review. These product controls do not themselves establish statutory compliance (REF-6).

BR-12 — Offline disease models. Each model package includes a signed manifest, SHA-256 checksum, crop, model and schema version, minimum runtime, validated labels, preprocessing, size and compatibility metadata. Download with the user’s consent, verify before activation, and replace packages atomically. Offline use needs a previously authenticated local account and an available approved package. Show the installed version, update status and model size, and let growers remove a package without deleting saved scans. Keep voice, quality scans and fresh forecasts online. Local disease scans and uploads obey the existing offline storage and pending-scan limits. Sync uses the original operation ID and owner. Accept historical versions from the approved manifest history, flag revoked releases or invalid results and never run server inference on a synced result unless the grower explicitly requests a new scan.

BR-13 — Forecasts, regional signals and market estimates. Each recommendation or estimate records its inputs, source timestamps, method version, units and assumptions. Use BR-03’s forecast freshness limits. Validate regional alert thresholds, minimum distinct contributors and time windows before launch, and count at most one qualifying signal per contributor for a crop, area and window. Use district-level summaries without raw locations or identifiers. Exclude withdrawn, removed or invalid observations and suppress small groups. Agronomy reviewers approve supported crop rules and error bounds. Product and agronomy reviewers approve the price source, allowed price age, units and publishing criteria. Missing inputs, mismatched units, stale forecasts or unapproved sources yield an unavailable estimate. Harvest and volume estimates must be distinguishable from measured records.

BR-14 — Voice, FAQ and attachments. A voice turn uses push-to-record, shows an editable transcript and requires a send action. Playback can be stopped and has a text equivalent. Apply BR-05 time and retry limits to submitted messages. Use reviewed FAQ entries and cited responses. Keep attachment access private and apply minimisation and retention rules to voice and files. Accept JPEG, PNG or WebP images under section 4.3, PDF up to 10 MiB and 30 pages, and UTF-8 plain text up to 1 MiB. Reject encrypted PDFs, executable content and malformed or oversized files. Store only necessary audio long enough to transcribe and delete it after processing. Keep the saved transcript or attachment with the thread until deletion. Validate declared format against decoded content, enforce extraction limits and ignore embedded tool or system instructions.

Specification Governance

The 99 requirement IDs define the implementation baseline and academic verification record. For changes to requirements, labels, providers or acceptance criteria, record the version, reason, affected IDs and updated test evidence.

Section 4.3 specifies the required libraries and services. Adapters, deployment scripts and detailed component designs belong in the implementation. Verify the required interfaces, behaviour and measurable outcomes. Any change to a technology constraint needs approval and regression test evidence.

Appendix A: Glossary

Term

Meaning

SRS

Software Requirements Specification: required system behaviour and constraints.

CNN

Convolutional neural network. Elora uses twelve separately versioned crop image classifiers for disease and quality scans.

Grounding

Relating advice to approved evidence and authorised user context.

Abstention

Explicit decision not to provide a reliable primary label.

Calibration

Aligning prediction confidence with measured empirical correctness.

OOD

An input outside the data the model supports. A model can report high confidence on such an input.

RPO / RTO

Maximum recoverable data age / target service restoration time.

Idempotency

Repeated submission of the same operation produces one logical result.

UGC

User-generated content, including public posts/comments/photos.

Release gate

Required evidence/approval before public launch.

RAG

Retrieval-augmented generation: composing a reply using retrieved reference material.

FCM

Firebase Cloud Messaging, used for best-effort push delivery.

pgvector

PostgreSQL extension for storing/querying embedding vectors.

XP

Experience points for eligible care activities and plant milestones under BR-01.

IAM

Identity and access management for scoped service/operational permissions.

EXIF

Image metadata that can include device details or location.

ARB

Application Resource Bundle, used for translated Flutter strings.

LangGraph

State/transition orchestration for the assistant, with persisted checkpoints.

OIDC

OpenID Connect; used for authenticated cloud-service invocation.

LLM

Large language model used for generation and tool proposals.

ECE

Expected calibration error; this SRS uses ten confidence bins for the provisional metric.

Model card

Versioned record of model inputs, labels, data rights, evaluation and limitations.

Product owner

The person responsible for approving scope and public release evidence. Team Tenzr still needs to name this person.

Appendix B: Analysis Models

System context and architecture

Figure B-1 — System context and architecture.

This is a logical view; IAM, database access controls and privacy checks apply to every path. LangSmith evaluates approved/redacted cases and does not receive production content by default.

Primary use cases and scan sequence

Use case

Actor

Requirements

UC-01 Sign in and manage a garden

Grower

REQ-5.1–5.2, SEC-1, SEC-4

UC-02 Assess disease or quality

Grower

REQ-1.1–1.9, REQ-2.1–2.7, REQ-3.8, REQ-4.10, REQ-5.19, QUAL-1, SAFE-4

UC-03 Plan and record care

Grower

REQ-3.1–3.8, REQ-5.3–5.4, REQ-5.13–5.14

UC-04 Chat and confirm an action

Grower

REQ-4.1–4.11, SAFE-2, SAFE-5

UC-05 Publish and interact

Grower / public recipient

REQ-5.5–5.12, SEC-1

UC-06 Report and review content

Operational owner

REQ-5.10–5.12, SEC-4, OPS-3

UC-07 Consent, export and deletion

Grower / operations

REQ-5.16–5.18, DATA-1–DATA-6

UC-08 Use all three languages

Grower

REQ-5.15, QUAL-2, AC-5.15

Figure B-2 — Scan submission, job status and result retrieval.

Use-case descriptions and acceptance paths:

UC-01 — Authenticate and maintain a private garden. Actor: grower. With a network connection and a valid sign-in method, the grower verifies their email or uses Google sign-in. They choose a supported crop and growing area and save a plant to their profile. If identity verification, permissions or input checks fail, explain how to recover. Only the owner can read or change the private records. Trace: REQ-5.1–5.4, SEC-1, SEC-4.

UC-02 — Assess disease or quality. Actor: grower. The grower chooses a supported crop, scan type and plant part. With an active account, they submit a usable photo or explicitly queue it offline. They follow job progress, receive a category or an explanation that the model cannot assess the photo, and may save the result to one of their plants. Invalid or uncertain inputs, quota limits and service or network failures do not produce a guessed result. Keep one durable job and record the source and model for each result. Trace: REQ-1.*, REQ-2.*, REQ-3.8, REQ-4.10, REQ-5.19, QUAL-1.

UC-03 — Plan and record care. Actor: grower. The grower opens a plant they own, optionally selects an area or uses GPS and adds care context. They view the forecast and its source, read the reviewed recommendation, and create and complete a care task. Stale forecasts limit advice. Offline logs stay pending, and the in-app schedule still works without notification permission. Completing care records one authorised event, updates the task and awards XP if the event qualifies. Trace: REQ-3.*, REQ-5.3–5.4, REQ-5.13–5.14.

UC-04 — Ask the assistant and confirm a care action. Actor: grower. In a conversation they own, the grower asks a question using permitted context. The assistant retrieves approved references and cites them in its reply. If it suggests an action, it shows the exact change for the grower to confirm. The backend checks and saves the confirmed action once. Cancellation, expiry after ten minutes, a changed record, missing evidence or tool failure cannot cause an unauthorised write. The recorded outcome can be audited. Trace: REQ-4.1–4.11, SAFE-2, SAFE-5.

UC-05 — Publish and interact. Actor: grower. A grower with an active account accepts the community rules, previews a post and publishes it. They can browse tagged feeds, comment, like, follow, bookmark and share, and can edit or delete their own content. Apply blocking, removal, uniqueness and ownership rules to each interaction. Public visitors can read explicitly shared posts. Trace: REQ-5.5–5.9, SEC-1.

UC-06 — Report and review content. Actors: grower and authorised operational owner. The grower submits a target and reason and receives an acknowledgement. The owner checks the report, records the decision and may remove content or suspend an account. Reject invalid reports and limit spam. Ordinary users cannot read confidential reports or take review actions. Protect the reporter’s identity and provide an appeal route. Trace: REQ-5.10–5.12, SEC-4, OPS-3.

UC-07 — Control consent, export and deletion. Actor: grower. The grower can manage optional training consent, request their own export or confirm account deletion and receive a receipt. Ask them to sign in again when required. Declining consent does not affect scanning. Deny access to other accounts and keep deleted records from reappearing after a restore. Follow the timing in DATA-1–DATA-6. Trace: REQ-5.16–5.18, DATA-1–DATA-6.

UC-08 — Use the system in three languages. Actor: grower. The grower chooses English, Sinhala or Tamil and completes the account, scan, care, chat, community and privacy workflows in that language. Keep their preferred language. Unreadable characters, clipped controls or unsafe wording fail the language review. Trace: REQ-5.15, QUAL-2, AC-5.15.

UC-09 — Run an offline disease scan. The grower downloads an approved crop model while connected. With the network unavailable, they capture a usable image, review the result or abstention, and save it to their own record. On reconnection the same operation syncs once. An unavailable model leads to an explicit photo-queue option. Trace: REQ-1.8, REQ-1.10–1.11, BR-12.

UC-10 — Compare care, harvest and market options. The grower adds growing context to a plant. They review the forecast, estimated watering volume, scenario comparison and harvest window. They record a harvest and post-harvest observations and review the price-source estimate. Stale or missing evidence prevents a new estimate. Trace: REQ-3.9–3.15, BR-13.

UC-11 — Use voice or a file in the assistant. The grower records a message, reviews the transcript and sends it, or uploads a supported file. The assistant answers with approved references and may offer spoken playback. A suggested care change follows the normal confirmation flow. Trace: REQ-4.6–4.7, REQ-4.12–4.14, BR-14.

UC-12 — Earn community rewards and view regional summaries. The grower submits an eligible post. The system awards XP once, reflects new milestones in their forest and shows leaderboard placement only for opt-in accounts. Regional statistics suppress small groups and do not expose participants. Trace: REQ-5.20–5.22, BR-01, BR-13.

Additional analysis models:

Figure B-3 — Launch use cases. Growers use the Android workflows, shared-post visitors have read-only access, and authorised owners review reports.

Figure B-4 — Garden, consent, scans and harvest. Model versions and unique operations record where a result was produced. Forecast and price evidence stay separate from private observations.

Figure B-5 — Community, assistant and rewards. The diagram shows record ownership, report targets, attachment provenance, confirmed actions and reward events.

Figure B-6 — Server scan and offline result states. A queued photo becomes a server job. A saved on-device result follows its own sync path and keeps its original model version.

Figure B-7 — Agent-action state model. Only a current, authorised, unexpired single-use confirmation permits execution. A cancelled or expired proposal cannot execute. If the outcome is unknown, show that uncertainty and retry only with the same operation ID to recover the recorded outcome.

Figure B-8 — Farming and harvest activities.

Figure B-9 — Voice and attachment interaction.

Figure B-10 — Community XP and visibility.

Data-model constraints:

Internal record IDs use UUIDs. A unique Firebase UID links each external identity to an account. Private records identify their owner through a foreign key. A scan can exist without a linked plant and has at most one result. Validate the crop, task, model version and normalised labels against the versioned manifest.

Care logs are appendable events with a user/client-operation uniqueness key; a completed scheduled occurrence links to at most one care log and reward event. Care-task statuses are pending, completed, skipped or cancelled, distinct from recommendation text. Assets retain owner, purpose, checksum and consent snapshot/provenance; deleting an account invalidates pending jobs before content cleanup.

Social edges enforce unique (follower, followed), (blocker, blocked), (user, post-like) and (user, bookmark) pairs and reject self-follow/block. Reports use separate nullable post/comment/user target foreign keys with an exactly-one-target check, rather than an unconstrained polymorphic ID. Review actions link report, authorised reviewer, decision, reason and timestamp.

Threads, messages and proposed actions belong to their owner. An action’s payload digest, expiry, target revision and unique operation ID bind confirmation to the exact change. Approved knowledge sources own chunks and embeddings. Record the source URL, crop, language and review status and use the embedding schema approved under BR-09. Notification delivery, XP, consent, worker leases, idempotency and deletion records retain their required lifecycle and uniqueness constraints.

Offline packs are versioned releases of server disease models. Saved local results reference the manifest version, device execution mode and unique user operation ID. A result sync creates one owned record and does not create a second inference job. Harvest and post-harvest observations stay private. Estimate snapshots reference input, forecast, method and price versions. Regional signals are separately consented and published only as aggregate records. Reward ledger entries have a unique earning-event key, including a post ID for posting XP.

Verification for added requirements. Exercise the 60% boundary and unsupported images online and offline. Test interrupted downloads, bad checksums, incompatible and revoked versions, account switching, quota exhaustion, duplicate sync and unavailable models. Record package size, memory, cold and warm scan latency and model metrics on representative devices. For farming, compare estimates and alerts with reviewer-approved cases, test missing inputs and stale sources, verify small-group suppression and confirm that simulations never create a task on their own. For assistant and rewards, test all three languages, permission refusal, bad and injected files, denied confirmation, replayed and removed posts, opt-out, blocking and data removal.

Verification and traceability

Requirement family

Required evidence

Accountable owner

REQ-1, REQ-2

Twelve server model tests, six offline package tests, 60% disease boundary, supported inputs, local-result replay, and optional output evidence

All crop owners; Dev 1 common workflow, Dev 2 quality presentation

REQ-3

Forecast freshness, volume and harvest benchmarks, simulation, regional privacy, crop advice, market-value and harvest-record checks

Dev 3

REQ-4

Three-language provider comparison, voice, file handling, FAQ, source checks, ownership, prompt injection and action confirmation

Dev 4 + domain/language reviewers

REQ-5

Accounts, offline diary, social controls, post XP and cap/reversal, private forest, leaderboard opt-in, statistics, consent and deletion

Dev 5 + integration coordinator

PERF

Reproducible load report, resource settings and approved scan timing table

Integration coordinator + crop owners

SAFE / QUAL-1

Dataset manifests, model cards, independent field metrics, approved per-class numeric acceptance matrix

Crop owners + agronomy reviewer

SEC / DATA

Ownership, media and security tests. Evidence for retention, consent, deletion and backup restoration, plus privacy review.

Integration coordinator + Dev 5

QUAL-2–QUAL-4

Language, device, accessibility and recovery checks. Include generated OpenAPI and JSON Schema validation, consumer fixtures and migration compatibility.

Each UI owner + reviewers

OPS

Infrastructure setup, operations guide, monitoring, budget approval, restore and rollback drills, and incident contacts

Integration coordinator + product owner

REQ-5.15 / QUAL-2

Core workflows in all three languages, terminology, script rendering, accessibility and approval for each language

UI owners + language/agronomy reviewers

REQ-5.19 / QUAL-1

Both chrysanthemum model contracts, local stage data, independent metrics and abstention review

Dev 5 + agronomy reviewer

In pull requests and release records, link test evidence to each requirement it verifies. The table groups related IDs for readability.

Module ownership

Developer

Assigned implementation and supplied starting material

Dev 1

Common scan/capture/history plus tomato/chilli four models; catalogue DS-TOM-DIS / DS-CHI-DIS / DS-VEG-Q.

Dev 2

Quality presentation plus citrus two models; DS-CIT-DIS / DS-FRUIT-Q, explicit variety/organ limits.

Dev 3

Weather/rules/care scheduling plus banana two models; DS-BAN-DIS / DS-BAN-RIPE and selected provider docs.

Dev 4

Assistant/retrieval/confirmed tools plus roses two models; DS-ROS-DIS / DS-ROS-STAGE and source corpus plan.

Dev 5

Accounts/gardens/diary/community/block/report/review/rewards/consent/deletion plus chrysanthemum two models; DS-CHR-DIS / DS-CHR-STAGE and local annotation plan.

The ownership table assigns each module to a Team Tenzr developer. The integration coordinator maintains shared API and model formats and the verification record. Section 2.1 identifies the academic supervisor and the two industry supervisors from Xenergy. Team Tenzr still needs to name a product owner to approve the release. Agricultural and language review does not grant reviewers access to private production records.

Appendix C: Issues List

The table lists open decisions, measurements and approvals, with the owner and evidence needed to close each item.

Issue ID

Open Issue

Owner

Closure Evidence

ISS-01

Dataset/image rights and labels

Crop owners

Audit original archives, permissions and label definitions; freeze class maps.

ISS-02

Chrysanthemum stage data

Dev 5 + agronomy reviewer

Collect local bud and open-flower photos, then apply BR-07 and BR-08.

ISS-03

Numeric model acceptance criteria

Crop owners + agronomy reviewer

Validate the fixed 60% disease cutoff and provisional QUAL-1 targets for server and device builds. Approve quality thresholds and record supported labels, class metrics and abstention evidence.

ISS-04

Measured scan-response limits

Coordinator + crop owners

Benchmark the provisional PERF-3 objectives across twelve models and representative mobile connections; approve measured limits and disclose cold starts.

ISS-05

Android support matrix

Mobile owners

Validate the Android 10/API 29 planning floor and representative device matrix; publish actual minimum support and camera/offline/notification/language results.

ISS-06

Production budget/accounts

Owner + coordinator

Approve spend, billing ownership, locations, quotas and processing terms before provisioning.

ISS-07

Reviewers and incident/report contacts

Product owner

Appoint agricultural and language reviewers and contacts for incidents and report review. Publish the support and appeal process.

ISS-08

Public launch acceptance

Owner + team

Complete traceability, language, capacity, security and privacy checks. Test deletion, restore and rollback before launch.

ISS-09

Named product owner

Team Tenzr / Xenergy

Confirm the named product owner for release acceptance. Section 2.1 identifies the Xenergy industry supervisors.

ISS-11

Offline model distribution and devices

Mobile and crop owners

Approve the six Android disease packages. Record compatibility, download sizes, field accuracy, abstention, update rollback and sync results.

ISS-12

Advisory and market validation

Dev 3 + agronomy reviewers

Approve crop rules, error bounds, regional sample and privacy rules, price sources and freshness, and validation results for all launch estimates.

ISS-13

Assistant, embedding and speech provider selection

Dev 4 + language reviewers

Compare providers under BR-09 and BR-14. Record language, safety, privacy, quota, latency and cost results and freeze the index configuration.

Release acceptance checklist

Complete the checks below before announcing public launch. The academic demonstration and verification record are defined in section 1.4.

[ ] Download the selected datasets, verify image rights and remove duplicates. Collect the missing local and chrysanthemum images and approve all label definitions.

[ ] Validate all twelve server models and all six Android disease variants. Verify the fixed disease cutoff, field metrics, model delivery and sync. Enable additional numeric scan outputs only after REQ-2.8 evidence and approval.

[ ] Measure and approve inference and end-to-end scan timing limits. Pass the load test with 100 sessions.

[ ] Pass the three-language provider benchmark and voice and file checks. Approve offline model compatibility, forecast and estimate methods, regional aggregation and privacy, harvest and market data, and rewards before launch.

[ ] Publish the tested Android versions and minimum supported version. Pass camera, offline, notification and accessibility checks.

[ ] Align OpenAPI, machine-validated model schemas and migrations with the SRS. Verify all functional requirements.

[ ] Verify ownership, security and privacy, including consent, export and deletion. Test backups, restoration, rollback and recovery after failures.

[ ] Approve provider budgets, accounts, quotas, processing locations and terms. Approve the privacy, terms and help URLs and verify distribution requirements.

[ ] Appoint agricultural and language reviewers and contacts for incidents and report review. Test reporting, removal and appeals, then publish the community rules.

[ ] Product owner reviews traceability and accepts release evidence before announcing launch.

Announce public launch only after these checks pass. Unmeasured values and pending approvals remain in this issues list until resolved.
