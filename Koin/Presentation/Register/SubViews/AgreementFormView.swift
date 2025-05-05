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
    private let seperateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral100)
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let agreementAllCheckbox = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .checkEmptyCircle), for: .normal)
        $0.tintColor = UIColor.appColor(.gray)
    }
    
    private let agreementAllLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.primary500)
        $0.text = "모두 동의합니다."
    }
    
    private let agreementStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }
    
    private let agreementCheckbox1 = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .checkEmptyCircle), for: .normal)
        $0.tintColor = UIColor.appColor(.gray)
    }
    
    private let agreementLabel1 = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.gray)
        $0.text = "개인정보 이용약관 (필수)"
    }
    
    private let agreementTextView1 = UITextView().then {
        $0.text = AgreementText.personalInformation.description
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.systemFont(ofSize: 9)
        $0.layer.borderColor = UIColor.appColor(.lightGray).cgColor
        $0.layer.borderWidth = 1.0
        $0.isEditable = false
        $0.isScrollEnabled = true
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    private let agreementCheckbox2 = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .checkEmptyCircle), for: .normal)
        $0.tintColor = UIColor.appColor(.gray)
    }
    
    private let agreementLabel2 = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.gray)
        $0.text = "코인 이용약관 (필수)"
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
    
    private let agreementCheckbox3 = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .checkEmptyCircle), for: .normal)
        $0.tintColor = UIColor.appColor(.gray)
    }
    
    private let agreementLabel3 = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.gray)
        $0.text = "마케팅수신 동의약관 (선택)"
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
        agreementAllCheckbox.isSelected = !agreementAllCheckbox.isSelected
        let newState = agreementAllCheckbox.isSelected
        
        updateCheckboxImage(checkbox: agreementAllCheckbox, isSelected: newState)
        
        [agreementCheckbox1, agreementCheckbox2, agreementCheckbox3].forEach { checkbox in
            checkbox.isSelected = newState
            updateCheckboxImage(checkbox: checkbox, isSelected: newState)
        }
        
        let requiredAgreementsChecked = agreementCheckbox1.isSelected && agreementCheckbox2.isSelected
        onRequiredAgreementsChanged?(requiredAgreementsChecked)
    }
    
    @objc private func individualAgreementTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateCheckboxImage(checkbox: sender, isSelected: sender.isSelected)
        
        let areAllSelected = agreementCheckbox1.isSelected && agreementCheckbox2.isSelected && agreementCheckbox3.isSelected
        agreementAllCheckbox.isSelected = areAllSelected
        updateCheckboxImage(checkbox: agreementAllCheckbox, isSelected: areAllSelected)

        let requiredAgreementsChecked = agreementCheckbox1.isSelected && agreementCheckbox2.isSelected
        onRequiredAgreementsChanged?(requiredAgreementsChecked)
        
        if sender == agreementCheckbox3 && sender.isSelected {
            requestPushNotificationPermission()
        }
    }

    private func updateCheckboxImage(checkbox: UIButton, isSelected: Bool) {
        let image = isSelected ? UIImage.appImage(asset: .checkFilledCircle) : UIImage.appImage(asset: .checkEmptyCircle)
        checkbox.setImage(image, for: .normal)
    }

    private func setUpButtonTargets() {
        agreementCheckbox1.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckbox2.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckbox3.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementAllCheckbox.addTarget(self, action: #selector(allAgreementTapped), for: .touchUpInside)
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
        [seperateView, agreementAllCheckbox, agreementAllLabel, agreementStackView].forEach {
            addSubview($0)
        }

        let item1Header = UIStackView(arrangedSubviews: [agreementCheckbox1, agreementLabel1]).then {
            $0.axis = .horizontal
            $0.spacing = 8
        }
        
        let item1 = UIStackView(arrangedSubviews: [item1Header, agreementTextView1]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        let item2Header = UIStackView(arrangedSubviews: [agreementCheckbox2, agreementLabel2]).then {
            $0.axis = .horizontal
            $0.spacing = 8
        }

        let item2 = UIStackView(arrangedSubviews: [item2Header, agreementTextView2]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        let item3Header = UIStackView(arrangedSubviews: [agreementCheckbox3, agreementLabel3]).then {
            $0.axis = .horizontal
            $0.spacing = 8
        }

        let item3 = UIStackView(arrangedSubviews: [item3Header, agreementTextView3]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        [item1, item2, item3].forEach {
            agreementStackView.addArrangedSubview($0)
        }
    }

    private func setUpConstraints() {
        seperateView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        agreementAllCheckbox.snp.makeConstraints {
            $0.leading.equalTo(seperateView.snp.leading).offset(8)
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(seperateView)
        }

        agreementAllLabel.snp.makeConstraints {
            $0.leading.equalTo(agreementAllCheckbox.snp.trailing).offset(8)
            $0.centerY.equalTo(seperateView)
        }

        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(seperateView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }

        [agreementTextView1, agreementTextView2, agreementTextView3].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(120) }
        }

        [agreementCheckbox1, agreementCheckbox2, agreementCheckbox3].forEach {
            $0.snp.makeConstraints { $0.width.height.equalTo(16) }
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
