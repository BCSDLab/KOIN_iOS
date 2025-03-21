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
    private let menuImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
        $0.isUserInteractionEnabled = true
    }
    
    private let menuTitleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let priceLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.text = "-"
        $0.textColor = UIColor.appColor(.primary500)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }
    
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
            menuImageView.isHidden = true
        } else {
            menuImageView.isHidden = false
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
            make.trailing.equalTo(separateView.snp.trailing)
            make.width.equalTo(68)
            make.height.equalTo(68)
        }
        
        menuTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuImageView.snp.top).offset(10)
            make.leading.equalTo(separateView.snp.leading)
            make.trailing.equalTo(menuImageView.snp.leading).offset(-10)
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

