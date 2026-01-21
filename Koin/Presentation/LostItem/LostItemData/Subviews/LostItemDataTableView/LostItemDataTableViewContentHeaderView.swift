//
//  LostItemDataTableViewContentHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit

final class LostItemDataTableViewContentHeaderView: UIView {
    
    // MARK: - UI Components
    private let typeLabel = UILabel()
    private let isFoundLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        $0.alignment = .fill
    }
    private let categoryLabel = paddingLabel(padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)).then {
        $0.backgroundColor = .appColor(.primary500)
        $0.layer.cornerRadius = 11
        $0.clipsToBounds = true
        $0.textAlignment = .center
    }
    private let foundPlaceLabel = UILabel().then {
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    private let foundPlaceSeparatorLabel = UILabel().then {
        $0.text = "|"
    }
    private let foundDateLabel = UILabel()
    
    private let authorStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
    }
    private let registeredDateLabel = UILabel()
    private let authorLabel = UILabel()
    private let authorSeparatorLabel = UILabel().then {
        $0.text = "•"
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(lostItemData: LostItemData) {
        typeLabel.text = "\(lostItemData.type.description)물"
        categoryLabel.text = lostItemData.category
        foundPlaceLabel.text = lostItemData.foundPlace
        foundDateLabel.text = lostItemData.foundDate
        registeredDateLabel.text = lostItemData.registeredAt
        authorLabel.text = lostItemData.author
        
        if lostItemData.isFound {
            isFoundLabel.text = "찾음"
            isFoundLabel.textColor = .appColor(.neutral400)
            isFoundLabel.backgroundColor = .appColor(.neutral100)
        } else {
            isFoundLabel.text = "찾는중"
            isFoundLabel.textColor = .appColor(.neutral0)
            isFoundLabel.backgroundColor = UIColor(hexCode: "FFA928")
        }
    }
}

extension LostItemDataTableViewContentHeaderView {
    
    private func configureLabels() {
        // textColor
        [typeLabel].forEach { $0.textColor = .appColor(.primary600) }
        [categoryLabel].forEach { $0.textColor = .appColor(.neutral0) }
        [foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach { $0.textColor = .appColor(.neutral800) }
        [authorLabel, registeredDateLabel].forEach { $0.textColor = .appColor(.neutral500) }
        [authorSeparatorLabel].forEach { $0.textColor = .appColor(.neutral400) }
        
        // font
        [typeLabel].forEach { $0.font = .appFont(.pretendardSemiBold, size: 12) }
        [categoryLabel, foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach { $0.font = .appFont(.pretendardMedium, size: 14) }
        [authorLabel, authorSeparatorLabel, registeredDateLabel].forEach { $0.font = .appFont(.pretendardRegular, size: 12) }
        [isFoundLabel].forEach { $0.font = .appFont(.pretendardMedium, size: 12) }
    }
    
    private func setLayouts() {
        [categoryLabel, foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [authorLabel, authorSeparatorLabel, registeredDateLabel].forEach {
            authorStackView.addArrangedSubview($0)
        }
        [typeLabel, isFoundLabel, titleStackView, authorStackView, separatorView].forEach {
            addSubview($0)
        }
    }
    
    private func setConstraints() {
        typeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(19)
        }
        isFoundLabel.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(23)
            $0.top.equalToSuperview().offset(33)
            $0.trailing.equalToSuperview().offset(-24)
        }
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(isFoundLabel.snp.leading).offset(-8)
            $0.height.equalTo(23)
        }
        authorStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(isFoundLabel.snp.leading).offset(-8)
            $0.height.equalTo(19)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
    private func configureView() {
        configureLabels()
        setLayouts()
        setConstraints()
        backgroundColor = .white
    }
}
