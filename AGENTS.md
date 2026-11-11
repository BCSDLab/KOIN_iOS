# KOIN iOS — AI 작업 기준

이 파일은 Codex·Claude 등 이 저장소에서 작업하는 모든 AI가 먼저 읽는다. Claude Code는 `CLAUDE.md`를 통해 이 파일을 읽는다.

## 프로젝트
- UIKit + SwiftUI 혼합 앱. 화면 이동은 UIKit(`UINavigationController`)이 맡고, SwiftUI 화면은 HostingController로 감싼다.
- 비동기는 Combine, 레이아웃은 SnapKit·Then, 네트워크는 Alamofire.
- 레이어: `Presentation` → `Domain`(UseCase·Repository protocol) → `Data`(Repository·Service·DTO).

## 작업 원칙
- 고치기 전에 가장 가까운 기존 기능을 읽고 그 패턴을 따른다. 저장소 전체를 한 번에 정리하지 않는다.
- 요청에 없는 구조·추상화·이름·책임 분리를 새로 도입하지 않는다.
- 모호하면 구현을 멈추고 사용자에게 묻는다. 특히 명세 값(문구·label·value)을 추측해 만들지 않는다.
- 로깅·리팩터링 등을 하면서 UI 동작이나 비즈니스 흐름을 함께 바꾸지 않는다. 바꿔야 하면 먼저 묻는다.

## 코드 규칙
- 새 Swift 파일은 `koin.xcodeproj/project.pbxproj`에 등록하고 target membership을 확인한다.
- 의존성(UseCase·Repository·Service)은 화면을 만드는 곳에서 지역 `let`으로 만든 뒤 넘긴다. 이니셜라이저 인자 안에서 바로 생성하지 않는다.
- 접근 제어는 `private extension`보다 메서드별 `private func`를 쓴다. 기존 `private extension`은 일부러 바꾸지 않는다.
- `UITableView`·`UITableViewCell`의 이벤트는 기본적으로 publisher로 내보낸다. 사용자가 요청하지 않으면 클로저를 주입하지 않는다.
- 이미지는 `UIImage.appImage(asset:)` / `Image.appImage(asset:)`로만 쓴다. 문자열 이름(`UIImage(named:)`, `Image("…")`)을 쓰지 않는다.
- xcassets에 이미지를 추가하면 `Koin/Core/Asset/ImageAsset.swift`의 `// MARK: - <xcassets 폴더명>` 아래에 `.imageset` 이름 그대로 case를 추가한다.
- 색상은 `appColor(_: ColorAsset)`와 `ColorSystem`(`Koin/Core/DesignSystem/Color/ColorSystem.swift`)이 공존한다. 주변 코드가 쓰는 쪽을 따른다. 폰트는 `appFont(_:size:)` 또는 `Typography`.

## 커밋
- 한 커밋에 한 주제. 제목 한 줄, 한국어, `type: 내용` 형식 (`feat`, `fix`, `design`, `refactor`, `chore`, `log`).
- 사용자가 요청할 때만 커밋·push한다.

## 스킬 (`.agents/skills/`)
작업이 아래에 해당하면 해당 스킬을 먼저 읽는다.
- `koin-ios-architecture`: 화면 추가·수정, API 연결, UIKit/SwiftUI 구조, HostingController·ViewModel 규약.
- `koin-logging-implementation`: GA4 로깅 추가·수정, Notion 로깅 명세와 코드 대조.

스킬을 고치거나 추가할 때: 한 스킬에 한 주제, `SKILL.md`는 짧게 두고 자세한 내용은 `references/`에 둔다. description에 언제 써야 하는지(트리거 키워드)를 적는다. 코드가 바뀌어 스킬 내용이 틀려지면 같은 PR에서 스킬도 고친다.
