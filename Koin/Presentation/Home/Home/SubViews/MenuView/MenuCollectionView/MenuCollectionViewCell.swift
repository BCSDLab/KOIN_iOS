//
//  MenuCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 1/21/24.
//

import UIKit

final class MenuCollectionViewCell: UICollectionViewCell {
    
    private let menuLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(labelText: String) {
        menuLabel.text = labelText
    }
    
}

extension MenuCollectionViewCell {
    private func setUpLayouts() {
        [menuLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        menuLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(18)
            make.width.equalTo(self.snp.width)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
