//
//  MyKeyWordCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class MyKeywordCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    let tapDeleteButtonPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
 
    private let keywordLabel = UILabel().then {
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .center
    }
    
    private let deleteButton = UIImageView().then {
        $0.image = .appImage(asset: .delete)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keyWord: String) {
        keywordLabel.text = keyWord
    }
}

extension MyKeywordCollectionViewCell {
    private func setUpLayouts() {
        [keywordLabel, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keywordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(34)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(keywordLabel)
            $0.width.height.equalTo(16)
            $0.leading.equalTo(keywordLabel.snp.trailing).offset(2)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .appColor(.neutral100)
    }
}


