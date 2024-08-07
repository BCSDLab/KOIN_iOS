//
//  CategoryCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//
import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.appFont(.pretendardRegular, size: 14)
        label.lineBreakMode = .byClipping
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(info: ShopCategory, _ selected: Bool) {
        imageView.loadImage(from: info.imageURL)
        titleLabel.text = info.name
        titleLabel.textColor = selected ? UIColor.appColor(.sub500) : UIColor.appColor(.neutral800)
        if selected { titleLabel.textColor = UIColor.appColor(.sub500) }
    }
}

extension CategoryCollectionViewCell {
    private func setUpLayouts() {
        [imageView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.centerX.equalTo(contentView.snp.centerX)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.height.equalTo(19)
            make.centerX.equalTo(imageView.snp.centerX)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
