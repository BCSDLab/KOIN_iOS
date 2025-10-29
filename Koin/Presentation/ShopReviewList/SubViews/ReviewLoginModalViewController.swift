//
//  ReviewLoginModalViewController.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//


import Combine
import UIKit

final class ReviewLoginModalViewController: UIViewController {
    
    let loginButtonPublisher = PassthroughSubject<Void, Never>()
    private let message: String
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    
    private lazy var messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let text = "리뷰 \(message)시 로그인을 해주세요."
        let attributedString = NSMutableAttributedString(string: text)
        
        let loginRange = (text as NSString).range(of: "로그인")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.primary500), range: loginRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.textAlignment = .center
    }
    
    
    private lazy var subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let text = "리뷰 \(message)\(message.hasFinalConsonant() ? "은" : "는") 회원만 사용 가능합니다.\n회원가입 또는 로그인 후 이용해주세요 :-)"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private let closeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("취소하기", for: .normal)
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
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
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
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
        cancelButtonPublisher.send()
    }
    
    @objc private func loginButtonTapped() {
        dismiss(animated: true, completion: nil)
        loginButtonPublisher.send(())
    }
}

extension ReviewLoginModalViewController {
    
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
            make.width.equalTo(301)
            make.height.equalTo(201)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
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
    }
}
