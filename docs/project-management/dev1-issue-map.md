# Developer 1 issue and dependency map

Owner: `Kavee-ginty`. Capacity: 3 hours every day. Estimates are provisional remaining effort; confirm status with PR/test/demo evidence.

[Shared CPM, ownership decisions and traceability](TEAM_DEPENDENCIES.md)

| ID / GitHub issue | Work | Scope | Hours | Technical blockers | State |
|---|---|---|---:|---|---|
| F0 F0 | Shared development foundation accepted | foundation | 0 |  | done |
| I1A [#44](https://github.com/Tenzrr/Elora/issues/44) | Interim: authenticated tomato upload and status flow | interim | 6 | F0 F0 | not_started |
| I1B [#45](https://github.com/Tenzrr/Elora/issues/45) | Interim: tomato disease dataset and evaluated baseline | interim | 9 | F0 F0 | not_started |
| I1C [#46](https://github.com/Tenzrr/Elora/issues/46) | Interim: crop-health evidence and focused PR | interim | 3 | I1A [#44](https://github.com/Tenzrr/Elora/issues/44), I1B [#45](https://github.com/Tenzrr/Elora/issues/45) | not_started |
| IG [#51](https://github.com/Tenzrr/Elora/issues/51) | Interim: reviewed integration, freeze and rehearsal | interim | 6 | I1C [#46](https://github.com/Tenzrr/Elora/issues/46), I2 [#47](https://github.com/Tenzrr/Elora/issues/47), I3 [#48](https://github.com/Tenzrr/Elora/issues/48), I4 [#50](https://github.com/Tenzrr/Elora/issues/50), I5 [#49](https://github.com/Tenzrr/Elora/issues/49) | not_started |
| S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | Freeze shared API, model and cross-module handoff contracts | release | 9 | IG [#51](https://github.com/Tenzrr/Elora/issues/51) | not_started |
| S2 [#53](https://github.com/Tenzrr/Elora/issues/53) | Private media, durable workers and deployment preparation | release | 18 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D1A [#54](https://github.com/Tenzrr/Elora/issues/54) | Durable shared scan jobs and versioned model registry | release | 18 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52), S2 [#53](https://github.com/Tenzrr/Elora/issues/53) | not_started |
| D1B [#55](https://github.com/Tenzrr/Elora/issues/55) | Android capture, disease results and reviewed guidance | release | 15 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D1C [#56](https://github.com/Tenzrr/Elora/issues/56) | Owned scan saving, history and deletion service | release | 12 | D1A [#54](https://github.com/Tenzrr/Elora/issues/54) | not_started |
| D1D [#57](https://github.com/Tenzrr/Elora/issues/57) | Audit tomato/chilli datasets and freeze four label maps | release | 12 | I1B [#45](https://github.com/Tenzrr/Elora/issues/45), S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D1E [#58](https://github.com/Tenzrr/Elora/issues/58) | Train and calibrate four tomato/chilli server models | release | 30 | D1D [#57](https://github.com/Tenzrr/Elora/issues/57) | not_started |
| D1F [#59](https://github.com/Tenzrr/Elora/issues/59) | Independent tomato/chilli and Android variant validation | release | 18 | D1E [#58](https://github.com/Tenzrr/Elora/issues/58) | not_started |
| D1G [#60](https://github.com/Tenzrr/Elora/issues/60) | Signed offline disease package delivery and local inference | release | 18 | D1A [#54](https://github.com/Tenzrr/Elora/issues/54), D1B [#55](https://github.com/Tenzrr/Elora/issues/55), D1F [#59](https://github.com/Tenzrr/Elora/issues/59) | not_started |
| D1H [#61](https://github.com/Tenzrr/Elora/issues/61) | Offline photo queue and once-only local result sync | release | 18 | D1C [#56](https://github.com/Tenzrr/Elora/issues/56), D1G [#60](https://github.com/Tenzrr/Elora/issues/60), D5B [#82](https://github.com/Tenzrr/Elora/issues/82) | not_started |
| D1I [#62](https://github.com/Tenzrr/Elora/issues/62) | Integrate twelve server models and six Android disease packs | release | 12 | D1A [#54](https://github.com/Tenzrr/Elora/issues/54), D1F [#59](https://github.com/Tenzrr/Elora/issues/59), D1G [#60](https://github.com/Tenzrr/Elora/issues/60), D2D [#66](https://github.com/Tenzrr/Elora/issues/66), D3F [#74](https://github.com/Tenzrr/Elora/issues/74), D4N [#24](https://github.com/Tenzrr/Elora/issues/24), D5K [#91](https://github.com/Tenzrr/Elora/issues/91) | not_started |
| R1 [#93](https://github.com/Tenzrr/Elora/issues/93) | Integrated security, replay, load and recovery verification | release | 24 | D1H [#61](https://github.com/Tenzrr/Elora/issues/61), D1I [#62](https://github.com/Tenzrr/Elora/issues/62), D2F [#68](https://github.com/Tenzrr/Elora/issues/68), D3J [#78](https://github.com/Tenzrr/Elora/issues/78), D4O [#25](https://github.com/Tenzrr/Elora/issues/25), D5L [#92](https://github.com/Tenzrr/Elora/issues/92) | not_started |
| R3 [#95](https://github.com/Tenzrr/Elora/issues/95) | Release operations, provenance, rollback and handover | release | 18 | R1 [#93](https://github.com/Tenzrr/Elora/issues/93), S2 [#53](https://github.com/Tenzrr/Elora/issues/53), D5F [#86](https://github.com/Tenzrr/Elora/issues/86) | not_started |
