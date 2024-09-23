//
//  CallBenefitFooterView.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import UIKit

final class CallBenefitFooterView: UICollectionReusableView {
    static let identifier = "CallBenefitFooterView"

    private let benefitDetailLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(benefitDetailLabel)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .systemBackground
        benefitDetailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
        }
    }

}
