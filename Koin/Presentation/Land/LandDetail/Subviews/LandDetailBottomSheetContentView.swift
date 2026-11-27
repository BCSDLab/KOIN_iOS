//
//  LandDetailBottomSheetContentView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandDetailBottomSheetContentView: UIView, KoinBottomSheetContent {

    // MARK: - Properties
    weak var delegate: KoinBottomSheetDelegate?
    let callTappedPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    private let contactStackView = UIStackView()
    private let contactTitleLabel = UILabel()
    private let phoneLabel = UILabel()
    private let callButton = UIButton()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandDetailBottomSheetContentView {
    func configure(landDetail: LandDetail) {
        phoneLabel.text = landDetail.phoneText
        callButton.isEnabled = landDetail.phone != nil
    }
}

extension LandDetailBottomSheetContentView {
    @objc private func callButtonTapped() {
        callTappedPublisher.send()
    }
}

extension LandDetailBottomSheetContentView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        contactStackView.axis = .vertical
        contactTitleLabel.do {
            $0.text = "연락처"
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral800)
        }
        phoneLabel.do {
            $0.text = " "
            $0.font = .appFont(.pretendardMedium, size: 14)
            $0.textColor = .appColor(.neutral800)
        }
        callButton.do {
            $0.isEnabled = false
            $0.configurationUpdateHandler = { button in
                var configuration = UIButton.Configuration.plain()
                configuration.attributedTitle = AttributedString("전화 문의하기", attributes: AttributeContainer([
                    .font: UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor: UIColor.appColor(.neutral0)
                ]))
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
                configuration.background.backgroundColor = button.isEnabled ? .appColor(.new500) : .appColor(.neutral400)
                configuration.background.cornerRadius = 8
                configuration.cornerStyle = .fixed
                button.configuration = configuration
            }
        }
    }

    private func setUpLayouts() {
        [contactTitleLabel, phoneLabel].forEach {
            contactStackView.addArrangedSubview($0)
        }
        [contactStackView, callButton].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        contactStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(callButton.snp.leading).offset(-8)
        }
        contactTitleLabel.snp.makeConstraints {
            $0.height.equalTo(19)
        }
        phoneLabel.snp.makeConstraints {
            $0.height.equalTo(22)
        }
        callButton.snp.makeConstraints {
            $0.centerY.equalTo(contactStackView)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(42)
        }
    }
}
