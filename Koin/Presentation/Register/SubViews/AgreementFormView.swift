//
//  AgreementFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit

final class AgreementFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    var onRequiredAgreementsChanged: ((Bool) -> Void)?
    
    // MARK: - UI Components
    private let agreementAllButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .checkEmptyCircle)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.appColor(.primary500)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        config.background.backgroundColor = .clear
        config.background.strokeColor = .clear

        var attrTitle = AttributedString("모두 동의합니다.")
        attrTitle.font = UIFont.appFont(.pretendardMedium, size: 14)
        config.attributedTitle = attrTitle

        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 5
    }
    
    private let agreementStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }
    
    private let agreementCheckButton1 = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .checkEmptyCircle)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.appColor(.gray)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        config.background.backgroundColor = .clear
        config.background.strokeColor = .clear

        var attrTitle = AttributedString("개인정보 이용약관 (필수)")
        attrTitle.font = UIFont.appFont(.pretendardMedium, size: 14)
        config.attributedTitle = attrTitle

        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.backgroundColor = .clear
    }

    private let agreementTextView1 = UITextView().then {
        $0.text = AgreementText.personalInformation.description
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.systemFont(ofSize: 9)
        $0.layer.borderColor = UIColor.appColor(.lightGray).cgColor
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 5.0
        $0.isEditable = false
        $0.isScrollEnabled = true
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    private let agreementCheckButton2 = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .checkEmptyCircle)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.appColor(.gray)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        config.background.backgroundColor = .clear
        config.background.strokeColor = .clear

        var attrTitle = AttributedString("코인 이용약관 (필수)")
        attrTitle.font = UIFont.appFont(.pretendardMedium, size: 14)
        config.attributedTitle = attrTitle

        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.backgroundColor = .clear
    }
    
    private let agreementTextView2 = UITextView().then {
        $0.text = AgreementText.koin.description
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.systemFont(ofSize: 9)
        $0.layer.borderColor = UIColor.appColor(.lightGray).cgColor
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 5.0
        $0.isEditable = false
        $0.isScrollEnabled = true
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    private let agreementCheckButton3 = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .checkEmptyCircle)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.appColor(.gray)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        config.background.backgroundColor = .clear
        config.background.strokeColor = .clear

        var attrTitle = AttributedString("마케팅수신 동의약관 (선택)")
        attrTitle.font = UIFont.appFont(.pretendardMedium, size: 14)
        config.attributedTitle = attrTitle

        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.backgroundColor = .clear
    }
    
    private let agreementTextView3 = UITextView().then {
        $0.text = AgreementText.marketing.description
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.systemFont(ofSize: 9)
        $0.layer.borderColor = UIColor.appColor(.lightGray).cgColor
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 5.0
        $0.isEditable = false
        $0.isScrollEnabled = true
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    // MARK: Init
    init(viewModel: RegisterFormViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureView()
        setUpButtonTargets()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgreementFormView {
    @objc private func allAgreementTapped(_ sender: UIButton) {
        agreementAllButton.isSelected = !agreementAllButton.isSelected
        let newState = agreementAllButton.isSelected
        
        updateCheckboxImage(checkbox: agreementAllButton, isSelected: newState)
        
        [agreementCheckButton1, agreementCheckButton2, agreementCheckButton3].forEach { checkbox in
            checkbox.isSelected = newState
            updateCheckboxImage(checkbox: checkbox, isSelected: newState)
        }
        
        let requiredAgreementsChecked = agreementCheckButton1.isSelected && agreementCheckButton2.isSelected
        onRequiredAgreementsChanged?(requiredAgreementsChecked)
    }
    
    @objc private func individualAgreementTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateCheckboxImage(checkbox: sender, isSelected: sender.isSelected)
        
        let areAllSelected = agreementCheckButton1.isSelected && agreementCheckButton2.isSelected && agreementCheckButton3.isSelected
        agreementAllButton.isSelected = areAllSelected
        updateCheckboxImage(checkbox: agreementAllButton, isSelected: areAllSelected)

        let requiredAgreementsChecked = agreementCheckButton1.isSelected && agreementCheckButton2.isSelected
        onRequiredAgreementsChanged?(requiredAgreementsChecked)
        
        if sender == agreementCheckButton3 && sender.isSelected {
            requestPushNotificationPermission()
        }
    }

    private func updateCheckboxImage(checkbox: UIButton, isSelected: Bool) {
        let image = isSelected ? UIImage.appImage(asset: .checkFilledCircle) : UIImage.appImage(asset: .checkEmptyCircle)
        checkbox.setImage(image, for: .normal)
    }

    private func setUpButtonTargets() {
        agreementCheckButton1.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckButton2.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckButton3.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementAllButton.addTarget(self, action: #selector(allAgreementTapped), for: .touchUpInside)
    }
    
    private func requestPushNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("푸시 권한 요청 실패: \(error.localizedDescription)")
                return
            }
            if granted {
                print("사용자 푸시 알림 권한 허용")
            } else {
                print("사용자 푸시 알림 권한 거부")
            }
        }
    }
}

// MARK: UI Settings
extension AgreementFormView {
    private func setUpLayOuts() {
        [agreementAllButton, agreementStackView].forEach {
            addSubview($0)
        }
        
        let item1 = UIStackView(arrangedSubviews: [agreementCheckButton1, agreementTextView1]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        let item2 = UIStackView(arrangedSubviews: [agreementCheckButton2, agreementTextView2]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        let item3 = UIStackView(arrangedSubviews: [agreementCheckButton3, agreementTextView3]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        [item1, item2, item3].forEach {
            agreementStackView.addArrangedSubview($0)
        }
    }

    private func setUpConstraints() {
        agreementAllButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(agreementAllButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }

        [agreementTextView1, agreementTextView2, agreementTextView3].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(120) }
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
