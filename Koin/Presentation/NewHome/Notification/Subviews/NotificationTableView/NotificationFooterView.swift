//
//  NotificationFooterView.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import SnapKit
import Then

final class NotificationFooterView: UIView {
    
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NotificationFooterView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = UIColor.ColorSystem.Neutral.gray0
        
        label.do {
            $0.text = "14일이 지난 알림은 자동으로 삭제됩니다."
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.ColorSystem.Neutral.gray500
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }
    
    private func setUpLayouts() {
        addSubview(label)
    }
    
    private func setUpConstraints() {
        label.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(15)
        }
    }
}
