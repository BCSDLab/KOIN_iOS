//
//  KoinDropdownViewController.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit
import Combine
import Then

@MainActor
final class KoinDropdownViewController: UIViewController {

    // MARK: - Properties
    weak var anchor: UIView?
    let contentView: UIView & KoinDropdownContentView
    let configuration: KoinDropdownConfiguration
    let animator = KoinDropdownAnimator()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Presentation State
    var isPresented = false
    var isDismissing = false
    var isDismissed = false

    // MARK: - Scroll State
    weak var scrollView: UIScrollView?
    var addedBottomInset: CGFloat = 0
    var isScrollPrepared = false

    // MARK: - Layout State
    var travel: CGFloat = 0
    var lastLayoutSize: CGSize = .zero
    var resolvedDirection: KoinDropdownConfiguration.ResolvedDirection = .down
    var fitsInResolvedDirection = false
    var hiddenOffsetY: CGFloat {
        resolvedDirection == .down ? -travel : travel
    }

    // MARK: - UI Components
    let panel = UIView()
    /// 부모 화면에 붙여 바깥 터치를 받는다. 탭은 뒤 화면에 전달하지 않고, 스크롤(pan)은 통과시킨다.
    lazy var outsideTouchRecognizer = OutsideTouchGestureRecognizer(
        target: self,
        action: #selector(handleOutsideTouch)
    ).then {
        $0.delaysTouchesBegan = true
        $0.delegate = self
    }

    // MARK: - Initializer
    init(
        anchor: UIView,
        contentView: UIView & KoinDropdownContentView,
        configuration: KoinDropdownConfiguration
    ) {
        self.anchor = anchor
        self.contentView = contentView
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func loadView() {
        // 패널 밖 터치는 아래로 넘기고, 바깥 처리는 outsideTouchRecognizer가 맡는다.
        view = PassThroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(
            to: size,
            with: coordinator
        )
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard isPresented, !isDismissing else { return }

        if view.bounds.size != lastLayoutSize {
            // inset 조정이 layout을 다시 일으킬 수 있으므로, 조정 전에 크기를 먼저 기록한다.
            lastLayoutSize = view.bounds.size
            resolveDirection()
            if let target = prepareScrollIfNeeded() {
                scrollView?.contentOffset = target
            }
        }
        layoutPanel()
    }
}

// MARK: - Bind
extension KoinDropdownViewController {
    private func bind() {
        contentView.dismissTappedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismissDropdown()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Configure View
extension KoinDropdownViewController {
    private func configureView() {
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        panel.backgroundColor = .clear
        panel.clipsToBounds = true
        view.addSubview(panel)
        panel.addSubview(contentView)
    }
}

// MARK: - Outside Touch
extension KoinDropdownViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        // 닫히기 시작한 뒤의 터치는 평소처럼 뒤 화면이 받는다.
        !isDismissing && !panel.bounds.contains(touch.location(in: panel))
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // 스크롤·시트 드래그는 그대로 진행되고 드롭다운만 닫힌다.
        otherGestureRecognizer is UIPanGestureRecognizer
    }
}

/// 터치가 닿는 즉시 인식한다. 인식되면 뒤 화면의 버튼·셀·탭 제스처는 그 터치를 받지 못한다.
final class OutsideTouchGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if state == .possible { state = .began }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
