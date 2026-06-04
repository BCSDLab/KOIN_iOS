//
//  NotificationEmptyView.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import SnapKit
import Then

final class NotificationEmptyView: UIView {
    
    // MARK: - UI Components
    private let sleepImageView = UIImageView()
    private let emptyLabel = UILabel()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NotificationEmptyView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        sleepImageView.image = .appImage(asset: .sleepBcsdSymbol)
        
        emptyLabel.do {
            $0.text = "아직 알림이 없어요"
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
            $0.textColor = .appColor(.new500)
            $0.textAlignment = .center
        }
    }
    
    private func setUpLayouts() {
        [sleepImageView, emptyLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        sleepImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(sleepImageView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}
