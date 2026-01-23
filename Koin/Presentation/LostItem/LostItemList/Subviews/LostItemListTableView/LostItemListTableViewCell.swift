//
//  LostItemListTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit

final class LostItemListTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let typeLabel = UILabel()
    private let isFoundLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let labelsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
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
    
    private let contentLabel = UILabel()
    
    private let blindStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    private let blindImageView = UIImageView(image: .appImage(asset: .blind)?.withTintColor(.appColor(.neutral500), renderingMode: .alwaysTemplate).resize(to: CGSize(width: 24, height: 24)))
    private let blindedLabel = UILabel().then {
        $0.text = "신고에 의해 숨김 처리 되었습니다."
    }
    
    private let authorStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
    }
    private let authorLabel = UILabel()
    private let authorSeparatorLabel = UILabel().then {
        $0.text = "•"
    }
    private let registeredDateLabel = UILabel()
    
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
        if lostItemListData.isReported {
            titleStackView.isHidden = true
            contentLabel.isHidden = true
            blindStackView.isHidden = false
        } else {
            titleStackView.isHidden = false
            contentLabel.isHidden = false
            blindStackView.isHidden = true
        }
        
        if lostItemListData.isFound {
            isFoundLabel.text = "찾음"
            isFoundLabel.textColor = .appColor(.neutral400)
            isFoundLabel.backgroundColor = .appColor(.neutral100)
        } else {
            isFoundLabel.text = "찾는중"
            isFoundLabel.textColor = .appColor(.neutral0)
            isFoundLabel.backgroundColor = UIColor(hexCode: "FFA928")
        }
        
        typeLabel.text = "\(lostItemListData.type.description)물"
        categoryLabel.text = lostItemListData.category
        foundPlaceLabel.text = lostItemListData.foundPlace
        foundDateLabel.text = lostItemListData.foundDate
        contentLabel.text = lostItemListData.content
        authorLabel.text = lostItemListData.author
        registeredDateLabel.text = lostItemListData.registeredAt
    }
}

extension LostItemListTableViewCell {
    
    private func configureLabels() {
        // textColor
        [typeLabel].forEach { $0.textColor = .appColor(.primary600) }
        [categoryLabel].forEach { $0.textColor = .appColor(.neutral0) }
        [foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel, contentLabel].forEach { $0.textColor = .appColor(.neutral800) }
        [blindedLabel, authorLabel, registeredDateLabel].forEach { $0.textColor = .appColor(.neutral500) }
        [authorSeparatorLabel].forEach { $0.textColor = .appColor(.neutral400) }
        
        // font
        [typeLabel].forEach { $0.font = .appFont(.pretendardSemiBold, size: 12) }
        [categoryLabel, foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel, blindedLabel].forEach { $0.font = .appFont(.pretendardMedium, size: 14) }
        [contentLabel, authorLabel, authorSeparatorLabel, registeredDateLabel].forEach { $0.font = .appFont(.pretendardRegular, size: 12) }
        [isFoundLabel].forEach { $0.font = .appFont(.pretendardMedium, size: 12) }
    }
    
    private func setLayouts() {
        [categoryLabel, foundPlaceLabel, foundPlaceSeparatorLabel, foundDateLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [blindImageView, blindedLabel].forEach {
            blindStackView.addArrangedSubview($0)
        }
        [authorLabel, authorSeparatorLabel, registeredDateLabel].forEach {
            authorStackView.addArrangedSubview($0)
        }
        [titleStackView, contentLabel, blindStackView, authorStackView].forEach {
            labelsStackView.addArrangedSubview($0)
        }
        [typeLabel, isFoundLabel, labelsStackView, separatorView].forEach {
            contentView.addSubview($0)
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
        labelsStackView.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(isFoundLabel.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().offset(-12)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        titleStackView.snp.makeConstraints {
            $0.height.equalTo(22)
        }
        contentLabel.snp.makeConstraints {
            $0.height.equalTo(14)
        }
        blindStackView.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        authorStackView.snp.makeConstraints {
            $0.height.equalTo(19)
        }
    }
    private func configureView() {
        configureLabels()
        setLayouts()
        setConstraints()
        selectionStyle = .none
    }
}
