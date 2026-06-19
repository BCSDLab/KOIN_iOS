//
//  ForceUpdateViewController.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine
import UIKit
import SnapKit
import Lottie

@MainActor
protocol ForceUpdateViewControllerCoordinator: AnyObject {
    func updateButtonTapped()
    func errorCheckButtonTapped(
        presentOn presenter: UIViewController,
        onOpenStoreButtonTapped: @escaping () -> Void,
        onCancelButtonTapped: @escaping () -> Void
    )
}

final class ForceUpdateViewController: UIViewController, LottieAnimationManageable {
    
    // MARK: - LottieAnimationManageable Protocol
    var lottieAnimationView: LottieAnimationView {
        return logoAnimationView
    }
    
    // MARK: - Properties
    private let viewModel: ForceUpdateViewModel
    private let inputSubject: PassthroughSubject<ForceUpdateViewModel.Input, Never> = .init()
    var subscriptions: Set<AnyCancellable> = []
    weak var coordinator: ForceUpdateViewControllerCoordinator?
    
    // MARK: - UI Components
    private let contentViewLayoutGuide = UILayoutGuide()
    
    private let contentView = UIView()
    
    private let logoAnimationView = LottieAnimationView().then {
        $0.animation = LottieAnimation.named("waveLogo")
        $0.loopMode = .loop
        $0.animationSpeed = 1.0
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
    }
    
    private let titleLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributedText = NSMutableAttributedString(
            string: "코인을 사용하기 위해\n업데이트가 필요해요",
            attributes: [
                .font: UIFont.appFont(.pretendardBold, size: 20),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.appColor(.neutral700)
            ]
        )
        $0.attributedText = attributedText
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let descriptionLabel = UILabel().then {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributedText = NSMutableAttributedString(
            string: "코인을 사용하기 위해 아래 버튼을 눌러\n스토어에서 업데이트를 진행해 주세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.appColor(.neutral700)
            ]
        )
        $0.attributedText = attributedText
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let updateButton = UIButton().then {
        $0.setTitle("업데이트하기", for: .normal)
        $0.backgroundColor = UIColor.appColor(.new500)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 15)
        $0.layer.cornerRadius = 8
    }
    
    private let errorCheckButton = UIButton().then {
        let attributedTitle = NSAttributedString(
            string: "이미 업데이트를 하셨나요?",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor: UIColor.appColor(.new800),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.backgroundColor = .clear
    }
    
    // MARK: - Initialization
    init(
        viewModel: ForceUpdateViewModel,
        coordinator: ForceUpdateViewControllerCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        clearLottieAnimation()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        setAddTarget()
        setupLottie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLottieAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func bind() {
        let _ = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
    }
    
    private func setAddTarget() {
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        errorCheckButton.addTarget(self, action: #selector(errorCheckButtonTapped), for: .touchUpInside)
    }
    
    private func setupCustomNotificationObservers() {
        // 백그라운드 진입 시
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forceUpdateExit, .pageExit, "홈버튼"))
            }.store(in: &subscriptions)
    }
}

extension ForceUpdateViewController {
    @objc private func updateButtonTapped() {
        coordinator?.updateButtonTapped()
        inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forceUpdateConfirm, .update, "업데이트하기"))
    }
    
    @objc private func errorCheckButtonTapped() {
        coordinator?.errorCheckButtonTapped(presentOn: self) { [weak self] in
            self?.coordinator?.updateButtonTapped()
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.alreadyUpdatePopup, .click, "스토어로 가기"))
        } onCancelButtonTapped: { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.alreadyUpdatePopup, .click, "확인"))
        }
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forceUpdateAlreadyDone, .click, "이미업데이트"))
    }
}

extension ForceUpdateViewController {
    private func setUpLayOuts() {
        [contentView, logoAnimationView, titleLabel, descriptionLabel, errorCheckButton, updateButton].forEach {
            view.addSubview($0)
        }
        
        [contentViewLayoutGuide].forEach {
            view.addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        contentViewLayoutGuide.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(updateButton.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.center.equalTo(contentViewLayoutGuide)
        }
        
        logoAnimationView.snp.makeConstraints {
            $0.top.centerX.equalTo(contentView)
            $0.width.equalTo(237)
            $0.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoAnimationView.snp.bottom).offset(16)
            $0.centerX.equalTo(contentView)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.centerX.bottom.equalTo(contentView)
        }
        
        updateButton.snp.makeConstraints {
            $0.bottom.equalTo(errorCheckButton.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(46)
        }
        
        errorCheckButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-14)
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(234)
            $0.height.greaterThanOrEqualTo(19)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral0)
    }
}
