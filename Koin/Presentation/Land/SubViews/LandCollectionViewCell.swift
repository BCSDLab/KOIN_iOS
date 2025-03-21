//
//  LandCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 3/16/24.
//

import UIKit

final class LandCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let landNameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 15)
        $0.backgroundColor = .systemBackground
        $0.textAlignment = .center
    }
    
    private let monthlyFeeGuideLabel = UILabel().then {
        $0.text = "월세"
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.bus3)
        $0.layer.cornerRadius = 9
        $0.layer.masksToBounds = true
    }
    
    private let charterFeeGuideLabel = UILabel().then {
        $0.text = "전세"
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.bus1)
        $0.layer.cornerRadius = 9
        $0.layer.masksToBounds = true
    }
    
    private let monthlyFeeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let charterFeeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(info: LandItem) {
        landNameLabel.text = info.landName
        monthlyFeeLabel.text = info.monthlyFee
        charterFeeLabel.text = info.charterFee
    }
}

extension LandCollectionViewCell {
    private func setUpLayouts() {
        [landNameLabel, monthlyFeeGuideLabel, charterFeeGuideLabel, monthlyFeeLabel, charterFeeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        landNameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY)
        }
        monthlyFeeGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.centerY).offset(5)
            make.leading.equalTo(self.snp.leading).offset(10)
            make.width.equalTo(40)
            make.height.equalTo(18)
        }
        charterFeeGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(monthlyFeeGuideLabel.snp.bottom).offset(5)
            make.leading.equalTo(self.snp.leading).offset(10)
            make.width.equalTo(40)
            make.height.equalTo(18)
        }
        monthlyFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.centerY).offset(5)
            make.leading.equalTo(monthlyFeeGuideLabel.snp.trailing).offset(10)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(18)
        }
        charterFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(monthlyFeeLabel.snp.bottom).offset(5)
            make.leading.equalTo(charterFeeGuideLabel.snp.trailing).offset(10)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(18)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpBorder()
        self.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private func setUpBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.appColor(.neutral400).cgColor
    }
}
