//
//  LandImageCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Combine
import UIKit

final class LandImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let landImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageString: String) {
        landImageView.loadImage(from: imageString)
    }
}

extension LandImageCollectionViewCell {
    private func setUpLayouts() {
        [landImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        landImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.backgroundColor = UIColor.appColor(.neutral400)
    }
    
}
