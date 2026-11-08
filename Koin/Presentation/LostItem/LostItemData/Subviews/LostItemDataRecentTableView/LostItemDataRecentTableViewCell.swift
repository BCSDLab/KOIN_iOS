//
//  LostItemDataRecentTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit

final class LostItemDataRecentTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let typeLabel = UILabel()
    
    private let titleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    private let categoryLabel = paddingLabel(padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)).then {
        $0.font = .appFont(.pretendardMedium, size: 10)
        $0.layer.cornerRadius = 9
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    private let foundPlaceLabel = UILabel().then {
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    private let foundPlaceSeparatorLabel = UILabel().then {
        $0.text = "|"
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    private let foundDateLabel = UILabel().then {
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let isFoundLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(lostItemListData: LostItemListData) {
        typeLabel.text = "\(lostItemListData.type.description)물"
        let categoryColors = LostItemColorAsset(rawValue: lostItemListData.category) ?? .unknown
        categoryLabel.text = lostItemListData.category
        categoryLabel.backgroundColor = .appColor(categoryColors.background)
        categoryLabel.textColor = .appColor(categoryColors.foreground)
        foundPlaceLabel.text = lostItemListData.foundPlace
        foundDateLabel.text = lostItemListData.foundDate
        
        if lostItemListData.isFound {
            isFoundLabel.text = "찾음"
            isFoundLabel.textColor = .appColor(.neutral0)
            isFoundLabel.backgroundColor = .appColor(.neutral400)
        } else {
            isFoundLabel.text = "찾는중"
            isFoundLabel.textColor = .appColor(.neutral0)
            isFoundLabel.backgroundColor = .appColor(.new700)
        }
    }
}

extension LostItemDataRecentTableViewCell {
    
    private func configureLabels() {
        // textColor
        [typeLabel].forEach { $0.textColor = .appColor(.new500) }
        [foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach { $0.textColor = .appColor(.neutral800) }
        
        // font
        [typeLabel].forEach { $0.font = .appFont(.pretendardSemiBold, size: 12) }
        [foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach { $0.font = .appFont(.pretendardMedium, size: 14) }
        [isFoundLabel].forEach { $0.font = .appFont(.pretendardMedium, size: 12) }
    }
    
    private func setUpLayouts() {
        [categoryLabel, foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [typeLabel, titleStackView, isFoundLabel, separatorView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        typeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        categoryLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        titleStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(typeLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(isFoundLabel.snp.leading).offset(-8)
        }
        isFoundLabel.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(23)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func configureView() {
        configureLabels()
        setUpLayouts()
        setUpConstraints()
        selectionStyle = .none
    }
}
