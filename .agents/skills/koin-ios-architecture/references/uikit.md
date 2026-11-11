# UIKit screens

## ViewModel

```swift
protocol ViewModelProtocol {          // Koin/Core/Protocol/ViewModelProtocol.swift
    associatedtype Input
    associatedtype Output
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
```

- `enum Input` / `enum Output`, `private let outputSubject = PassthroughSubject<Output, Never>()`, `private var subscriptions: Set<AnyCancellable> = []`.
- `transform(with:)` sinks the input, switches on it, calls use cases, sends results through `outputSubject`.
- Dependencies come through `init`.

## ViewController

- `private let inputSubject = PassthroughSubject<ViewModel.Input, Never>()`; `bind()` subscribes to `viewModel.transform(with:)` with `.receive(on: DispatchQueue.main)`.
- Layout in code: `configureView()` → `setUpStyles()`, `setUpLayouts()`, `setUpConstraints()` with SnapKit; `Then` for one-shot configuration.
- Split large screens into `Subviews/` (table/collection view wrappers, cells).
- `UITableView` / `UITableViewCell` events go out through publishers (`PassthroughSubject`), not injected closures, unless the user asks for closures.
- Side effects and network calls stay in the ViewModel or lower layers.
- Navigation (push/present) happens in the ViewController after building dependencies with local `let`s.

## Reference files

- `Koin/Presentation/LostItem/LostItemList/LostItemListViewModel.swift`
- `Koin/Presentation/CallVan/CallVanNotification/` (ViewController + ViewModel + Subviews table view with publishers)
