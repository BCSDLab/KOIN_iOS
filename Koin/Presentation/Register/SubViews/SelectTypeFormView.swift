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
        [logoImageView].forEach {
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
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
