//
//  ToastMessageView.swift
//  koin
//
//  Created by 이은지 on 10/19/25.
//

import UIKit
import SnapKit

final class ToastMessageView: UIView {
    
    // MARK: - Properties
    
    private var buttonAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let toastImageView = UIImageView().then {
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let toastLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.numberOfLines = 1
    }
    
    private let toastButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = UIColor(hexCode: "4B4B4B")
        config.background.cornerRadius = 4
        config.baseForegroundColor = UIColor(hexCode: "FFFFFF")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.appFont(.pretendardRegular, size: 15)
        config.attributedTitle = AttributedString("", attributes: titleContainer)
        
        $0.configuration = config
    }
    
    // MARK: - Initialize
    
    init(config: ToastConfig, buttonAction: (() -> Void)? = nil) {
        self.buttonAction = buttonAction
        super.init(frame: .zero)
        
        backgroundColor = UIColor(hexCode: "6F6F6F")
        layer.cornerRadius = 8
        
        setUpLayout()
        configure(with: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configuration

extension ToastMessageView {
    private func configure(with config: ToastConfig) {
        if let icon = config.intent.toastMessageIcon {
            toastImageView.image = icon
            toastImageView.isHidden = false
        } else {
            toastImageView.isHidden = true
        }
        
        toastLabel.text = config.message
        
        switch config.variant {
        case .standard:
            toastButton.isHidden = true
            toastLabel.numberOfLines = 1
            
        case .action(let title):
            toastButton.isHidden = false
            var buttonConfig = toastButton.configuration
            var titleContainer = AttributeContainer()
            titleContainer.font = UIFont.appFont(.pretendardRegular, size: 15)
            buttonConfig?.attributedTitle = AttributedString(title, attributes: titleContainer)
            toastButton.configuration = buttonConfig
            
            toastButton.removeTarget(nil, action: nil, for: .allEvents)
            toastButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
            toastLabel.numberOfLines = 1
            
        case .overflow(let lines):
            toastButton.isHidden = true
            toastLabel.numberOfLines = lines
        }
        
        setUpConstraints()
    }
    
    @objc private func handleButtonTap() {
        buttonAction?()
    }
}

// MARK: - UI Function

extension ToastMessageView {
    private func setUpLayout() {
        [toastImageView, toastLabel, toastButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        let hasIcon = !toastImageView.isHidden
        let hasButton = !toastButton.isHidden
        
        toastImageView.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        toastButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(31)
            $0.width.greaterThanOrEqualTo(65)
        }
        
        toastLabel.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            
            if hasIcon {
                $0.leading.equalTo(toastImageView.snp.trailing).offset(12)
            } else {
                $0.leading.equalToSuperview().offset(16)
            }
            
            if hasButton {
                $0.trailing.equalTo(toastButton.snp.leading).offset(-12)
            } else {
                $0.trailing.equalToSuperview().offset(-16)
            }
        }
    }
}
