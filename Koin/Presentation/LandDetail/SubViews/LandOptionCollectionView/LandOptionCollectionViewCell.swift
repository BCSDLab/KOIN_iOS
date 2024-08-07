//
//  LandOptionCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import UIKit

final class LandOptionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(.pretendardRegular, size: 10)
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: ImageAsset, text: String, exist: Bool) {
        imageView.image = UIImage.appImage(asset: image)
        descriptionLabel.text = text
        
        imageView.alpha = exist ? 1.0 : 0.3
        descriptionLabel.alpha = exist ? 1.0 : 0.3
 
    }
}

extension LandOptionCollectionViewCell {
    private func setUpLayouts() {
        [imageView, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalTo(self.snp.centerY).offset(-10)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.width.equalTo(self.snp.width)
            make.centerX.equalTo(self.snp.centerX)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}
