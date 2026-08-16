//
//  KoinModalViewController.swift
//  koin
//
//  Created by 홍기정 on 8/15/26.
//

import UIKit
import Combine
import SnapKit
import Then

class KoinModalViewController: UIViewController {
    
    // MARK: - Properties
    private let configuration: KoinModalConfiguration
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView = UIView()
    private var contentView: ModalContentView
    private let buttonView: ModalButtonView
    
    // MARK: - Initializer
    init(configuration: KoinModalConfiguration) {
        self.configuration = configuration
        self.contentView = ModalContentView(configuration: configuration)
        self.buttonView = ModalButtonView(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
        configureTransition()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGestureRecognizer()
        configureView()
        bind()
    }
    
    // MARK: - Bind
    private func bind() {
        buttonView.leftButtonTappedPublisher.sink { [weak self] in
            self?.leftButtonTapped()
        }.store(in: &subscriptions)
        
        buttonView.rightButtonTappedPublisher.sink { [weak self] in
            self?.rightButtonTapped()
        }.store(in: &subscriptions)
    }
    
    func leftButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.configuration.button?.leftButtonAction?()
        }
    }
    
    func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.configuration.button?.rightButtonAction()
        }
    }
}

extension KoinModalViewController: UIViewControllerTransitioningDelegate {
    private func configureTransition() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        KoinModalAnimator(transitionType: .present)
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        KoinModalAnimator(transitionType: .dismiss)
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        KoinModalPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}

extension KoinModalViewController {
    private func setUpGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideOfContainerView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapOutsideOfContainerView(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}

extension KoinModalViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = .clear
        
        containerView.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 8
        }
    }
    
    private func setUpLayouts() {
        [contentView, buttonView].forEach {
            containerView.addSubview($0)
        }
        [containerView].forEach {
            view.addSubview($0)
        }
        
        if configuration.button == nil {
            buttonView.removeFromSuperview()
        }
    }
    private func setUpConstraints() {
        if let _ = configuration.button {
            contentView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(configuration.layout.contentTopPadding)
                $0.leading.equalToSuperview().offset(configuration.layout.contentHorizontalPadding)
                $0.trailing.equalToSuperview().offset(-configuration.layout.contentHorizontalPadding)
            }
            buttonView.snp.makeConstraints {
                $0.top.equalTo(contentView.snp.bottom).offset(configuration.layout.paddingBetweenContentAndButton)
                $0.leading.equalToSuperview().offset(configuration.layout.buttonHorizontalPadding)
                $0.trailing.equalToSuperview().offset(-configuration.layout.buttonHorizontalPadding)
                $0.bottom.equalToSuperview().offset(-configuration.layout.buttonBottomPadding)
            }
        } else {
            contentView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(configuration.layout.contentTopPadding)
                $0.leading.equalToSuperview().offset(configuration.layout.contentHorizontalPadding)
                $0.trailing.equalToSuperview().offset(-configuration.layout.contentHorizontalPadding)
                $0.bottom.equalToSuperview().offset(-configuration.layout.contentBottomPadding)
            }
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(configuration.layout.width)
        }
    }
}
