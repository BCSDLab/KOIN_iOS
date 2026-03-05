//
//  CallVanNotificationEmptyView.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import SnapKit
import Then

final class CallVanNotificationEmptyView: UIView {
 
    // MARK: - UI Components
    private let sleepSymbolImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subTitleLable = UILabel()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CallVanNotificationEmptyView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        sleepSymbolImageView.do {
            $0.image = UIImage.appImage(asset: .sleepBcsdSymbol)
        }
        
        titleLabel.do {
            $0.text = "아직 알림이 없어요"
            $0.font = UIFont.appFont(.pretendardBold, size: 18)
            $0.textColor = UIColor.appColor(.new500)
        }
        
        subTitleLable.do {
            $0.text = "콜밴팟 관련 알림이 오면 여기에 표시돼요"
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
            $0.textColor = UIColor.appColor(.neutral600)
        }
    }
    
    private func setUpLayouts() {
        [sleepSymbolImageView, titleLabel, subTitleLable].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        sleepSymbolImageView.snp.makeConstraints {
            $0.height.equalTo(75)
            $0.width.equalTo(95)
            $0.top.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(sleepSymbolImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLable.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
