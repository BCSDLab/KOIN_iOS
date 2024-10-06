//
//  RecommendedKeyWordCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecommendedKeywordCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    let recommendedKeywordPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
 
    private let keywordLabel = UILabel().then {
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .center
    }
    
    private let addButton = UIImageView().then {
        $0.image = .appImage(asset: .plus)
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

extension RecommendedKeywordCollectionViewCell {
    private func setUpLayouts() {
        [keywordLabel, addButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keywordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(34)
        }
        
        addButton.snp.makeConstraints {
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


