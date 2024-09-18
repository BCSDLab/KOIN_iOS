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

final class MyKeyWordCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private var keyWord: String = ""
    let tapDeleteButtonPublisher = PassthroughSubject<String, Never>()
    
    // MARK: - UI Components
 
    private let keyWordLabel = UILabel().then {
        $0.textColor = .appColor(.neutral500)
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .center
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(.appImage(asset: .delete), for: .normal)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        deleteButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keyWord: String) {
        keyWordLabel.text = keyWord
        self.keyWord = keyWord
    }
    
    @objc func tapDeleteButton(sender: UIButton) {
        tapDeleteButtonPublisher.send(keyWord)
    }
}

extension MyKeyWordCollectionViewCell {
    private func setUpLayouts() {
        [keyWordLabel, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        keyWordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(34)
        }
        
        deleteButton.snp.makeConstraints {
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

