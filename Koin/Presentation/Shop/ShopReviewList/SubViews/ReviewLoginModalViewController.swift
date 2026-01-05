//
//  ReviewLoginModalViewController.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//


import Combine
import UIKit

final class ReviewLoginModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private let message: String
    
    // MARK: - Publisher
    private let onLoginButtonTapped: ()->Void
    private let onCancelButtonTapped: (()->Void)?

    // MARK: - UI Components

    private lazy var messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private lazy var subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }
    
    private let closeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    private let loginButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.new500)
        $0.setTitle("로그인하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initializer
    
    init(
        message: String,
        onLoginButtonTapped: @escaping ()->Void,
        onCancelButtonTapped: (()->Void)?
    ) {
        self.message = message
        self.onLoginButtonTapped = onLoginButtonTapped
        self.onCancelButtonTapped = onCancelButtonTapped
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureMessages()
        setAddTarget()
    }
    
    private func setAddTarget() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func configureMessages() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let mainText: String
        let subText: String
        
        switch message {
        case "작성":
            mainText = "리뷰를 작성하기 위해\n로그인이 필요해요."
            subText = "리뷰 작성은 회원만 사용 가능합니다."
            
        case "신고":
            mainText = "리뷰를 신고하기 위해\n로그인이 필요해요."
            subText = "리뷰 신고는 회원만 사용 가능합니다."
            
        default:
            mainText = "리뷰를 작성하기 위해\n로그인이 필요해요."
            subText = "리뷰 작성은 회원만 사용 가능합니다."
        }
        
        let mainAttributedString = NSMutableAttributedString(
            string: mainText,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        messageLabel.attributedText = mainAttributedString
        
        let subParagraphStyle = NSMutableParagraphStyle()
        subParagraphStyle.lineSpacing = 6
        let subAttributedString = NSMutableAttributedString(
            string: subText,
            attributes: [.paragraphStyle: subParagraphStyle]
        )
        subMessageLabel.attributedText = subAttributedString
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
        onCancelButtonTapped?()
    }
    
    @objc private func loginButtonTapped() {
        dismiss(animated: true, completion: nil)
        onLoginButtonTapped()
    }
}

// MARK: - UI Functions

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
            make.height.equalTo(208)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(8)
            make.centerX.equalTo(containerView.snp.centerX)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-4)
            make.width.equalTo(114.5)
            make.height.equalTo(48)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.centerX).offset(4)
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
