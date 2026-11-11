---
name: koin-ios-architecture
description: Use when adding or changing screens, features, or API flows in the KOIN iOS repo — UIKit ViewControllers, SwiftUI views hosted in UIHostingController, ViewModels (Combine `transform(with:)` or `@Observable` `execute(_:)`), API → Service → Repository → UseCase chains, design tokens, or new Swift files. Triggers on 화면 추가, 기능 수정, API 연결, HostingController, sendAction, ViewModel, SwiftUI, UIKit, Repository, UseCase.
version: 0.1.0
---

# KOIN iOS Architecture

Follow the patterns that exist in the nearest feature. This skill lists them; read the reference for the UI framework you touch.

- UIKit screen → `references/uikit.md`
- SwiftUI screen (or a UIKit screen that hosts SwiftUI) → `references/swiftui.md`

## Layers (shared by UIKit and SwiftUI)

```text
Presentation (ViewController / HostingController + View, ViewModel)
  → Domain/UseCase/<Feature>/Default…UseCase      (protocol + Default implementation)
  → Domain/Repository/<…>Repository                (protocol)
  → Data/Repository/Default…Repository
  → Data/Service/<Feature>Service.swift            (Default…Service, calls NetworkService.shared)
  → Data/Service/Network/API/<Feature>API.swift    (Router enum: path, method, headers, encoding)
  DTOs: Data/DTOs/Encodable (request), Data/DTOs/Decodable (response)
```

- `NetworkService` offers both Combine (`AnyPublisher<_, ErrorResponse>`) and `async throws` variants. Use the one the feature's service already uses.
- Map DTOs to domain models only where the feature already does.

## Wiring

- The screen that navigates builds the next screen's dependencies with local `let`s, then passes them in. Never construct use cases inline in initializer arguments.
- Some older ViewModels create their own use cases (`TimetableViewModel`). Keep that inside that feature; do not copy it to new code.
- `DIContainer` is unused here. Do not wire new code through it.
- Navigation code lives in ViewControllers / HostingControllers today. A coordinator refactor is planned separately; do not start it inside feature work.

## Shared UI pieces

| Need | Use |
|---|---|
| Color | `UIColor.appColor(_:)` / `Color.appColor(_:)` with `ColorAsset`, or `UIColor.ColorSystem.*` / `Color.ColorSystem.*` (`Koin/Core/DesignSystem/Color/ColorSystem.swift`). Both exist; follow the surrounding code |
| Font | `UIFont.appFont(_:size:)` / `Font.appFont(_:size:)` with `FontAsset`, or `Typography` (`.Typography(.body1)` in SwiftUI) |
| Image | `UIImage.appImage(asset:)` / `Image.appImage(asset:)` with `ImageAsset`. Never string names |
| Toast | `showToastMessage(message:intent:)`, `showToastMessageWithButton(...)` on `UIViewController` |
| Modal / sheet | `KoinModalViewController`, `presentBottomSheet(_:configuration:)` (`KoinBottomSheet`) |
| Back navigation logging | `PopLoggable` + `CustomNavigationController` (see the logging skill) |

Reusable UIKit views live in `Koin/Core/View/UIKit`, extensions in `Koin/Core/Extensions/{UIKit,SwiftUI,Common}`, protocols in `Koin/Core/Protocol`.

## Before finishing

- New files are registered in `koin.xcodeproj/project.pbxproj` with the right target.
- Naming matches siblings (`Default…UseCase`, `Default…Repository`, `…ViewModel`, `…HostingController`, `Subviews/`).
- No UI or business flow changed beyond the request.
