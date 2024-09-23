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

final class RecommendedKeyWordCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    let recommendedKeyWordPublisher = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
 
    private let keyWordLabel = UILabel().then {
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .center
    }
    
    private let addButton = UIButton().then {
        $0.setImage(.appImage(asset: .plus), for: .normal)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addButton.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keyWord: String) {
        keyWordLabel.text = keyWord
    }
    
    @objc private func tapAddButton(sender: UIButton) {
        recommendedKeyWordPublisher.send()
    }
}

extension RecommendedKeyWordCollectionViewCell {
    private func setUpLayouts() {
        [keyWordLabel, addButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keyWordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(34)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(keyWordLabel)
            $0.width.height.equalTo(16)
            $0.leading.equalTo(keyWordLabel.snp.trailing).offset(2)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .appColor(.neutral100)
    }
}


