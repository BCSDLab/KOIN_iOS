//
//  ShopSummaryPhoneButton.swift
//  koin
//
//  Created by 홍기정 on 11/9/25.
//

import UIKit

final class ShopSummaryPhoneButton: UIButton {
    
    // MARK: - UI Components
    let stackview = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.alignment = .center
        $0.isUserInteractionEnabled = false
    }
    let phoneImageView = UIImageView(image: .callNew)
    let paddingViewWidth8 = UIView().then {
        $0.backgroundColor = .clear
    }
    let descriptionLabel = UILabel().then {
        $0.text = "가게에 전화하기"
        $0.font = .appFont(.pretendardSemiBold, size: 14)
        $0.textColor = .appColor(.new500)
    }
    let paddingViewWidth20 = UIView().then {
        $0.backgroundColor = .clear
    }
    let phonenumberLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textColor = .appColor(.neutral700)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(phonenumber: String) {
        phonenumberLabel.text = phonenumber
    }
}

extension ShopSummaryPhoneButton {
    
    private func setUpLayout() {
        [phoneImageView, paddingViewWidth8, descriptionLabel, paddingViewWidth20, phonenumberLabel].forEach {
            stackview.addArrangedSubview($0)
        }
        [stackview].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        phoneImageView.snp.makeConstraints {
            $0.width.height.equalTo(18)
        }
        paddingViewWidth8.snp.makeConstraints {
            $0.width.equalTo(8)
        }
        paddingViewWidth20.snp.makeConstraints {
            $0.width.equalTo(20)
        }
        stackview.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 12
    }
}

