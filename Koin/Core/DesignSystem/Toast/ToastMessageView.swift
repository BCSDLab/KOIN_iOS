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
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let toastLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.setFont(.body2)
        $0.numberOfLines = 2
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private let toastButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = UIColor(hexCode: "4B4B4B")
        config.background.cornerRadius = 29
        config.baseForegroundColor = UIColor(hexCode: "FFFFFF")
        config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 20, bottom: 9, trailing: 20)
        
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.setFont(.body2)
        config.attributedTitle = AttributedString("", attributes: titleContainer)
        
        $0.configuration = config
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
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

extension ToastMessageView {
    private func configure(with config: ToastConfig) {
        if let icon = config.intent.toastMessageIcon {
            toastImageView.image = icon
            toastImageView.isHidden = false
        } else {
            toastImageView.isHidden = true
        }
        
        toastLabel.text = config.message
        
        if let buttonTitle = config.variant.buttonTitle {
            toastButton.isHidden = false
            var buttonConfig = toastButton.configuration
            var titleContainer = AttributeContainer()
            titleContainer.font = UIFont.setFont(.body2)
            buttonConfig?.attributedTitle = AttributedString(buttonTitle, attributes: titleContainer)
            toastButton.configuration = buttonConfig
            
            toastButton.removeTarget(nil, action: nil, for: .allEvents)
            toastButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        } else {
            toastButton.isHidden = true
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
        
        if hasIcon {
            toastImageView.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(16)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(20)
            }
        } else {
            toastImageView.snp.remakeConstraints {
                $0.width.height.equalTo(0)
            }
        }
        
        if hasButton {
            toastButton.snp.remakeConstraints {
                $0.trailing.equalToSuperview().inset(12)
                $0.centerY.equalToSuperview()
                $0.height.equalTo(31)
            }
        } else {
            toastButton.snp.remakeConstraints {
                $0.width.height.equalTo(0)
            }
        }
        
        toastLabel.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            
            if hasIcon {
                $0.leading.equalTo(toastImageView.snp.trailing).offset(12)
            } else {
                $0.leading.equalToSuperview().offset(16)
            }
            
            if hasButton {
                $0.trailing.lessThanOrEqualTo(toastButton.snp.leading).offset(-12)
            } else {
                $0.trailing.equalToSuperview().inset(16)
            }
        }
    }
}
