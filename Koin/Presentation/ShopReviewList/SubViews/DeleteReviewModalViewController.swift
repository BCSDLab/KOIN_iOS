//
//  DeleteReviewModalViewController.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import UIKit
import SnapKit

final class DeleteReviewModalViewController: UIViewController {
    
    // MARK: - Properties
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let reviewDeleteInfoLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 15)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        
        let text = "삭제한 리뷰는 되돌릴 수 없습니다.\n삭제 하시겠습니까?"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        
        $0.attributedText = attributedString
    }
    
    private let closeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("취소하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    private let deleteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.new500)
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
    }
    
    private func setAddTarget() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
}

extension DeleteReviewModalViewController {
    @objc private func closeButtonTapped() {
        cancelButtonPublisher.send()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true, completion: nil)
        deleteButtonPublisher.send(())
    }
}

// MARK: - UI Functions
extension DeleteReviewModalViewController {
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        
        [reviewDeleteInfoLabel, closeButton, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.width.equalTo(301)
            $0.height.equalTo(168)
        }

        reviewDeleteInfoLabel.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(24)
            $0.centerX.equalTo(containerView.snp.centerX)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(reviewDeleteInfoLabel.snp.bottom).offset(24)
            $0.trailing.equalTo(containerView.snp.centerX).offset(-4)
            $0.width.equalTo(114.5)
            $0.height.equalTo(48)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(reviewDeleteInfoLabel.snp.bottom).offset(24)
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
