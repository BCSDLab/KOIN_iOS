//
//  MenuListCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import UIKit

final class MenuListCollectionViewCell: UICollectionViewCell {
    
    var onTap: ((UIImage?) -> Void)?
    
    // MARK: - UI Components
    
    private let menuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let menuTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        return label
    }()
    
    private let priceLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 14)
        label.text = "-"
        label.textColor = UIColor.appColor(.primary500)
        return label
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral200)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        menuImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        menuTitleLabel.text = ""
        priceLabel.text = ""
        menuImageView.image = nil
    }
    
    func configure(menuName: String, price: Int, imageUrls: [String]?) {
        
        menuTitleLabel.text = menuName
        priceLabel.text = "\(price.formattedWithComma) 원"
        
        guard let imageUrls = imageUrls else {
            menuImageView.image = UIImage.appImage(asset: .defaultMenuImage)
            return
        }
        if imageUrls.isEmpty {
            menuImageView.image = UIImage.appImage(asset: .defaultMenuImage)
        } else {
            menuImageView.loadImage(from: imageUrls[0])
        }
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
           let image = imageView.image
           onTap?(image)
    }
    
}

extension MenuListCollectionViewCell {

    private func setUpLayouts() {
        [menuImageView, menuTitleLabel, priceLabel, separateView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        menuImageView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading)
            make.width.equalTo(68)
            make.height.equalTo(68)
        }
        
        menuTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuImageView.snp.top).offset(10)
            make.leading.equalTo(menuImageView.snp.trailing).offset(16)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(19)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(menuTitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(menuTitleLabel.snp.leading)
        }
        
        separateView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(1)
        }
        
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }

    
}

