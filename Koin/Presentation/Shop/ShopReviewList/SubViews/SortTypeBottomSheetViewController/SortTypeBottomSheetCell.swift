//
//  SortTypeBottomSheetCell.swift
//  koin
//
//  Created by 이은지 on 10/24/25.
//

import UIKit
import SnapKit

final class SortTypeBottomSheetCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let cellContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let sortTypeLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let checkmarkImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .check)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.appColor(.new400)
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    // MARK: - Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Function
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .white
        
        contentView.addSubview(cellContainerView)
        
        [sortTypeLabel, checkmarkImageView].forEach {
            cellContainerView.addSubview($0)
        }
        
        cellContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        sortTypeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }
    
    func configure(text: String, isSelected: Bool) {
        sortTypeLabel.text = text
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            sortTypeLabel.textColor = UIColor.appColor(.new400)
        } else {
            sortTypeLabel.textColor = UIColor.appColor(.neutral800)
        }
    }
}
