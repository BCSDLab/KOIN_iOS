//
//  ShopBenefitEmptyView.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import UIKit
import SnapKit
import Then

final class ShopBenefitEmptyView: UIView {
    
    // MARK: - UI Compoents
    private let logoImageView = UIImageView().then {
        $0.image = .appImage(asset: .sleepBcsdSymbol)
    }
    private let emptyLabel = UILabel().then {
        $0.text = "아직 이벤트/공지가 없어요"
        $0.font = .appFont(.pretendardSemiBold, size: 18)
        $0.textColor = .appColor(.new500)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShopBenefitEmptyView {
    
    private func configureView() {
        [logoImageView, emptyLabel].forEach {
            addSubview($0)
        }
        logoImageView.snp.makeConstraints {
            $0.height.equalTo(75)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
