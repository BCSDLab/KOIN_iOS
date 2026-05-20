//
//  ShopBenefitOpenCloseView.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import UIKit
import SnapKit
import Then

final class ShopBenefitOpenCloseView: UIView {
    
    // MARK: - UI Components
    private let stateLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textColor = .appColor(.neutral500)
    }
    private let chevronImageView = UIImageView().then {
        $0.image = .appImage(asset: .shopOpenCloseChevron)
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(isExpanded: Bool) {
        switch isExpanded {
        case true:
            stateLabel.text = "접기"
            chevronImageView.transform = CGAffineTransform(scaleX: 1, y: -1)
        case false:
            stateLabel.text = "상세보기"
            chevronImageView.transform = .identity
        }
    }
}

extension ShopBenefitOpenCloseView {
    
    private func configureView() {
        [stateLabel, chevronImageView].forEach {
            addSubview($0)
        }
        
        stateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(chevronImageView.snp.leading)
            $0.centerY.equalToSuperview()
        }
        chevronImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}
