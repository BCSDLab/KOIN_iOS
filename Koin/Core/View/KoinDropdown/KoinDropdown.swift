//
//  KoinDropdown.swift
//  koin
//
//  Created by 홍기정 on 8/21/26.
//

import UIKit
import Combine

@MainActor
protocol KoinDropdownContentView: AnyObject {
    var dismissTappedPublisher: AnyPublisher<Void, Never> { get }
    var height: CGFloat { get }
}

@MainActor
final class KoinDropdown: UIView {
    
    // MARK: - Properties
    private weak var host: KoinDropdownHost?
    private(set) weak var trigger: UIView?
    private let configuration: KoinDropdownConfiguration
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let contentView: UIView & KoinDropdownContentView

    // MARK: - Animation
    let animator = KoinDropdownAnimator()
    private(set) var travel: CGFloat = 0

    // MARK: - Initializer
    init(
        host: KoinDropdownHost,
        trigger: UIView,
        contentView: UIView & KoinDropdownContentView,
        configuration: KoinDropdownConfiguration
    ) {
        self.host = host
        self.trigger = trigger
        self.contentView = contentView
        self.configuration = configuration
        super.init(frame: .zero)
        
        configureView()
        bind()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    private func bind() {
        contentView.dismissTappedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Public
    func toggle() {
        host?.toggle(self)
    }

    func present() {
        host?.present(self)
    }

    func dismiss() {
        host?.dismiss(self)
    }
}


extension KoinDropdown {
    func layout(in space: UIView) -> Bool {
        guard let trigger else { return false }
        contentView.transform = .identity

        let triggerFrame = trigger.convert(trigger.bounds, to: space)
        let panelHeight = contentView.height
        let padding = configuration.shadowPadding
        
        guard 0 < triggerFrame.width,
              0 < panelHeight else {
            return false
        }
        self.frame = CGRect(
            x: triggerFrame.minX - padding.left,
            y: triggerFrame.maxY,
            width: triggerFrame.width + padding.left + padding.right,
            height: configuration.topPadding + panelHeight + padding.bottom
        )
        contentView.frame = CGRect(
            x: padding.left,
            y: configuration.topPadding,
            width: triggerFrame.width,
            height: panelHeight
        )
        applyShadow()
        
        travel = panelHeight + configuration.topPadding
        return true
    }


    func animatePresent() {
        animator.present(view: contentView, travel: travel)
    }

    func animateDismiss(completion: @escaping () -> Void) {
        animator.dismiss(
            view: contentView,
            travel: travel,
            completion: completion
        )
    }
}

extension KoinDropdown {
    /// 프레임이 확정된 뒤에 부른다 — `shadowPath` 가 콘텐츠의 bounds 를 쓰기 때문이다.
    private func applyShadow() {
        let shadow = configuration.shadow
        contentView.layer.applySketchShadow(
            color: UIColor.appColor(shadow.color),
            alpha: shadow.alpha,
            x: shadow.offset.x,
            y: shadow.offset.y,
            blur: shadow.blur,
            spread: shadow.spread
        )
    }
}


extension KoinDropdown {
    private func configureView() {
        clipsToBounds = true
        backgroundColor = .clear
        addSubview(contentView)
    }
}
