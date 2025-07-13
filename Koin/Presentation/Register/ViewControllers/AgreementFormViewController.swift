//
//  AgreementFormViewController.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit
import Combine

final class AgreementFormViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    private let inputSubject: PassthroughSubject<RegisterFormViewModel.Input, Never> = .init()
    private var agreementItems: [AgreementItemView] = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentView = UIView()
    
    private let stepTextLabel = UILabel().then {
        $0.text = "1. 약관 동의"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "1 / 4"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral200)
        $0.progressTintColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 0.25

        NSLayoutConstraint.activate([
            $0.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
        $0.backgroundColor = UIColor.appColor(.neutral300)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
    }
    
    private let agreementAllButton = UIButton(type: .system).then {
        let resizedImage = UIImage.appImage(asset: .checkEmptyCircle)?
            .resize(to: CGSize(width: 16, height: 16))
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .checkEmptyCircle)
        config.image = resizedImage
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.appColor(.primary500)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)

        var attrTitle = AttributedString("모두 동의합니다.")
        attrTitle.font = UIFont.appFont(.pretendardMedium, size: 14)
        config.attributedTitle = attrTitle

        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 5

        $0.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            updatedConfig?.baseForegroundColor = UIColor.appColor(.primary500)
            updatedConfig?.background.backgroundColor = UIColor.appColor(.neutral100)
            button.configuration = updatedConfig
        }
    }
    
    private let agreementStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }
    
    // MARK: - Init
    init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
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
        configureAgreementItems()
        setUpButtonTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
}

extension AgreementFormViewController {
    private func configureAgreementItems() {
        let item1 = AgreementItemView(title: "개인정보 이용약관 (필수)", text: AgreementText.personalInformation.description)
        let item2 = AgreementItemView(title: "코인 이용약관 (필수)", text: AgreementText.koin.description)
        let item3 = AgreementItemView(title: "마케팅수신 동의약관 (선택)", text: AgreementText.marketing.description)

        agreementItems = [item1, item2, item3]
        agreementItems.forEach { agreementStackView.addArrangedSubview($0) }
    }

    private func setUpButtonTargets() {
        agreementItems.forEach { item in
            item.checkButton.addTarget(self, action: #selector(individualAgreementTapped(_:)), for: .touchUpInside)
        }
        agreementAllButton.addTarget(self, action: #selector(allAgreementTapped(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func notifyAgreementState() {
        let requiredChecked = agreementItems[0].checkButton.isSelected && agreementItems[1].checkButton.isSelected
        
        nextButton.isEnabled = requiredChecked
        nextButton.backgroundColor = requiredChecked ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral300)
        nextButton.setTitleColor(requiredChecked ? .white : UIColor.appColor(.neutral600), for: .normal)
    }

    private func updateCheckboxImage(checkbox: UIButton, isSelected: Bool) {
        let original = isSelected ? UIImage.appImage(asset: .checkFilledCircle) : UIImage.appImage(asset: .checkEmptyCircle)
        let resized = original?.resize(to: CGSize(width: 16, height: 16))
        checkbox.setImage(resized, for: .normal)
    }

    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("푸시 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print(granted ? "사용자 푸시 알림 권한 허용" : "사용자 푸시 알림 권한 거부")
            }
        }
    }
}

extension AgreementFormViewController {
    @objc private func allAgreementTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateCheckboxImage(checkbox: sender, isSelected: sender.isSelected)
        agreementItems.forEach {
            $0.checkButton.isSelected = sender.isSelected
            updateCheckboxImage(checkbox: $0.checkButton, isSelected: sender.isSelected)
        }
        notifyAgreementState()
    }
    
    @objc private func individualAgreementTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateCheckboxImage(checkbox: sender, isSelected: sender.isSelected)

        let allSelected = agreementItems.allSatisfy { $0.checkButton.isSelected }
        agreementAllButton.isSelected = allSelected
        updateCheckboxImage(checkbox: agreementAllButton, isSelected: allSelected)

        notifyAgreementState()

        if sender == agreementItems[2].checkButton && sender.isSelected {
            requestPushNotificationPermission()
        }
    }
    
    @objc private func nextButtonTapped() {
        let viewController = CertificationFormViewController(viewModel: viewModel)
        viewController.title = "회원가입"
        navigationController?.pushViewController(viewController, animated: true)

        let customSessionId = CustomSessionManager.getOrCreateSessionId(eventName: "sign_up", userId: 0, platform: "iOS")
        inputSubject.send(.logSessionEvent(EventParameter.EventLabel.User.termsAgreement, .click, "약관동의", customSessionId))
    }
}

// MARK: UI Settings
extension AgreementFormViewController {
    private func setUpLayouts() {
        [stepTextLabel, stepLabel, progressView, nextButton].forEach {
            view.addSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [agreementAllButton, agreementStackView].forEach {
            contentView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        stepTextLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }

        stepLabel.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(3)
        }

        nextButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.height.equalTo(50)
            $0.horizontalEdges.equalToSuperview().inset(32)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(nextButton.snp.top).offset(-32)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        agreementAllButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(agreementAllButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    private func configureView() {
        view.backgroundColor = .white
        setUpLayouts()
        setUpConstraints()
    }
}

// MARK: - 체크박스 뷰
private final class AgreementItemView: UIStackView {
    let checkButton = UIButton(type: .system)
    let textView = UITextView()

    init(title: String, text: String) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 4

        let resizedImage = UIImage.appImage(asset: .checkEmptyCircle)?
            .resize(to: CGSize(width: 16, height: 16))

        var config = UIButton.Configuration.plain()
        config.image = resizedImage
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.appColor(.gray)

        var attrTitle = AttributedString(title)
        attrTitle.font = UIFont.appFont(.pretendardMedium, size: 14)
        config.attributedTitle = attrTitle
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        checkButton.configuration = config
        checkButton.contentHorizontalAlignment = .leading
        checkButton.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(22)
        }
        checkButton.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            updatedConfig?.baseForegroundColor = UIColor.appColor(.gray)
            updatedConfig?.background.backgroundColor = .clear
            button.configuration = updatedConfig
        }

        textView.text = text
        textView.textColor = UIColor.appColor(.neutral800)
        textView.font = UIFont.systemFont(ofSize: 9)
        textView.layer.borderColor = UIColor(hexCode: "D2DAE2").cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.snp.makeConstraints { $0.height.equalTo(120) }

        [checkButton, textView].forEach {
            addArrangedSubview($0)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
