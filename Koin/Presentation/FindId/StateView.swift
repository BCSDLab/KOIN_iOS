//
//  StateView.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import Combine
import UIKit

final class StateView: UIView {
    
    enum State {
        case success
        case warning
        case dangerous
    }
    
    private let imageView = UIImageView()
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setState(state: State, message: String) {
        switch state {
        case .success:
            imageView.image = UIImage(named: "successCircle")
            messageLabel.textColor = UIColor.appColor(.success700)
        case .warning:
            imageView.image = UIImage(named: "warningOrange")
            messageLabel.textColor = UIColor.appColor(.sub500)
        case .dangerous:
            imageView.image = UIImage(named: "warningRed")
            messageLabel.textColor = UIColor.appColor(.danger700)
        }
    }
}

extension StateView {
    private func setupLayouts() {
        [imageView, messageLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(imageView.snp.height)
        }
        messageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    private func setupComponents() {
        
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        setupComponents()
    }
}
