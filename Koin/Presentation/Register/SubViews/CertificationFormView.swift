//
//  CertificationFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit

final class CertificationFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    
    // MARK: - UI Components
    private let nameAndGenderLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
        $0.text = "성함과 성별을 알려주세요."
    }
    
    private let nameTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: "실명을 입력해 주세요.", attributes: [.foregroundColor: UIColor.appColor(.neutral400), .font: UIFont.appFont(.pretendardRegular, size: 14)])
        $0.autocapitalizationType = .none
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)

        $0.clearButtonMode = .never
        let clearButton = UIButton(type: .custom) // 커스텀 버튼
        clearButton.setImage(UIImage.appImage(asset: .cancelNeutral500), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.tintColor = .red
        $0.rightView = clearButton
        $0.rightViewMode = .whileEditing
    }
    
    private let seperateView1 = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private lazy var femaleButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .circlePrimary500)
        var text = AttributedString("여성")
        text.font = UIFont.appFont(.pretendardRegular, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .black
        $0.configuration = configuration
        $0.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var maleButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .circlePrimary500)
        var text = AttributedString("남성")
        text.font = UIFont.appFont(.pretendardRegular, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .black
        $0.configuration = configuration
        $0.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
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
    
    @objc private func clearTextField() {   // 입력 없이 터치만 해도 clear 버튼이 생겨서 안 이쁘다
        nameTextField.text = ""
    }

}

extension CertificationFormView {
    @objc private func femaleButtonTapped() {
        updateGenderSelection(isFemale: true)
    }

    @objc private func maleButtonTapped() {
        updateGenderSelection(isFemale: false)
    }

    private func updateGenderSelection(isFemale: Bool) {
        var femaleConfig = femaleButton.configuration
        var maleConfig = maleButton.configuration

        femaleConfig?.image = UIImage.appImage(asset: isFemale ? .circleCheckedPrimary500 : .circlePrimary500)
        maleConfig?.image = UIImage.appImage(asset: isFemale ? .circlePrimary500 : .circleCheckedPrimary500)

        femaleButton.configuration = femaleConfig
        maleButton.configuration = maleConfig

        // 선택된 성별을 ViewModel에 저장할 때 여기서 처리하기
        // viewModel.selectedGender = isFemale ? .female : .male
    }

   
}

// MARK: UI Settings
extension CertificationFormView {
    private func setUpLayOuts() {
        [nameAndGenderLabel, nameTextField, seperateView1, femaleButton, maleButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        nameAndGenderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.equalTo(29)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameAndGenderLabel.snp.bottom).offset(16)
            $0.leading.equalTo(nameAndGenderLabel.snp.leading)
            $0.trailing.equalTo(nameAndGenderLabel.snp.trailing)
            $0.height.equalTo(40)
        }
        
        seperateView1.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom)
            $0.leading.equalTo(nameTextField.snp.leading)
            $0.trailing.equalTo(nameTextField.snp.trailing)
            $0.height.equalTo(1)
        }
        
        // FIXME: 버튼 UI가 안 맞음
        femaleButton.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(16)
            $0.leading.equalTo(seperateView1.snp.leading)
            $0.height.equalTo(26)
            $0.width.greaterThanOrEqualTo(52)
        }
        
        maleButton.snp.makeConstraints {
            $0.top.equalTo(seperateView1.snp.bottom).offset(16)
            $0.leading.equalTo(femaleButton.snp.trailing).offset(32)
            $0.height.equalTo(26)
            $0.width.greaterThanOrEqualTo(52)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
