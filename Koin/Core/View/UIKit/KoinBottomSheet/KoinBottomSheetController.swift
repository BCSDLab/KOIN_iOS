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

    // MARK: - State
    var state: State = .presenting
    var isActive: Bool {
        state == .presenting || state == .presented
    }
    var isDismissing: Bool {
        state == .dismissing
    }
    var isFullScreen = false
    var didExpandForKeyboard = false

    // MARK: - Closure
    var pendingAction: (() -> Void)?

    // MARK: - Layout
    var resolvedHeight: CGFloat = 0
    var lastContext: KoinBottomSheetContext?
    var heightConstraint: NSLayoutConstraint?

    // MARK: - Animation
    var animator: UIViewPropertyAnimator?

    // MARK: - Gesture
    var panState: PanState?
    var panTracking = PanTracking()
    var navigationObservation: NSKeyValueObservation?

    // MARK: - Keyboard
    var keyboardState = KeyboardState()

    // MARK: - UI Components
    let dimView = UIView().then {
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
        updateHeightIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if state != .dismissed, owner?.viewIfLoaded?.window == nil {
            teardown()
        }
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
}
