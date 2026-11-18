# Developer 3 issue and dependency map

Owner: `Dimanya-Perera`. Capacity: 3 hours every day. Estimates are provisional remaining effort; confirm status with PR/test/demo evidence.

[Shared CPM, ownership decisions and traceability](TEAM_DEPENDENCIES.md)

| ID / GitHub issue | Work | Scope | Hours | Technical blockers | State |
|---|---|---|---:|---|---|
| I3 [#48](https://github.com/Tenzrr/Elora/issues/48) | Interim: live location forecast and explained advisory | interim | 12 | F0 F0 | not_started |
| D3A [#69](https://github.com/Tenzrr/Elora/issues/69) | Weather/location service, freshness and typed read contract | release | 12 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52), I3 [#48](https://github.com/Tenzrr/Elora/issues/48) | not_started |
| D3B [#70](https://github.com/Tenzrr/Elora/issues/70) | Owned care task persistence, revisions and mutation service | release | 18 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D3C [#71](https://github.com/Tenzrr/Elora/issues/71) | Reviewed care rules and forecast-based recommendations | release | 15 | D3A [#69](https://github.com/Tenzrr/Elora/issues/69), D3B [#70](https://github.com/Tenzrr/Elora/issues/70) | not_started |
| D3D [#72](https://github.com/Tenzrr/Elora/issues/72) | Care reminders integrated with notification preferences | release | 12 | D3B [#70](https://github.com/Tenzrr/Elora/issues/70), D5C [#83](https://github.com/Tenzrr/Elora/issues/83) | not_started |
| D3E [#73](https://github.com/Tenzrr/Elora/issues/73) | Audit, train and calibrate banana model pair | release | 24 | S1 [#52](https://github.com/Tenzrr/Elora/issues/52) | not_started |
| D3F [#74](https://github.com/Tenzrr/Elora/issues/74) | Independent banana evaluation and Android disease variant | release | 18 | D3E [#73](https://github.com/Tenzrr/Elora/issues/73) | not_started |
| D3G [#75](https://github.com/Tenzrr/Elora/issues/75) | Reviewed watering, harvest-window and irrigation scenarios | release | 24 | D3C [#71](https://github.com/Tenzrr/Elora/issues/71) | not_started |
| D3H [#76](https://github.com/Tenzrr/Elora/issues/76) | Private harvest observations, crop advice and market values | release | 24 | D3C [#71](https://github.com/Tenzrr/Elora/issues/71) | not_started |
| D3I [#77](https://github.com/Tenzrr/Elora/issues/77) | Privacy-preserving regional risk alerts | release | 15 | D3A [#69](https://github.com/Tenzrr/Elora/issues/69), D5I [#89](https://github.com/Tenzrr/Elora/issues/89) | not_started |
| D3J [#78](https://github.com/Tenzrr/Elora/issues/78) | Farming methods, translations and device acceptance | release | 15 | D3D [#72](https://github.com/Tenzrr/Elora/issues/72), D3G [#75](https://github.com/Tenzrr/Elora/issues/75), D3H [#76](https://github.com/Tenzrr/Elora/issues/76), D3I [#77](https://github.com/Tenzrr/Elora/issues/77), D3F [#74](https://github.com/Tenzrr/Elora/issues/74) | not_started |
