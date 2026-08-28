//
//  FilterGroupCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 8/27/26.
//

import UIKit
import SnapKit
import Then

final class FilterGroupCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(item model: FilterItemModel) {
        titleLabel.text = model.title
        titleLabel.textColor = model.isSelected ? .appColor(.new500) : .appColor(.neutral500)
        contentView.layer.borderColor = model.isSelected
            ? UIColor.appColor(.new500).cgColor
            : UIColor.appColor(.neutral300).cgColor
    }
}

extension FilterGroupCollectionViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.font = .appFont(.pretendardSemiBold, size: 14)
            $0.textAlignment = .center
        }
        contentView.do {
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 17
            $0.clipsToBounds = true
        }
    }
    
    private func setUpLayouts() {
        contentView.addSubview(titleLabel)
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
}
