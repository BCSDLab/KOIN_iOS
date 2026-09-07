//
//  ModalButtonView.swift
//  koin
//
//  Created by 홍기정 on 8/15/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class ModalButtonView: UIView {
    
    private enum Layout {
        static let PaddingBetweenButtons: CGFloat = 8
        static let ButtonHeight: CGFloat = 48
    }
    
    // MARK: - Properties
    private let configuration: KoinModalConfiguration
    let leftButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let rightButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let singleButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let leftButton = UIButton()
    private let rightButton = UIButton()
    private let singleButton = UIButton()
    
    // MARK: - Initializer
    init(configuration: KoinModalConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        configureView()
        setUpAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ModalButtonView {
    private func setUpAddTargets() {
        leftButton.addTarget(self, action: #selector(onLeftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(onRightButtonTapped), for: .touchUpInside)
        singleButton.addTarget(self, action: #selector(onSingleButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Objc
    @objc private func onLeftButtonTapped() {
        leftButtonTappedPublisher.send()
    }
    @objc private func onRightButtonTapped() {
        rightButtonTappedPublisher.send()
    }
    @objc private func onSingleButtonTapped() {
        singleButtonTappedPublisher.send()
    }
}

extension ModalButtonView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        switch configuration.button {
        case .buttons(let leftButtonTitle, _, let leftButtonStyle, let rightButtonTitle, _, let rightButtonStyle):
            let leftButtonTitle = leftButtonTitle
            let leftButtonStyle = leftButtonStyle ?? configuration.style.leftButton
            let rightButtonTitle = rightButtonTitle
            let rightButtonStyle = rightButtonStyle ?? configuration.style.rightButton
            
            apply(title: leftButtonTitle, style: leftButtonStyle, to: leftButton)
            apply(title: rightButtonTitle, style: rightButtonStyle, to: rightButton)
        case .singleButton(let title, _, let style):
            let title = title
            let style = style ?? configuration.style.singleButton
            
            apply(title: title, style: style, to: singleButton)
        case .none:
            return
        }
    }
    
    private func setUpLayouts() {
        switch configuration.button {
        case .buttons:
            [leftButton, rightButton].forEach {
                addSubview($0)
            }
        case .singleButton:
            [singleButton].forEach {
                addSubview($0)
            }
        case .none:
            return
        }
    }
    
    private func setUpConstraints() {
        switch configuration.button {
        case .buttons:
            leftButton.snp.makeConstraints {
                $0.height.equalTo(Layout.ButtonHeight)
                $0.top.leading.bottom.equalToSuperview()
            }
            rightButton.snp.makeConstraints {
                $0.height.equalTo(Layout.ButtonHeight)
                $0.width.equalTo(leftButton.snp.width)
                $0.leading.equalTo(leftButton.snp.trailing).offset(Layout.PaddingBetweenButtons)
                $0.top.trailing.bottom.equalToSuperview()
            }
        case .singleButton:
            singleButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(Layout.ButtonHeight)
            }
        case .none:
            return
        }
    }
}

extension ModalButtonView {
    private func apply(title: String, style: KoinModalStyle.ButtonStyle, to button: UIButton) {
        button.do {
            var configuration = UIButton.Configuration.plain()
            
            configuration.attributedTitle = AttributedString(
                title,
                attributes: AttributeContainer([
                    .font: UIFont.appFont(style.font, size: style.fontSize),
                    .foregroundColor: UIColor.appColor(style.textColor)
                ])
            )
            $0.configuration = configuration
            
            if let backgroundColor = style.backgroundColor {
                $0.backgroundColor = .appColor(backgroundColor)
            }
            if let borderColor = style.borderColor {
                $0.layer.borderColor = UIColor.appColor(borderColor).cgColor
            }
            if let borderWidth = style.borderWidth {
                $0.layer.borderWidth = borderWidth
            }
            if let cornerRadius = style.cornerRadius {
                $0.layer.cornerRadius = cornerRadius
            }
            
            $0.clipsToBounds = true
        }
    }
}
