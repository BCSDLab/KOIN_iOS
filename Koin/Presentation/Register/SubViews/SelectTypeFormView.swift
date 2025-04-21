//
//  SelectTypeFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit

final class SelectTypeFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    
    // MARK: - UI Components
    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinLogo)
    }
    
    private let studentButton = UIButton().then {
        $0.backgroundColor = .appColor(.sub500)
        $0.setTitle("한국기술교육대학교 학생", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.layer.cornerRadius = 8
    }
    
    private let outsiderButton = UIButton().then {
        $0.backgroundColor = .appColor(.primary500)
        $0.setTitle("외부인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.layer.cornerRadius = 8
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

extension SelectTypeFormView {
   
}

// MARK: UI Settings

extension SelectTypeFormView {
    private func setUpLayOuts() {
        [logoImageView, studentButton, outsiderButton].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(84)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(96)
            $0.height.equalTo(56)
        }
        
        studentButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(80)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(48)
        }
        
        outsiderButton.snp.makeConstraints {
            $0.top.equalTo(studentButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
