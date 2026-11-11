# SwiftUI screens

SwiftUI is added on top of the UIKit app. UIKit keeps control of navigation; SwiftUI renders content and emits actions.

## Protocols (`Koin/Core/Protocol/`)

```swift
protocol ActionBindableView: View {
    associatedtype Action
    var sendAction: ((Action) -> Void) { get set }
}

@MainActor
protocol HostingControllerProtocol: AnyObject {
    associatedtype RootView: ActionBindableView
    var rootView: RootView { get set }
    func execute(action: RootView.Action)
}
// extension: bindAction(to:) wires rootView.sendAction → execute(action:)

@MainActor
protocol SwiftUIViewModelProtocol: AnyObject {
    associatedtype Input
    func execute(_ input: Input)
}
```

## Pattern

```swift
@MainActor
final class CategoryHostingController: UIHostingController<CategoryView>, HostingControllerProtocol {
    override init(rootView: CategoryView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }
    func execute(action: RootView.Action) {
        switch action {
        case .showShop: navigationController?.pushViewController(makeShopViewController(), animated: true)
        case .showLoginToast: showToastMessageWithButton(message: "…", buttonTitle: "로그인") { … }
        }
    }
}

struct CategoryView: ActionBindableView {
    enum Action { case showShop, showLoginToast }
    @State private var viewModel: CategoryViewModel
    var sendAction: ((Action) -> Void) = { _ in }
}

@Observable @MainActor
final class CategoryViewModel: SwiftUIViewModelProtocol {
    enum Input { case checkAuth }
    private var subscriptions = Set<AnyCancellable>()
    func execute(_ input: Input) { /* use case .sink { … } */ }
}
```

Example: `Koin/Presentation/Home/Category/`.

## Rules

- One concrete HostingController per screen. No shared base hosting controller.
- The View receives only `sendAction`. Push, present, pop, dismiss and toast go through `sendAction` → `execute(action:)` in the HostingController.
- Pure UI actions (close, fixed navigation) can call `sendAction` directly from the View. When business logic decides, go ViewModel → state → View → `sendAction`.
- ViewModels never touch `UINavigationController`, ViewControllers, toast, or dismiss. They expose state; the View forwards it.
- Use cases stay Combine-based (`.sink`, `subscriptions`). Do not introduce async/await or new task containers in a feature without asking.
- Do not add `NavigationStack`. Use the UIKit navigation bar and `UITabBarController`.
- The View does not create services, repositories, or use cases.

## View helpers (`Koin/Core/Extensions/SwiftUI/`)

`.isHidden(_:shouldOccupySpace:)`, `.onFirstAppear(_:)`, `.loadingOverlay(_:)`, `.emptyOverlay(…)`, `.applySketchShadow(color:alpha:x:y:blur:)`, `.hideKeyboardWhenTapAround()`, `.border(…)`, `.linespacing(…)`, plus `Color+`, `Font+`, `Image+` bridges.

- Helpers handle view-local presentation only. They never navigate, show toasts, or look up ViewControllers.
- Reuse UIKit components (bottom sheet, modal, picker, toast) through the HostingController instead of re-implementing them as helpers.
