//
//  ClubCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

import UIKit

final class ClubCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 31
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral700)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(_ item: ClubCategory, image: ImageAsset) {
        imageView.image = UIImage.appImage(asset: image)
        nameLabel.text = item.name
    }
    
}

extension ClubCollectionViewCell {
    private func setUpLayouts() {
        [imageView, nameLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(62)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.centerX.equalTo(imageView)
            make.height.equalTo(22)
        }
    }


    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

