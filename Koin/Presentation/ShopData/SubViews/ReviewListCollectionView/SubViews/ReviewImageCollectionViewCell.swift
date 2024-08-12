//
//  ReviewImageCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Then
import UIKit

final class ReviewImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let menuImageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageURL: String) {
        menuImageView.loadImage(from: imageURL)
    }
}

extension ReviewImageCollectionViewCell {
    private func setUpLayouts() {
        [menuImageView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        menuImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}
