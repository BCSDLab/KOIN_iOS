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
    
    // MARK: 개인정보 이용약관
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
    
    // MARK: 코인 이용약관
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
    
    // MARK: 마케팅수신 동의약관
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
    }
    
    @objc private func individualAgreementTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateCheckboxImage(checkbox: sender, isSelected: sender.isSelected)
        
        let areBothSelected = agreementCheckbox1.isSelected && agreementCheckbox2.isSelected && agreementCheckbox3.isSelected
        agreementAllCheckbox.isSelected = areBothSelected
        updateCheckboxImage(checkbox: agreementAllCheckbox, isSelected: areBothSelected)
    }

    private func updateCheckboxImage(checkbox: UIButton, isSelected: Bool) {
        if isSelected {
            checkbox.setImage(UIImage.appImage(asset: .checkFilledCircle), for: .normal)
        } else {
            checkbox.setImage(UIImage.appImage(asset: .checkEmptyCircle), for: .normal)
        }
    }

    private func setUpButtonTargets() {
        agreementCheckbox1.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckbox2.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementCheckbox3.addTarget(self, action: #selector(individualAgreementTapped), for: .touchUpInside)
        agreementAllCheckbox.addTarget(self, action: #selector(allAgreementTapped), for: .touchUpInside)
    }
    
    @objc private func checkButtonTapped() {
        // viewModel.checkList[index].toggle() ?? <- 이런식.
        
        // TODO:  여기서 이거 버튼 눌러서 3개 viewmodel의 checklist[] 배열 @Published로 된거 true로 바꾸고, 그거 모두 true면 viewcontroller의 nextbutton의 enable 상태를 바꿔주시면 됩니다.
    }
}

// MARK: UI Settings

extension AgreementFormView {
    private func setUpLayOuts() {
        [seperateView, agreementAllCheckbox, agreementAllLabel, agreementCheckbox1, agreementLabel1, agreementTextView1, agreementCheckbox2, agreementLabel2, agreementTextView2, agreementCheckbox3, agreementLabel3, agreementTextView3].forEach {
            self.addSubview($0)
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
        
        agreementCheckbox1.snp.makeConstraints {
            $0.top.equalTo(seperateView.snp.bottom).offset(19)
            $0.width.height.equalTo(16)
            $0.leading.equalToSuperview()
        }
        
        agreementLabel1.snp.makeConstraints {
            $0.leading.equalTo(agreementCheckbox1.snp.trailing).offset(8)
            $0.centerY.equalTo(agreementCheckbox1)
        }
        
        agreementTextView1.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(agreementLabel1.snp.bottom).offset(8)
            $0.height.equalTo(120)
        }
        
        agreementCheckbox2.snp.makeConstraints {
            $0.top.equalTo(agreementTextView1.snp.bottom).offset(16)
            $0.width.height.equalTo(16)
            $0.leading.equalToSuperview()
        }
        
        agreementLabel2.snp.makeConstraints {
            $0.leading.equalTo(agreementCheckbox2.snp.trailing).offset(8)
            $0.centerY.equalTo(agreementCheckbox2)
        }
        
        agreementTextView2.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(agreementLabel2.snp.bottom).offset(8)
            $0.height.equalTo(120)
        }
        
        agreementCheckbox3.snp.makeConstraints {
            $0.top.equalTo(agreementTextView2.snp.bottom).offset(16)
            $0.width.height.equalTo(16)
            $0.leading.equalToSuperview()
        }
        
        agreementLabel3.snp.makeConstraints {
            $0.leading.equalTo(agreementCheckbox3.snp.trailing).offset(8)
            $0.centerY.equalTo(agreementCheckbox3)
        }
        
        agreementTextView3.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(agreementLabel3.snp.bottom).offset(8)
            $0.height.equalTo(120)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpButtonTargets()
    }
}
