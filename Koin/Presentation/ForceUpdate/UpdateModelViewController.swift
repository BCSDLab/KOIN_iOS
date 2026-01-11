//
//  UpdateModelViewController.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine
import UIKit
import SnapKit

final class UpdateModelViewController: UIViewController {
    
    // MARK: - Properties
    let openStoreButtonPublisher = PassthroughSubject<Void, Never>()
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.text = "이미 업데이트 하셨나요?"
    }
    
    private let subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 13)
        $0.textColor = UIColor.appColor(.neutral600)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let text = "업데이트 이후에도 이 화면이 나타나는\n경우에는 스토어에서 코인을\n삭제 후 재설치 해 주세요."
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.numberOfLines = 3
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
    
    private let openStoreButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.new500)
        $0.setTitle("스토어 가기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
    }
    
    private func setAddTarget() {
        openStoreButton.addTarget(self, action: #selector(openStoreButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
}

// MARK: - @objc
extension UpdateModelViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
        cancelButtonPublisher.send()
    }
    
    @objc private func openStoreButtonTapped() {
        dismiss(animated: true, completion: nil)
        openStoreButtonPublisher.send(())
    }
}

// MARK: - UI Function
extension UpdateModelViewController {
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        
        [messageLabel, subMessageLabel, closeButton, openStoreButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.width.equalTo(301)
            $0.height.equalTo(210)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(24)
            $0.centerX.equalTo(containerView.snp.centerX)
        }
        
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.centerX.equalTo(containerView.snp.centerX)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            $0.trailing.equalTo(containerView.snp.centerX).offset(-4)
            $0.width.equalTo(114.5)
            $0.height.equalTo(48)
        }
        
        openStoreButton.snp.makeConstraints {
            $0.top.equalTo(subMessageLabel.snp.bottom).offset(24)
            $0.leading.equalTo(containerView.snp.centerX).offset(4)
            $0.width.equalTo(114.5)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
