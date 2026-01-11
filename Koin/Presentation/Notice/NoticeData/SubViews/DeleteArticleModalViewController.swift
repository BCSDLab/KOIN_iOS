//
//  DeleteArticleModalViewController.swift
//  koin
//
//  Created by 김나훈 on 1/23/25.
//

import Combine
import UIKit

final class DeleteArticleModalViewController: UIViewController {
    
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()
    var containerWidth: CGFloat
    var containerHeight: CGFloat
    
    private let messageLabel = UILabel().then {
        $0.text = "게시글을 삭제하시겠습니까?"
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }

    private let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let deleteButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("확인", for: .normal)
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
    
    init(width: CGFloat, height: CGFloat) {
        self.containerWidth = width
        self.containerHeight = height
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true, completion: nil)
        deleteButtonPublisher.send()
    }
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension DeleteArticleModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, cancelButton, deleteButton].forEach {
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
            make.top.equalTo(containerView.snp.top).offset(25)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(15)
            make.trailing.equalTo(view.snp.centerX).offset(-3)
            make.width.equalTo(105)
            make.height.equalTo(46)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(15)
            make.leading.equalTo(view.snp.centerX).offset(3)
            make.width.equalTo(105)
            make.height.equalTo(46)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
