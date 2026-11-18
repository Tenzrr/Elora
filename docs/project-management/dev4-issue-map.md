# Developer 4 issue and dependency map

Owner: `SadeepaNHerath`. Capacity: 3 hours every day. Estimates are provisional remaining effort; confirm status with PR/test/demo evidence.

[Shared CPM, ownership decisions and traceability](TEAM_DEPENDENCIES.md)

| ID / GitHub issue | Work | Scope | Hours | Technical blockers | State |
|---|---|---|---:|---|---|
| D4A [#10](https://github.com/Tenzrr/Elora/issues/10) | Chat contract and baseline endpoint | interim | 3 | F0 F0 | in_review |
| D4B [#11](https://github.com/Tenzrr/Elora/issues/11) | Typed owner-only plant context tool | interim | 3 | D4A [#10](https://github.com/Tenzrr/Elora/issues/10) | in_review |
| D4C [#12](https://github.com/Tenzrr/Elora/issues/12) | Mobile chat foundation | interim | 3 | D4A [#10](https://github.com/Tenzrr/Elora/issues/10) | in_review |
| D4D [#13](https://github.com/Tenzrr/Elora/issues/13) | Agronomist prompt and chemical safety boundaries | interim | 3 | D4A [#10](https://github.com/Tenzrr/Elora/issues/10) | in_review |
| I4 [#50](https://github.com/Tenzrr/Elora/issues/50) | Interim: real LLM turn, bounded failure and evidence | interim | 6 | D4B [#11](https://github.com/Tenzrr/Elora/issues/11), D4C [#12](https://github.com/Tenzrr/Elora/issues/12), D4D [#13](https://github.com/Tenzrr/Elora/issues/13) | not_started |
| D4E [#14](https://github.com/Tenzrr/Elora/issues/14) | Chat thread/message persistence and canonical service routes | release | 12 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52), D4A [#10](https://github.com/Tenzrr/Elora/issues/10) | not_started |
| D4F [#15](https://github.com/Tenzrr/Elora/issues/15) | Conversation history UI and thread switching | release | 9 | D4E [#14](https://github.com/Tenzrr/Elora/issues/14), D4C [#12](https://github.com/Tenzrr/Elora/issues/12) | not_started |
| D4P [#79](https://github.com/Tenzrr/Elora/issues/79) | Select generation, embedding and speech providers | release | 15 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52), D4D [#13](https://github.com/Tenzrr/Elora/issues/13) | not_started |
| D4G [#16](https://github.com/Tenzrr/Elora/issues/16) | Approved knowledge schema and ingestion pipeline | release | 12 | D4P [#79](https://github.com/Tenzrr/Elora/issues/79), S2 [#53](https://github.com/Tenzrr/Elora/issues/53) | not_started |
| D4H [#17](https://github.com/Tenzrr/Elora/issues/17) | Cited retrieval and typed plant, scan and weather reads | release | 15 | D4G [#16](https://github.com/Tenzrr/Elora/issues/16), D4B [#11](https://github.com/Tenzrr/Elora/issues/11), D1C [#56](https://github.com/Tenzrr/Elora/issues/56), D3A [#69](https://github.com/Tenzrr/Elora/issues/69) | not_started |
| D4I [#18](https://github.com/Tenzrr/Elora/issues/18) | Two-phase confirmed care actions | release | 18 | D4E [#14](https://github.com/Tenzrr/Elora/issues/14), D3B [#70](https://github.com/Tenzrr/Elora/issues/70), D5B [#82](https://github.com/Tenzrr/Elora/issues/82) | not_started |
| D4J [#19](https://github.com/Tenzrr/Elora/issues/19) | LangGraph orchestration, checkpoints and bounded tools | release | 18 | D4E [#14](https://github.com/Tenzrr/Elora/issues/14), D4H [#17](https://github.com/Tenzrr/Elora/issues/17), D4I [#18](https://github.com/Tenzrr/Elora/issues/18), D4D [#13](https://github.com/Tenzrr/Elora/issues/13) | not_started |
| D4K [#20](https://github.com/Tenzrr/Elora/issues/20) | Private photo/document attachments and safe extraction | release | 12 | D4E [#14](https://github.com/Tenzrr/Elora/issues/14), S2 [#53](https://github.com/Tenzrr/Elora/issues/53) | not_started |
| D4L [#21](https://github.com/Tenzrr/Elora/issues/21) | Three-language speech input and reply playback | release | 15 | D4P [#79](https://github.com/Tenzrr/Elora/issues/79), D4C [#12](https://github.com/Tenzrr/Elora/issues/12), D4E [#14](https://github.com/Tenzrr/Elora/issues/14) | not_started |
| D4M1 [#22](https://github.com/Tenzrr/Elora/issues/22) | Rose disease dataset, training and calibration | release | 15 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D4M2 [#23](https://github.com/Tenzrr/Elora/issues/23) | Rose growth-stage dataset, training and calibration | release | 15 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D4N [#24](https://github.com/Tenzrr/Elora/issues/24) | Validated rose artifacts through common inference | release | 18 | D4M1 [#22](https://github.com/Tenzrr/Elora/issues/22), D4M2 [#23](https://github.com/Tenzrr/Elora/issues/23), D1A [#54](https://github.com/Tenzrr/Elora/issues/54) | not_started |
| D4Q [#80](https://github.com/Tenzrr/Elora/issues/80) | Reviewed gardening FAQ in three languages | release | 9 | D4P [#79](https://github.com/Tenzrr/Elora/issues/79) | not_started |
| D4O [#25](https://github.com/Tenzrr/Elora/issues/25) | Assistant safety, privacy and three-language acceptance | release | 18 | D4J [#19](https://github.com/Tenzrr/Elora/issues/19), D4K [#20](https://github.com/Tenzrr/Elora/issues/20), D4L [#21](https://github.com/Tenzrr/Elora/issues/21), D4Q [#80](https://github.com/Tenzrr/Elora/issues/80), D4N [#24](https://github.com/Tenzrr/Elora/issues/24) | not_started |
