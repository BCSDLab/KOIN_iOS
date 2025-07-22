//
//  FilterCollectionViewCell.swift
//  koin
//
//  Created by 이은지 on 6/21/25.
//

import UIKit
import SnapKit

final class FilterCollectionViewCell: UICollectionViewCell {
        
    private let selectedBackgroundColor = UIColor.appColor(.new500)
    private let unselectedBackgroundColor = UIColor.white
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
        
        contentView.layer.cornerRadius = 17
        contentView.layer.masksToBounds = true
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.04
        
        setUpLayouts()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with filter: ShopFilter, isSelected: Bool, price: Int?) {
        filterImageView.image = filter.image
        
        let attributedString = NSMutableAttributedString(attributedString: filter.title(for: price))
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let color = isSelected ? selectedTitleColor : unselectedTitleColor
        attributedString.addAttribute(.foregroundColor, value: color, range: fullRange)

        if filter == .MIN_PRICE, let price = price {
            let range = (attributedString.string as NSString).range(of: "\(price.formattedWithComma)원 이하")
            attributedString.addAttribute(.foregroundColor, value: isSelected ? selectedTitleColor : UIColor.appColor(.new500), range: range)
        }

        filterTitleLabel.attributedText = attributedString
        applyStyle(selected: isSelected)
        updateLayout(for: filter)
    }

    func updateTitle(text: NSAttributedString) {
        filterTitleLabel.attributedText = text
    }

    private func applyStyle(selected: Bool) {
        contentView.backgroundColor = selected ? selectedBackgroundColor : unselectedBackgroundColor
        filterImageView.tintColor = selected ? selectedTitleColor : unselectedTitleColor
    }
    
    private func updateLayout(for filter: ShopFilter) {
        if filter == .MIN_PRICE {
            filterTitleLabel.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(12)
                $0.centerY.equalToSuperview()
            }
            
            filterImageView.snp.remakeConstraints {
                $0.leading.equalTo(filterTitleLabel.snp.trailing).offset(6)
                $0.trailing.equalToSuperview().inset(12)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(17)
            }
        } else {
            filterImageView.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(17)
            }
            
            filterTitleLabel.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(filterImageView.snp.trailing).offset(6)
                $0.trailing.equalToSuperview().inset(8)
            }
        }
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
}

