//
//  CallBenefitCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import UIKit

final class CallBenefitCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(benefit: Benefit) {
        titleLabel.text = benefit.title
    }
}

extension CallBenefitCollectionViewCell {
    private func setUpLayouts() {
        [titleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
