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
    
    private let messageLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setState(state: State, message: String) {
        messageLabel.setImageText(
            image: image(for: state),
            text: message,
            font: UIFont.appFont(.pretendardRegular, size: 12),
            textColor: textColor(for: state)
        )
    }

    func setState(state: State, attributedMessage: NSAttributedString) {
        messageLabel.setImageAttributedText(image: image(for: state), attributedText: attributedMessage)
    }

    private func image(for state: State) -> UIImage? {
        switch state {
        case .success:
            return UIImage.appImage(asset: .successCircle)
        case .warning:
            return UIImage.appImage(asset: .warningOrange)?.withTintColor(.appColor(.new600), renderingMode: .alwaysOriginal)
        case .dangerous:
            return UIImage.appImage(asset: .warningRed)
        }
    }

    private func textColor(for state: State) -> UIColor {
        switch state {
        case .success:
            return UIColor.appColor(.success700)
        case .warning:
            return UIColor.appColor(.new600)
        case .dangerous:
            return UIColor.appColor(.danger700)
        }
    }
}

extension StateView {
    private func setupLayouts() {
        addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
    }
}
