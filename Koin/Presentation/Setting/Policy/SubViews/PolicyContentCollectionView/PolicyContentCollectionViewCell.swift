//
//  PolicyContentCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import UIKit

final class PolicyContentCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 15)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.numberOfLines = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(policyText: PolicyText) {
        titleLabel.text = policyText.title
        contentLabel.text = policyText.content
    }
}

extension PolicyContentCollectionViewCell {
    private func setUpLayouts() {
        [titleLabel, separateView, contentLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading).offset(24)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(16)
            make.leading.equalTo(self.snp.leading).offset(35)
            make.trailing.equalTo(self.snp.trailing).offset(-35)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
