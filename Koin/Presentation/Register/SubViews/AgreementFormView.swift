//
//  AgreementFormView.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit

final class AgreementFormView: UIView {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel
    
    // MARK: - UI Components
    
    
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
    @objc private func checkButtonTapped() {
        // viewModel.checkList[index].toggle() ?? <- 이런식.
        
        // TODO:  여기서 이거 버튼 눌러서 3개 viewmodel의 checklist[] 배열 @Published로 된거 true로 바꾸고, 그거 모두 true면 viewcontroller의 nextbutton의 enable 상태를 바꿔주시면 됩니다.
    }
}

// MARK: UI Settings

extension AgreementFormView {
    private func setUpLayOuts() {
        [].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.backgroundColor = .gray
        // !!!: 여기 부분은 임시로 색상 gray. 나중에 지우기.
    }
}
