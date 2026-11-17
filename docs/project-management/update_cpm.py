"""Regenerate planning views: python docs/project-management/update_cpm.py.

Uses calendar days, declared remaining effort, and explicit handoff dependencies.
This is a deterministic planning scenario, not a claim of actual completion.
"""
import csv
import json
import math
import re
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent.parent
PLAN = json.loads((ROOT / 'team-plan.json').read_text(encoding='utf-8'))
TASKS = {t['key']: t for t in PLAN['tasks']}
RATE = PLAN['capacity_hours_per_person_per_day']


def duration(task):
    return max(math.ceil(task['hours'] / RATE), task['minimum_elapsed_days'])


def analyse(scope):
    active = {k: t for k, t in TASKS.items() if t['scope'] == scope}
    pending, order = set(active), []
    while pending:
        ready = sorted(k for k in pending if not (set(active[k]['predecessors']) & pending))
        if not ready:
            raise ValueError(f'Cyclic dependencies: {sorted(pending)}')
        order.extend(ready)
        pending.difference_update(ready)
    successors = {k: [] for k in active}
    timing = {}
    for k in order:
        preds = [p for p in active[k]['predecessors'] if p in active]
        for p in preds:
            successors[p].append(k)
        es = max((timing[p]['ef'] for p in preds), default=0)
        timing[k] = dict(es=es, ef=es + duration(active[k]))
    finish = max(t['ef'] for t in timing.values())
    for k in reversed(order):
        lf = min((timing[s]['ls'] for s in successors[k]), default=finish)
        timing[k].update(lf=lf, ls=lf - duration(active[k]))
        timing[k]['float'] = timing[k]['ls'] - timing[k]['es']
        timing[k]['tail'] = finish - timing[k]['ls']
        assert timing[k]['float'] >= 0
        assert timing[k]['ef'] <= timing[k]['lf']

    # A day-by-day resource schedule. Work occupies one owner; external wait
    # continues after work and does not reserve that developer's capacity.
    scheduled, busy_until, last_work = {}, {}, {}
    day = 0
    while len(scheduled) < len(active):
        ready = [k for k in order if k not in scheduled and
                 all(p not in active or (p in scheduled and scheduled[p]['finish'] <= day)
                     for p in active[k]['predecessors'])]
        ready.sort(key=lambda k: (-timing[k]['tail'], k))
        for k in ready:
            task = active[k]
            owner = task['owner']
            if owner and busy_until.get(owner, 0) > day:
                continue
            effort_days = math.ceil(task['hours'] / RATE)
            scheduled[k] = dict(start=day, work_finish=day + effort_days,
                                finish=day + duration(task),
                                resource_predecessor=last_work.get(owner) if owner else None)
            if owner and effort_days:
                busy_until[owner] = day + effort_days
                last_work[owner] = k
        day += 1
        assert day < 10000, 'Schedule did not converge'
    for k, item in scheduled.items():
        assert all(p not in active or scheduled[p]['finish'] <= item['start']
                   for p in active[k]['predecessors'])
    for owner in range(1, 6):
        intervals = sorted((v['start'], v['work_finish']) for k, v in scheduled.items()
                           if active[k]['owner'] == owner and v['work_finish'] > v['start'])
        assert all(a[1] <= b[0] for a, b in zip(intervals, intervals[1:]))
    assert max(v['finish'] for v in scheduled.values()) >= finish
    return active, order, timing, scheduled, finish


def stamp(start, offset):
    return (start + timedelta(days=offset)).isoformat()


def link(key):
    t = TASKS[key]
    if t['issue']:
        return f"[#{t['issue']}](https://github.com/Tenzrr/Elora/issues/{t['issue']})"
    return key


def diagram(scope, active, order, timing):
    lines = ['flowchart LR', '  classDef critical fill:#ffe2e2,stroke:#c62828,stroke-width:3px',
             '  classDef gate fill:#fff3cd,stroke:#9a6700']
    for owner in range(0, 6):
        owned = [k for k in order if active[k]['owner'] == owner]
        if not owned:
            continue
        lines.append(f'  subgraph owner{owner}["' + (f'Developer {owner}' if owner else 'External acceptance') + '"]')
        for k in owned:
            t = active[k]
            issue = f" #{t['issue']}" if t['issue'] else ''
            title = t['title'].replace('"', "'").replace('&', 'and')
            lines.append(f'    {k}["{k}{issue}: {title}<br/>{t["hours"]}h / {duration(t)} calendar days"]')
        lines.append('  end')
    edge = 0
    critical_edges = []
    for k in order:
        for p in active[k]['predecessors']:
            if p in active:
                lines.append(f'  {p} --> {k}')
                if timing[p]['float'] == timing[k]['float'] == 0 and timing[p]['ef'] == timing[k]['es']:
                    critical_edges.append(str(edge))
                edge += 1
        if active[k]['issue']:
            lines.append(f'  click {k} "https://github.com/Tenzrr/Elora/issues/{active[k]["issue"]}"')
        if timing[k]['float'] == 0:
            lines.append(f'  class {k} critical')
    if scope == 'release':
        lines.append('  class RG gate')
    if critical_edges:
        lines.append('  linkStyle ' + ','.join(critical_edges) + ' stroke:#c62828,stroke-width:3px')
    return '\n'.join(lines) + '\n'


def validate():
    assert len(TASKS) == len(PLAN['tasks']), 'Duplicate activity IDs'
    assert RATE > 0
    for task in TASKS.values():
        assert task['hours'] >= 0 and task['minimum_elapsed_days'] >= 0
        assert all(p in TASKS for p in task['predecessors'])
        assert task['key'] not in task['predecessors']
        assert task['owner'] in range(6)
        phase = {'foundation': 0, 'interim': 1, 'release': 2}
        assert all(phase[TASKS[p]['scope']] <= phase[task['scope']] for p in task['predecessors'])
    text = (REPO / 'docs/specifications/Elora_SRS.md').read_text(encoding='utf-8')
    required = set(re.findall(r'^(?:REQ-\d+\.\d+|(?:PERF|SAFE|SEC|QUAL|DATA|OPS)-\d+)(?=:)', text, re.M))
    mapped = {r for t in TASKS.values() for r in t['requirements']}
    assert len(required) == 99
    assert required <= mapped, f'Unmapped requirements: {required - mapped}'
    assert not mapped - required, f'Unknown requirements: {mapped - required}'
    return required


def main():
    required = validate()
    report = ['# Team dependency and CPM plan', '',
              'Planning baseline: **17 November 2026**. Capacity confirmed by the project owner: '
              '**3 hours per developer every day, including weekends**. Final April date: **undecided**.', '',
              'Estimates are provisional remaining effort, not developer commitments. Owners must validate them and '
              'supply completion evidence. Open PRs are in review, not complete. '
              'Foundation PRs #6/#7 are merged. No other work is credited complete.', '',
              'The release scenario starts no earlier than 24 November and shifts automatically until the forecast interim integration is complete. '
              'Computed dates are planning forecasts, not approved public launch dates.', '',
              '## How to use this plan', '',
              '- GitHub issues hold implementation checklists, acceptance criteria and native blocking links.',
              '- `team-plan.json` holds estimates, technical predecessors, owner and GitHub issue IDs. Update it when a handoff or estimate changes.',
              '- Run `python docs/project-management/update_cpm.py` to regenerate both CPMs, schedule tables, developer views and traceability.',
              '- CPM uses longest dependency path, forward/backward passes and total float in calendar days. Activity duration is max(ceil(hours/3), minimum elapsed lead time).',
              '- The capacity schedule allows only one task per developer at a time. It selects ready tasks with the longest remaining dependency path first. This is a feasible heuristic, not a proof of the shortest possible resource schedule.',
              '- Collection/evaluation tasks have explicit provisional elapsed floors of 14 or 21 days. The external acceptance gate allows seven days; reviewer availability is unconfirmed. Wait days do not reserve developer working time.',
              '- Issue bodies distinguish technical blockers from developer sequencing. A developer\'s availability is not a technical dependency.', '',
              '## Shared ownership and handoffs', '',
              '| Deliverable | Accountable owner | Consumers / completion condition |',
              '|---|---|---|',
              '| Scan jobs, history, registry and model delivery | D1 | D2 quality; D4 scan reads; all crop owners supply versioned artifacts |',
              '| Quality categories and result UI | D2 | Uses common scans; never duplicates the scan persistence service |',
              '| Care tasks, schedule revisions and mutations | D3 | D4 confirmed actions; D5 diary/reward links; migration plus tested typed service required |',
              '| Private diary/logs and reusable offline outbox | D5 | D3 task completion and D4 care logs; D1/D2 queues use the same operation/account contract |',
              '| Devices, notification preferences and delivery interface | D5 | D3 schedules reminders; agreed occurrence IDs prevent duplicates |',
              '| Approved embeddings, retrieval and confirmation orchestration | D4 | Providers selected before production index; actions call D3/D5 services |',
              '| Opt-in district aggregation | D5 | D3 regional alerts consume eligible aggregates, never raw identities |', '',
              'These assignments retain the SRS ownership: care-plan storage belongs to D3. Shared schema/contract changes require D3 review and affected owners; D1 coordinates integration.', '',
              '## Audit of existing Developer 4 issues', '',
              '| Existing issues | Required reconciliation |',
              '|---|---|',
              '| #10, #14, #15 | Interim `/agricultural_agent/chat` is an adapter; final thread/message routes follow the SRS. History needs explicit list/read APIs, not only SQL tables. |',
              '| #16 | Replace fixed 1536-dimensional index with benchmark-selected embedding schema; separate experimental evaluation index from production. |',
              '| #17 | Include typed owner-only scan/weather reads and approved source provenance. |',
              '| #18 | Block real integration on D3 care mutation service and D5 care-log service; schedule/log fields are domain records, not arbitrary additions to plants. |',
              '| #19–#21 | Keep owner checkpoints, actual completed-action state, redaction, file limits, speech fallback and provider minimisation. |',
              '| #22–#24 | Preserve rose training ownership; add independent evaluation and Android disease variant; use common scan route rather than separate public crop endpoints. |',
              '| #25 | Provider-level trilingual benchmark required; regex unit tests alone do not establish safe model behaviour. |',
              '| New D4P / D4Q / I4 | Explicit provider-selection gate, reviewed FAQ and live interim LLM evidence were missing from the detailed issue breakdown. |', '',
              'Existing issue text and history are preserved; a marked planning section records the current acceptance corrections. Existing subtask issues #26–#38 remain attached to their original work.', '']
    results = {}
    for scope in ('interim', 'release'):
        active, order, timing, scheduled, cp_length = analyse(scope)
        start = date.fromisoformat(PLAN['baseline'] if scope == 'interim' else PLAN['release_start'])
        if scope == 'release':
            interim_end = date.fromisoformat(results['interim']['forecast_finish']) + timedelta(days=1)
            start = max(start, interim_end)
        resource_length = max(t['finish'] for t in scheduled.values())
        finish_date = stamp(start, resource_length - 1)
        critical = [k for k in order if timing[k]['float'] == 0]
        mmd = diagram(scope, active, order, timing)
        (ROOT / f'{scope}-cpm.mmd').write_text(mmd, encoding='utf-8')
        gantt = ['gantt', f'  title {scope.title()} capacity schedule — 3 hours daily', '  dateFormat YYYY-MM-DD', '  axisFormat %d %b']
        for owner in range(0, 6):
            owned = sorted((k for k in active if active[k]['owner'] == owner), key=lambda k: scheduled[k]['start'])
            if not owned:
                continue
            gantt.append('  section ' + (f'Developer {owner}' if owner else 'External acceptance'))
            for k in owned:
                s = scheduled[k]
                label = f'{k} #{active[k]["issue"]}' if active[k]['issue'] else k
                if s['work_finish'] > s['start']:
                    gantt.append(f'  {label} work :{k}, {stamp(start, s["start"])}, {s["work_finish"]-s["start"]}d')
                else:
                    gantt.append(f'  {label} review starts :milestone, {k}, {stamp(start, s["start"])}, 0d')
                if s['finish'] > s['work_finish']:
                    gantt.append(f'  {label} lead time :{k}wait, {stamp(start,s["work_finish"])}, {s["finish"]-s["work_finish"]}d')
        (ROOT / f'{scope}-schedule.mmd').write_text('\n'.join(gantt)+'\n', encoding='utf-8')
        report += [f'## {scope.title()} forecast', '',
                   f'Scenario start: **{start}**. ' + ('This respects the interim integration forecast.' if scope == 'release' else 'Remaining work is estimated from the planning baseline.'), '',
                   f'Technical CPM lower bound: **{cp_length} calendar days**, completing **{stamp(start,cp_length-1)}**. '
                   f'Capacity-constrained forecast: **{resource_length} calendar days**, completing **{finish_date}**.', '',
                   'Zero-total-float activities (technical CPM): ' + ', '.join(critical) + '. '
                   'The diagram shows the actual dependency edges and parallel critical branches.', '']
        if scope == 'interim':
            ready = date.fromisoformat(PLAN['interim_ready'])
            late = (date.fromisoformat(finish_date)-ready).days
            report += [f'Rehearsal-ready target: **{ready}**; forecast is **{late} days after that target**. '
                       'Presentation is **23 November**. This is an evidence/remaining-effort scenario; existing work may reduce it once verified. '
                       'Do not promise all originally planned work without that verification. Prioritise contract handoffs and small demonstrable slices; '
                       'keep actual assistant tool execution stretch and trained model evidence separate if inference integration is unfinished.', '']
        else:
            available = (date(2027,4,30)-start).days+1
            report += ['| Owner | Release effort | Nominal days at 3h/day | Capacity through April 30 |',
                       '|---|---:|---:|---:|']
            for owner in range(1,6):
                hours = sum(t['hours'] for t in active.values() if t['owner']==owner)
                report.append(f'| D{owner} | {hours}h | {math.ceil(hours/RATE)} | {available*RATE}h |')
            report += ['', f'Against April 1 the forecast buffer is **{(date(2027,4,1)-date.fromisoformat(finish_date)).days} days**; '
                       f'against April 30 it is **{(date(2027,4,30)-date.fromisoformat(finish_date)).days} days**. '
                       'Neither date is an approved deadline. Unconfirmed reviewers, collection access, compute/provider availability, rework and actual completion evidence can change the forecast.', '']
            overview = ['flowchart LR', '  classDef critical fill:#ffe2e2,stroke:#c62828,stroke-width:3px']
            for k in critical:
                t = active[k]
                who = f'D{t["owner"]}' if t['owner'] else 'Reviewers'
                overview.append(f'  {k}["{who}: {t["title"]}<br/>{duration(t)} days"]:::critical')
                for p in t['predecessors']:
                    if p in critical and timing[p]['ef'] == timing[k]['es']:
                        overview.append(f'  {p} --> {k}')
            summary = '\n'.join(overview)+'\n'
            (ROOT/'critical-path-overview.mmd').write_text(summary,encoding='utf-8')
            report += ['### Critical-path overview', '',
                       'This compact view shows only zero-float activities and their driving edges. '
                       'Noncritical branches remain in the exact full network below. Durations include the declared provisional elapsed lead times.', '',
                       '[Download critical-path overview PNG](png/critical-path-overview.png)', '',
                       '```mermaid',summary.rstrip(),'```','']
        report += [f'[Full {scope} CPM source]({scope}-cpm.mmd) · [Download PNG](png/{scope}-cpm.png) · [Developer capacity Gantt source]({scope}-schedule.mmd)', '',
                   '<details>', f'<summary>Open exact {scope} dependency diagram (red = zero total float)</summary>', '',
                   '```mermaid', mmd.rstrip(), '```', '', '</details>', '',
                   '| ID / issue | Owner | Effort | Predecessors | ES–EF / LS–LF / float | Capacity dates |',
                   '|---|---|---:|---|---|---|']
        for k in order:
            t, c, s = active[k], timing[k], scheduled[k]
            deps = ', '.join(p for p in t['predecessors']) or '—'
            owner_label = f'D{t["owner"]}' if t['owner'] else 'External'
            report.append(f'| {k} {link(k)} | {owner_label} | {t["hours"]}h | {deps} | '
                          f'{c["es"]}–{c["ef"]} / {c["ls"]}–{c["lf"]} / {c["float"]} | '
                          f'{stamp(start,s["start"])} to {stamp(start,s["finish"]-1)} |')
        report += ['', 'CPM offsets use exclusive finish boundaries: ES 0 / EF 2 means two full calendar days. '
                   'Capacity table dates are inclusive. Detailed Gantt separates active work from remaining elapsed lead time.', '']
        results[scope] = dict(start=start.isoformat(), technical_days=cp_length, capacity_days=resource_length, forecast_finish=finish_date,
                              critical=critical, timing=timing, schedule=scheduled)
    report += ['## Requirement coverage and evidence', '',
               f'All **{len(required)} SRS requirement IDs** are assigned below. Assignment is not evidence of implementation or acceptance.', '',
               '| Requirement | Activities / issues |', '|---|---|']
    for req in sorted(required):
        keys = [k for k,t in TASKS.items() if req in t['requirements']]
        report.append(f'| {req} | ' + ', '.join(f'{k} {link(k)}' for k in keys) + ' |')
    (ROOT/'TEAM_DEPENDENCIES.md').write_text('\n'.join(report)+'\n', encoding='utf-8')
    (ROOT/'schedule-results.json').write_text(json.dumps(results,indent=2)+'\n', encoding='utf-8')
    with (ROOT/'team-tasks.csv').open('w',newline='',encoding='utf-8-sig') as f:
        writer = csv.writer(f)
        writer.writerow(['id','owner','scope','issue','title','remaining_hours','minimum_elapsed_days','technical_predecessors','state'])
        for k,t in TASKS.items():
            writer.writerow([k,t['owner'],t['scope'],t['issue'] or '',t['title'],t['hours'],t['minimum_elapsed_days'],' '.join(t['predecessors']),t['state']])
    for owner in range(1,6):
        lines = [f'# Developer {owner} issue and dependency map', '',
                 f'Owner: `{PLAN["owners"][str(owner)]}`. Capacity: 3 hours every day. '
                 'Estimates are provisional remaining effort; confirm status with PR/test/demo evidence.', '',
                 '[Shared CPM, ownership decisions and traceability](TEAM_DEPENDENCIES.md)', '',
                 '| ID / GitHub issue | Work | Scope | Hours | Technical blockers | State |',
                 '|---|---|---|---:|---|---|']
        for k,t in TASKS.items():
            if t['owner']==owner:
                lines.append(f'| {k} {link(k)} | {t["title"]} | {t["scope"]} | {t["hours"]} | '
                             + ', '.join(f'{p} {link(p)}' for p in t['predecessors']) + f' | {t["state"]} |')
        (ROOT/f'dev{owner}-issue-map.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print(json.dumps({s:{k:v for k,v in r.items() if k not in ('timing','schedule')} for s,r in results.items()},indent=2))
    print('Validated all 99 requirements, acyclic networks, handoff ordering and per-person capacity.')


if __name__ == '__main__':
    main()
