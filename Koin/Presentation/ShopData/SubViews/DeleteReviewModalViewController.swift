//
//  DeleteReviewModalViewController.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//


import Combine
import UIKit

final class DeleteReviewModalViewController: UIViewController {
    
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        let text = "리뷰를 삭제 하시겠습니까?"
        let attributedString = NSMutableAttributedString(string: text)

        let loginRange = (text as NSString).range(of: "삭제")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.sub500), range: loginRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.textAlignment = .center
    }

    
    private let subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let text = "삭제한 리뷰는 되돌릴 수 없습니다."
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
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
    
    private let deleteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.sub500)
        $0.setTitle("삭제하기", for: .normal)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true, completion: nil)
        deleteButtonPublisher.send(())
    }
}

extension DeleteReviewModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, subMessageLabel, closeButton, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(301)
            make.height.equalTo(179)
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
        deleteButton.snp.makeConstraints { make in
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
