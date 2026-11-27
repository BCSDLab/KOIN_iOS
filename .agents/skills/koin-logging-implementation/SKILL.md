---
name: koin-logging-implementation
description: This skill should be used when working in the KOIN iOS repo to implement, review, or refactor analytics/event logging; when the user mentions 로깅, logging, GA4, LogAnalyticsEventUseCase, EventParameter, EventLabelType, PopLoggable, 뒤로가기 로깅, 스크롤 로깅, 회원가입 세션(custom_session_id), or asks to compare the Notion logging spec (Event Log export) with iOS code. Follow this skill before editing logging-related Swift files.
version: 0.3.0
---

# KOIN Logging Implementation

Use this skill to add or review GA4 event logging in KOIN iOS after the 2026-11 logging migration (`refactor/logging-migration`).

Detailed reference: `references/logging-implementation.md` (code snippets, sender behavior, file map).

## Label grammar

```text
service__page__feature[__detail]__category      4~5 segments, "__" between segments, "_" inside a segment
```

| GA4 field | Source |
|---|---|
| event_name (team) | service segment → `DA1` (shop, cafeteria, bus, timetable, real_estate, owner, ticket, team_recruit) / `DA2` (main, banner, board, account, callvan, chat, department, facility, course_practice). Override `team` in the enum only when the spec's event_name differs, and confirm with the user first (example: `ForceUpdate` labels are `main__…` but DA1) |
| screen_view | page segment. Override in the enum only when the spec's screen_view differs |
| event_category | last segment. Pass `category:` at the call only when the spec's category differs |
| event_label | the raw label |
| value | built at the call site in the spec's format |

## Spec handling

1. Spec = Notion "Event Log" export. Ask the user for the latest export path.
2. Ignore the `Event Log (과거)` folder and guide/dictionary pages.
3. Target only pages whose `platform` includes `IOS`.
4. Skip pages marked 레거시 in the title, folder, status, or body ("레거시: …로 통합").
5. Read the "새 로깅" section: `screen_view`, `event_label`, `value`, `event_category`, `설명` (exact trigger).
6. Titles like "(웹, 반응형 앱)" can still define mobile behavior in the body. Read the body before excluding.
7. Decide the contract:
   - New-spec contract exists → implement it (even if an old one also exists).
   - Only an old contract exists → ask the user. The old-spec path (`LegacyEventParameter`) was deleted in 2026-11 once every old label had a new contract; do not recreate it without a decision.
   - No spec → leave existing code as is.
   - Supplementary spec pages (zip exports sent after the main export) override the main export for the same feature.
8. Copy `event_label` raw values exactly. Never invent a missing value, category, or screen.

## Implementation rules

- Add new labels to the domain enum in `EventParameter.EventLabel` (`Shop`, `Bus`, `Notice`, `Account`, `LostItem`, `Dining`, `CallVan`, `Recruit`, `Department`, `RealEstate`, `Timetable`, `Home.DA1/DA2`, …). Create a domain enum if none exists.
- Case name = camelCase of the label without the service segment (keep the service in mixed enums like `Home.DA1/DA2`).
- `team` is a protocol requirement with a default, so an enum override is dispatched. A new service segment must also be added to the `team` switch in `EventLabelType`. If it is missing, debug builds assert and release builds drop the event.
- ViewModel input for new labels: `case logEvent(EventLabelType, Any)`. Call `logAnalyticsEventUseCase.execute(label:value:)`.
- Add `category:` only for spec exceptions (example: `Dining.SoldOutReport`).
- Extra GA4 parameters go through `execute(label:value:parameters:)` and are sent as is. Do not reuse a common key (`event_label`, `event_category`, `value`, `gender`, `major`, `screen_view`); nothing blocks it.
- Inject `LogAnalyticsEventUseCase` at the construction site with a local `let`. Never construct use cases inline in initializer arguments. ViewModels that already create their use cases as `lazy var` follow that local pattern.
- Register new Swift files in `koin.xcodeproj/project.pbxproj`.

## Team decisions (keep consistent)

- **Log only when the action really happens.** Put the log after login, validation, and state guards. For logged-out taps, the login-popup logs cover the case.
- **Do not log a re-select.** Tapping the tab, category, corner, or timetable that is already selected sends nothing.
- **Back navigation:**
  - Use `PopLoggable` + `CustomNavigationController` (click vs swipe).
  - If the spec defines only click, ignore swipe.
  - Exclude pops done by code, such as the automatic pop after a delete.
  - Never add duplicate `viewWillDisappear` logs.
- **Scroll:**
  - Follow the spec when it defines a threshold. The notice list stops after 200ms and needs at least 50pt from the previous stop.
  - Otherwise log the first user scroll once per screen visit, as the shop detail menu and the benefit screen do.
- **Notification delete click/swipe:** when the spec has both `…__delete__click` and `…__delete__swipe`, decide in the `UIContextualAction` handler: `sourceView.bounds.width > tableView.bounds.width / 2` means a full swipe (a button tap is only button-wide). Log a completed full swipe as a delete too. The default `commit editingStyle` delete cannot tell the two apart, so use a contextual action that looks the same.
- **Values:** never send raw user content such as notification titles or bodies, unless the spec asks for it.
- **Tests:** do not add logging tests unless asked. When a protocol changes, only adapt the test doubles. Disable (`#if false`) tests whose logic depends on removed logging, instead of rewriting them.

## Final checklist

- Spec page includes `IOS`, is not legacy, and the contract is from "새 로깅".
- Raw label is copied exactly. Team, screen_view, and category resolve to the spec values, or exceptions are explicit.
- The log fires exactly when `설명` says: after guards, not on re-select, not twice.
- The value matches the spec format.
- A new service is in the `team` switch, and new dependencies are injected at construction sites.
- No old-spec (non `service__page__…`) labels.
- Build passes.
