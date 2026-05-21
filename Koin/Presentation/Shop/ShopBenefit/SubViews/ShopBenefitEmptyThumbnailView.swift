//
//  ShopBenefitEmptyThumbnailView.swift
//  koin
//
//  Created by 홍기정 on 5/20/26.
//

import UIKit
import SnapKit
import Then

final class ShopBenefitEmptyThumbnailView: UIView {
    
    // MARK: - UI Components
    private let layoutGuide = UILayoutGuide()
    private let logoImageView = UIImageView(image: .appImage(asset: .bcsdSymbolLogo))
    private let emptyLabel = UILabel().then {
        $0.text = "사장님이 이미지를 준비중이예요."
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textColor = .appColor(.neutral500)
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShopBenefitEmptyThumbnailView {
    
    private func configureView() {
        backgroundColor = .appColor(.neutral100)
        
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [logoImageView, emptyLabel].forEach {
            addSubview($0)
        }
        [layoutGuide].forEach {
            addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        layoutGuide.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.height.equalTo(79)
            $0.width.equalTo(100)
            $0.centerX.equalTo(layoutGuide)
            $0.top.equalTo(layoutGuide)
        }
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.bottom.equalTo(layoutGuide)
            $0.leading.trailing.equalTo(layoutGuide)
        }
    }
}
