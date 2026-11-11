//
//  KoinBottomSheetController.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit
import SnapKit
import Then

@MainActor
final class KoinBottomSheetController: UIViewController {
    enum State {
        case presenting
        case presented
        case dismissing
        case dismissed
    }

    // MARK: - Configuration
    private(set) weak var owner: UIViewController?
    var configuration: KoinBottomSheetConfiguration
    let contentViewController: KoinBottomSheetContentViewController
    var isModal: Bool {
        if case .modal = configuration.style {
            return true
        }
        return false
    }
    var ownerWindowObserver: UIView?

    // MARK: - State
    var state: State = .presenting
    var isActive: Bool {
        state == .presenting || state == .presented
    }
    var isDismissing: Bool {
        state == .dismissing
    }
    var isFullScreen = false
    /// 바깥 전체 터치를 막는지. modal은 항상, nonModal은 fullscreen일 때만.
    var blocksOutside: Bool {
        isModal || isFullScreen
    }
    /// dim이 받아 시트를 닫을 터치. 바깥 전체를 막지 않을 때도 nav 영역(상단 한계 위)은 받는다.
    func dimReceivesTouch(at point: CGPoint) -> Bool {
        guard !blocksOutside else { return true }
        guard let host = view.superview, let topLimitY else { return false }
        return dimView.convert(point, to: host).y < topLimitY
    }
    /// nonModal fullscreen의 dim 농도.
    static let nonModalFullScreenDimAlpha: CGFloat = 0.7
    var didExpandForKeyboard = false

    // MARK: - Closure
    var pendingAction: (() -> Void)?

    // MARK: - Layout
    var resolvedHeight: CGFloat = 0
    var lastContext: KoinBottomSheetContext?
    var heightConstraint: NSLayoutConstraint?
    /// 콘텐츠 하단과 시트 하단 사이 간격. 키보드를 닫으며 끄는 동안만 0보다 크다.
    var contentBottomConstraint: Constraint?

    // MARK: - Animation
    var animator: UIViewPropertyAnimator?

    // MARK: - Gesture
    var panState: PanState?
    var panTracking = PanTracking()
    var navigationObservation: NSKeyValueObservation?

    // MARK: - Keyboard
    var keyboardState = KeyboardState()

    // MARK: - UI Components
    let dimView = DimView().then {
        $0.backgroundColor = .appColor(.neutral800)
        $0.alpha = 0
    }
    let sheetView = UIView()
    let containerView = UIView()

    // MARK: - Initializer
    init(
        contentViewController: KoinBottomSheetContentViewController,
        owner: UIViewController,
        configuration: KoinBottomSheetConfiguration
    ) {
        self.contentViewController = contentViewController
        self.owner = owner
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    deinit {
        NotificationCenter.default.removeObserver(self)
        keyboardState.timeout?.cancel()
    }

    override func loadView() {
        view = isModal ? UIView() : PassThroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        observeKeyboard()
        configurePan()
        hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard state != .dismissed else { return }
        if configuration.showsShadow {
            // path를 지정해 애니메이션 중 매 프레임 그림자 모양을 다시 계산하지 않게 한다.
            containerView.layer.shadowPath = UIBezierPath(
                roundedRect: containerView.bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: configuration.cornerRadius, height: configuration.cornerRadius)
            ).cgPath
        }
        updateHeightIfNeeded()
    }

    // MARK: - Presentation
    func presentSheet() {
        installHostGuideConstraintsIfNeeded()
        view.superview?.layoutIfNeeded()
        view.layoutIfNeeded()
        guard owner?.viewIfLoaded?.window != nil else {
            teardown()
            return
        }
        observeOwnerWindow()
        updateHeightIfNeeded()
        updateNavigationGesture()
        containerView.transform = CGAffineTransform(
            translationX: 0,
            y: view.bounds.maxY - containerView.frame.minY
        )
        animateToTarget(animated: true)
    }

    func dismissForReplacement() {
        pendingAction = nil
        beginDismissal(isReplacement: true)
    }

    private func observeOwnerWindow() {
        guard let ownerView = owner?.viewIfLoaded else { return }
        let observer = OwnerWindowObserverView().then {
            $0.isHidden = true
        }
        observer.onWindowChange = { [weak self] in
            guard let self, self.owner?.viewIfLoaded?.window == nil else { return }
            // 전환 중 잠깐 떼었다 붙는 경우를 거르려고 다음 runloop에서 다시 확인한다.
            DispatchQueue.main.async { [weak self] in
                guard let self, self.state != .dismissed,
                      self.owner?.viewIfLoaded?.window == nil else { return }
                self.teardown()
            }
        }
        ownerView.addSubview(observer)
        ownerWindowObserver = observer
    }
}

/// dim이 투명(alpha 0)해도 시트 바깥 탭을 받아 닫는다. UIKit 기본 hitTest는 alpha 0.01 미만을 건너뛴다.
final class DimView: UIView {
    var receivesTouch: ((CGPoint) -> Bool)?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, self.point(inside: point, with: event) else { return nil }
        return receivesTouch?(point) ?? true ? self : nil
    }
}

private final class OwnerWindowObserverView: UIView {
    var onWindowChange: (() -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onWindowChange?()
    }
}
