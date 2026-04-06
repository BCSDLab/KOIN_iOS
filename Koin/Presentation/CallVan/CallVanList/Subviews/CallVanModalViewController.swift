//
//  CallVanModalViewController.swift
//  koin
//
//  Created by 홍기정 on 4/6/26.
//

import UIKit
import SnapKit
import Then

final class CallVanModalViewController: UIViewController {
    
    // MARK: - UI Components
    private let dimView = UIView()
    private let modalView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let closeButton = UIButton()
    
    // MARK: - Initializer
    init(title: String, description: String) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 18),
                .foregroundColor : UIColor.appColor(.neutral600)
            ]
        )
        let paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont.appFont(.pretendardRegular, size: 14)
        paragraphStyle.lineSpacing = font.lineHeight * 0.6
        descriptionLabel.attributedText = NSAttributedString(
            string: description,
            attributes: [
                .font : font,
                .foregroundColor : UIColor.appColor(.gray),
                .paragraphStyle : paragraphStyle
            ]
        )
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTargets()
    }
}

extension CallVanModalViewController {
    
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: false)
    }
}

extension CallVanModalViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        dimView.do {
            $0.alpha = 0.7
            $0.backgroundColor = UIColor.black
        }
        modalView.do {
            $0.backgroundColor = UIColor.white
            $0.layer.cornerRadius = 8
        }
        descriptionLabel.do {
            $0.numberOfLines = 2
            $0.textAlignment = .center
        }
        closeButton.do {
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "닫기",
                    attributes: [
                        .font : UIFont.appFont(.pretendardMedium, size: 15),
                        .foregroundColor : UIColor.white
                    ]),
                for: .normal
            )
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, descriptionLabel, closeButton].forEach {
            modalView.addSubview($0)
        }
        [dimView, modalView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        modalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
        }
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        closeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-24)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
}
