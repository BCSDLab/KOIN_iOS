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

final class ForceUpdateViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ForceUpdateViewModel
    private let inputSubject: PassthroughSubject<ForceUpdateViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let logoAnimationView = LottieAnimationView().then {
        $0.animation = LottieAnimation.named("waveLogo")
        $0.loopMode = .loop
        $0.animationSpeed = 1.0
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
                .underlineStyle: NSUnderlineStyle.single.rawValue // 여기에 'none' 값을 주어도 기본 설정은 밑줄 없음
            ]
        )
        
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.backgroundColor = .clear
    }
    
    private let updateModalViewController = UpdateModelViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    // MARK: - Initialization
    init(viewModel: ForceUpdateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        setAddTarget()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.isHidden = true
        logoAnimationView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        navigationController?.navigationBar.isHidden = false
        logoAnimationView.stop()
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let.isLowVersion(isLow):
                
                if !isLow {
                    self?.dismiss()
                }
            }
        }.store(in: &subscriptions)
        
        updateModalViewController.openStoreButtonPublisher.sink { [weak self] in
            self?.openStore()
        }.store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forceUpdateExit, .pageExit, "홈버튼"))
            }.store(in: &subscriptions)
        
        // 포그라운드로 돌아올 시 알림
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.inputSubject.send(.checkVersion)
            }.store(in: &subscriptions)
        
        updateModalViewController.openStoreButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.alreadyUpdatePopup, .click, "스토어로 가기"))
        }.store(in: &subscriptions)
        
        updateModalViewController.cancelButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.alreadyUpdatePopup, .click, "확인"))
        }.store(in: &subscriptions)
    }
    
    private func setAddTarget() {
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        errorCheckButton.addTarget(self, action: #selector(errorCheckButtonTapped), for: .touchUpInside)
    }
}

extension ForceUpdateViewController {
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func updateButtonTapped() {
        openStore()
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forceUpdateConfirm, .update, "업데이트하기"))
    }
    
    private func openStore() {
        if let url = URL(string: "https://itunes.apple.com/app/id1500848622"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func errorCheckButtonTapped() {
        present(updateModalViewController, animated: true, completion: nil)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forceUpdateAlreadyDone, .click, "이미업데이트"))
    }
}

extension ForceUpdateViewController {
    
    private func setUpLayOuts() {
        [logoAnimationView, titleLabel, descriptionLabel, errorCheckButton, updateButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        logoAnimationView.snp.makeConstraints {
            $0.top.lessThanOrEqualTo(view.snp.top).offset(230.5)
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(237)
            $0.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoAnimationView.snp.bottom).offset(16)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.centerX.equalTo(view.snp.centerX)
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
