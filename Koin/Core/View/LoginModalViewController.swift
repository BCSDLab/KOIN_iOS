//
//  LoginModalViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine
import UIKit

class LoginModalViewController: UIViewController {
    let loginButtonPublisher = PassthroughSubject<Void, Never>()
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    var containerWidth: CGFloat = 0
    var containerHeight: CGFloat = 0
    var paddingBetweenLabels: CGFloat = 0
    var titleText: String = ""
    var subTitleText: String = ""
    var titleColor: UIColor = .black
    var subTitleColor: UIColor = .black
    
    private let messageLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    private let subMessageLabel = UILabel().then {
        $0.numberOfLines = 0
    }

    private let closeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let loginButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("로그인하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    init(width: CGFloat, height: CGFloat, paddingBetweenLabels: CGFloat, title: String, subTitle: String, titleColor: UIColor, subTitleColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.containerWidth = width
        self.containerHeight = height
        self.paddingBetweenLabels = paddingBetweenLabels
        self.titleText = title
        self.subTitleText = subTitle
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc func closeButtonTapped() {
        cancelButtonPublisher.send()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func loginButtonTapped() {
        loginButtonPublisher.send()
        dismiss(animated: true, completion: nil)
    }
    
    func updateLoginButton(buttonColor: UIColor) {
        loginButton.backgroundColor = buttonColor
    }
    
    func updateCloseButton(buttonColor: UIColor) {
        closeButton.backgroundColor = buttonColor
    }
    
    func updateMessageLabel(font: UIFont = .appFont(.pretendardMedium, size: 18), alignment: NSTextAlignment = .center) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = alignment
        let attributedString = NSMutableAttributedString(string: titleText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: titleText.count))
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: titleText.count))
        attributedString.addAttribute(.foregroundColor, value: titleColor, range: NSRange(location: 0, length: titleText.count))
        
        messageLabel.attributedText = attributedString
    }
    
    func updateSubMessageLabel(font: UIFont = .appFont(.pretendardRegular, size: 14), alignment: NSTextAlignment = .center) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = alignment
        let attributedString = NSMutableAttributedString(string: subTitleText)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: subTitleText.count))
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: subTitleText.count))
        attributedString.addAttribute(.foregroundColor, value: subTitleColor, range: NSRange(location: 0, length: subTitleText.count))
        
        subMessageLabel.attributedText = attributedString
    }
}

extension LoginModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, subMessageLabel, closeButton, loginButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(containerWidth)
            make.height.equalTo(containerHeight)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(paddingBetweenLabels)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.centerX).offset(2)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
        updateMessageLabel()
        updateSubMessageLabel()
    }
}
