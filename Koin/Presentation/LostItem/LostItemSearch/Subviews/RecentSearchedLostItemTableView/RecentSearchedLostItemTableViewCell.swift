//
//  RecentSearchedLostItemTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class RecentSearchedLostItemTableViewCell: UITableViewCell {
    
    // MARK: - Property
    private var keyword: RecentSearchedLostItem?
    let deleteButtonTappedPublisher = PassthroughSubject<RecentSearchedLostItem, Never>()
    
    // MARK: - UI Components
    private let keywordLabel = UILabel().then {
        $0.text = "테스트"
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardRegular, size: 16)
    }
    private let deleteButton = UIButton().then {
        $0.setImage(.appImage(asset: .delete), for: .normal)
        $0.tintColor = .appColor(.neutral600)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setAddTarget()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keyword: RecentSearchedLostItem) {
        self.keyword = keyword
        keywordLabel.text = keyword.keyword
    }
}

extension RecentSearchedLostItemTableViewCell {
    
    private func setAddTarget() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    @objc private func deleteButtonTapped() {
        if let keyword {
            deleteButtonTappedPublisher.send(keyword)
        }
    }
}

extension RecentSearchedLostItemTableViewCell {
    
    private func configureView() {
        [keywordLabel, deleteButton].forEach {
            contentView.addSubview($0)
        }
        
        keywordLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(26)
        }
        deleteButton.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.leading.equalTo(keywordLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(keywordLabel)
        }
        
        selectionStyle = .none
    }
}
