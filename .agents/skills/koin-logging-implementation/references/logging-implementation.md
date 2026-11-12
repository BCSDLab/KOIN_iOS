# KOIN Logging Implementation Reference

State after the 2026-11 logging migration (`refactor/logging-migration`).

## File map

| File | Role |
|---|---|
| `Koin/Core/Logger/EventParameter.swift` | `EventLabelType` + default derivation, new-spec label enums, `EventCategory` |
| `Koin/Domain/UseCase/Analytics/LogAnalyticsEventUseCase.swift` | `execute` API (new + legacy) |
| `Koin/Domain/Repository/AnalyticsRepository.swift`, `Koin/Data/Repository/GA4AnalyticsRepository.swift` | pass-through |
| `Koin/Data/Service/LogAnalyticsService.swift` | `GA4AnalyticsService`: builds parameters and sends to Firebase |
| `Koin/Core/Protocol/PopLoggable.swift`, `Koin/Core/View/UIKit/CustomNavigationController.swift` | back navigation click/swipe |
| `CustomSessionManager` | 15-minute sign-up session id |

## Label types

```swift
protocol EventLabelType {
    var rawValue: String { get }
    var screenView: String? { get }      // default: page segment
    var team: String { get }             // default: service segment → "DA1" / "DA2" (assert + "" if unknown)
}
extension EventLabelType {
    var lastSegment: String // used as event_category when the call passes none
}

```

Spec exception example (screen_view and category differ from the label):

```swift
enum SoldOutReport: String, EventLabelType {
    case cafeteriaDiningSoldoutStart = "cafeteria__dining__soldout__start"
    // ...
    var screenView: String? { "cafeteria" }   // page segment is "dining"
}
makeLogAnalyticsEvent(label: SoldOutReport.cafeteriaDiningSoldoutStart, value: value, category: .click)
```

Spec exception example (event_name differs from the service segment):

```swift
enum ForceUpdate: String, EventLabelType {
    case forcedUpdateAppUpdateExposure = "main__forced_update__app_update__exposure"
    // ...
    var team: String { "DA1" }                // service "main" would give DA2
}
```

## Use case API

```swift
// new spec
execute(label: EventLabelType, value: Any, category: EventParameter.EventCategory? = nil)
execute(label: EventLabelType, value: Any, parameters: [String: String])
```

## What the sender sends

- **event_name:** `label.team`. An empty team means the event is not sent.
- **Common parameters:** `event_label`, `event_category`, `value`, `gender`, `major`.
- **screen_view:** added only when `label.screenView` is not nil.
- **event_category:** the `category` argument, or else `EventCategory(rawValue: lastSegment)`. A debug assert fires when neither works.
- **Extra parameters:** merged as is (no reserved-key check). The caller limits them, e.g. `custom_session_id` is sent only from the sign-up inputs (`logSignUpEvent`).

## Patterns

### Normal event (SwiftUI or UIKit ViewModel)

```swift
enum Input {
    case logEvent(EventLabelType, Any)
}
case let .logEvent(label, value):
    logAnalyticsEventUseCase.execute(label: label, value: value)

// call site
viewModel.execute(.logEvent(EventParameter.EventLabel.Notice.mainNoticeNoticeDetailEntryClick, noticeId))
```

### UIKit container / tab bar / navigation bar

- Do not call the use case from the controller.
- Route through a `ViewModelProtocol` ViewModel (`transform(with:)`) with the same `logEvent(EventLabelType, Any)` input.

### Sign-up session

```swift
let sessionId = CustomSessionManager.getOrCreateSessionId(duration: .fifteenMinutes, eventName: "sign_up", loginStatus: 0, platform: "iOS")
logAnalyticsEventUseCase.execute(label: label, value: value, parameters: ["custom_session_id": sessionId])
```

### Back / exit

```swift
extension ShopViewController: PopLoggable {
    func sendPopLog(category: EventParameter.EventCategory) {
        let label: EventLabelType = category == .swipe
            ? EventParameter.EventLabel.Shop.shopListNavigationBackSwipe
            : EventParameter.EventLabel.Shop.shopListNavigationBackClick
        inputSubject.send(.logEvent(label, "메인"))
    }
}
```

- **Spec defines only click:** `guard category == .click else { return }`.
- **Pops done by code** (for example after a delete): set a flag and skip, as `RecruitDataHostingController.isDeleted` does.
- `CustomNavigationController` logs only real pops. It does not log pushes or cancelled swipes.
- `PopLoggable` works only inside `CustomNavigationController`. The window root is a single `CustomNavigationController` whose root is `HomeTabBarController`; tabs have no navigation controller of their own. Tab root screens are never popped, so `PopLoggable` applies to pushed screens only.

### Scroll

| Rule | Where |
|---|---|
| The spec defines a threshold | Notice list (`NoticeListTableView`). A stop is 200ms with no movement. Log the direction when the stop point moved at least 50pt from the previous stop. Moves made by code are not counted |
| No threshold in the spec | Log the first user scroll once per screen visit. Example: `willBeginDraggingPublisher.first()` in `ShopBenefitViewController`, `hasLoggedInitialScroll` in `ShopSummaryViewController` |

### Notification delete: click vs swipe

Home (`main__notification_list__…`), team recruit (`team_recruit__team_notification__…`) and callvan (`callvan__callvan_notification__…`) define both `delete__click` and `delete__swipe`.

```swift
let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, sourceView, completion in
    // A button tap leaves sourceView button-wide; a full swipe stretches it to nearly the row width.
    let isSwipe = sourceView.bounds.width > tableView.bounds.width / 2
    self?.deletePublisher.send((id: item.id, isSwipe: isSwipe))
    completion(true)
}
// subscriber
let label: EventLabelType = deletion.isSwipe ? …DeleteSwipe : …DeleteClick
```

- Shared views: `NotificationTableView` → `NotificationListView` (home, recruit). Callvan has its own `CallVanNotificationTableView`.
- Verified on a real device; not verified per iOS version.

### Filter bottom sheet close

`FilterBottomSheetView(onCloseTapped:)` fires on the X button only. It does not fire on a background tap or a drag.

## Value conventions seen in the spec

| Value | Format |
|---|---|
| Recruit post | `"\(category.rawValue)_\(id)"` |
| Shuttle route | `"{노선 구분}_{세부 노선}"` (for example "주중_천안역") |
| Timetable select | `"{연도}_{학기}_{시간표명}"`. Build it with `semester.reverseFormatSemester()` and replace `"년 "` with `"_"` |
| Notification list item | the category value (`NotificationHistoryItem.logValue`), never the title |
| Toggles | "켜짐" / "꺼짐" (sold-out meal: `"{아침\|점심\|저녁}_{켜짐\|꺼짐}"`) |
| Semester edit (timetable 2-13/2-14) | `"{추가\|삭제}_{연도}_{학기}"`, several joined with `,`. Add logs at apply, delete logs at the delete-confirm button |
| Force update exposure | `"v{CFBundleShortVersionString}"`, logged in `viewDidAppear` |

## Legacy labels

None. ForceUpdate (4 old labels) and Recruit `notification_list` moved to new contracts (supplementary specs 2026-11-11~12), and `LegacyEventParameter.swift` plus the old `execute(label:category:value:)` path were deleted. `EventCategory.pageExit` and `.update` went with them; force-update exit now uses `.exit`.

## Known not-implemented iOS specs (2026-11-10 export + supplements)

- None open. Timetable 2-13/2-14/2-23 were implemented (titles said "(웹, 반응형 앱)" but bodies define mobile behavior).
- **Excluded by decision:**
  - Bus 5-8: no X button on iOS.
  - Shop 2-3 / 4-3: events hidden.
  - Shop 4-2 / 4-4: the screen does not exist on iOS.
  - Shop 2-5~8: replaced by the quick filter.

## Tests

- **Do not add logging tests unless asked.**
- **Test doubles** (`StubLogAnalyticsEventUseCase`, `SpyLogAnalyticsEventUseCase`) implement only `execute(label:value:category:parameters:)`.
- **Old register logging tests** are wrapped in `#if false` (they still mention removed legacy APIs; they do not compile if re-enabled).

## Forbidden

- Force casts (`as!`). Capturing `self` without `[weak self]` in logging closures.
- Changing UI or business flow just to add a log.
- Inventing spec values. Changing existing raw labels on the side.
- Calling the use case directly from UIKit containers. Constructing use cases inline in initializer arguments.
