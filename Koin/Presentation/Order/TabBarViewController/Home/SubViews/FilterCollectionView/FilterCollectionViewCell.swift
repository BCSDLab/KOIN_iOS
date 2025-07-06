//
//  FilterCollectionViewCell.swift
//  koin
//
//  Created by 이은지 on 6/21/25.
//

import UIKit
import SnapKit

final class FilterCollectionViewCell: UICollectionViewCell {
        
    private var itemRow: Int?
    private let selectedBackgroundColor = UIColor.appColor(.new500)
    private let unselectedBackgroundColor   = UIColor.white
    private let selectedTitleColor = UIColor.white
    private let unselectedTitleColor = UIColor.appColor(.neutral400)
    
    private let filterImageView = UIImageView().then {
        $0.layer.masksToBounds = true
    }
    
    private let filterTitleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.layer.shadowColor   = UIColor.black.cgColor
        contentView.layer.shadowOffset  = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius  = 4
        contentView.layer.shadowOpacity = 0.04
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dataBind(_ itemData: OrderFilterData, itemRow: Int) {
        filterImageView.image = itemData.image
        filterTitleLabel.text = itemData.label
        contentView.backgroundColor = itemData.isSelected
            ? UIColor.appColor(.new500)
        : .white
        self.itemRow = itemRow
        applyStyle(selected: isSelected)
    }
    
    override var isSelected: Bool {
        didSet { applyStyle(selected: isSelected) }
    }

    private func applyStyle(selected: Bool) {
        contentView.backgroundColor = selected ? selectedBackgroundColor : unselectedBackgroundColor
        filterImageView.tintColor = selected ? selectedTitleColor : unselectedTitleColor
        filterTitleLabel.textColor = selected ? selectedTitleColor : unselectedTitleColor
    }
}

extension FilterCollectionViewCell {
    private func setUpLayouts() {
        [filterImageView, filterTitleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        filterImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(17)
        }
        
        filterTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(filterImageView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(8)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
