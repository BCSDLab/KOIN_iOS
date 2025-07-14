//
//  ModifyUserModalViewController.swift
//  koin
//
//  Created by 김나훈 on 7/14/25.
//

import Combine
import UIKit

final class ModifyUserModalViewController: UIViewController {
    
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    let navigateButtonPublisher = PassthroughSubject<Void, Never>()
    
    private let messageLabel = UILabel().then {
        $0.text = "아직 입력되지 않은 정보가 있어요."
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = .black
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "필수 정보를 입력하시면 더 많은 기능을 이용하실 수 있어요.\n지금 입력하시겠어요?"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .gray
    }

    private let cancelButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral0)
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.borderWidth = 1.0
        $0.setTitle("나중에 하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral600), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let navigateButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("지금 입력하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
    }
    @objc private func cancelButtonTapped() {
        cancelButtonPublisher.send()
        dismiss(animated: true)
    }
    @objc private func navigateButtonTapped() {
        navigateButtonPublisher.send()
        dismiss(animated: true)
    }
   
}

extension ModifyUserModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, subMessageLabel, cancelButton, navigateButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.centerY.equalTo(view.snp.centerY)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(232)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(42.5)
            $0.centerX.equalToSuperview()
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.bottom.equalToSuperview().offset(-42.5)
            $0.trailing.equalTo(view.snp.centerX).offset(-4)
            $0.height.equalTo(48)
        }
        navigateButton.snp.makeConstraints {
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.bottom.equalToSuperview().offset(-42.5)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
