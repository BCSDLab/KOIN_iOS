//
//  KoinDropdownViewController.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit
import Combine

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

    // MARK: - Layout State
    var travel: CGFloat = 0
    var lastLayoutSize: CGSize = .zero

    // MARK: - UI Components
    private let backgroundTapView = UIView()
    let panel = UIView()

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
            if let target = prepareScroll() {
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

        backgroundTapView.backgroundColor = .clear
        backgroundTapView.frame = view.bounds
        backgroundTapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundTapView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleOutsideTap)
            )
        )
        panel.backgroundColor = .clear
        panel.clipsToBounds = true
        view.addSubview(backgroundTapView)
        view.addSubview(panel)
        panel.addSubview(contentView)
    }
}
