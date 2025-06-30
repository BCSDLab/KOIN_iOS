//
//  OrderShopCollectionViewCell.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import UIKit
import SnapKit

final class OrderShopCollectionViewCell: UICollectionViewCell {
        
    private var itemRow: Int?
    
    private let shopImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let shopTitleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let starImageView = UIImageView().then { _ in
    }
    
    private let ratingLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let deliveryImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .delivery)
    }
    
    private let deliveryLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dataBind(_ info: OrderShop, itemRow: Int) {
        shopImageView.image = info.image
        shopTitleLabel.text = info.name
        starImageView.image = info.reviewCount > 0 ? UIImage.appImage(asset: .star) : UIImage.appImage(asset: .emptyStar)
        
        ratingLabel.text = "\(info.averageRate)"
        switch info.reviewCount {
        case 0: reviewCountLabel.text = "첫 번째 리뷰를 작성해보세요 :)"
        case 1...9: reviewCountLabel.text = "( 리뷰 \(info.reviewCount)개 )"
        default: reviewCountLabel.text = "( 리뷰 10+개 )"
        }
        deliveryLabel.text = "배달비 \(info.deliveryLabel)원"
        self.itemRow = itemRow
    }
}

extension OrderShopCollectionViewCell {
    private func setUpLayouts() {
        [shopImageView, shopTitleLabel, starImageView, ratingLabel, reviewCountLabel, deliveryImageView, deliveryLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shopImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(shopImageView.snp.height)
        }
        
        shopTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(shopImageView.snp.trailing).offset(20)
            $0.top.equalToSuperview().offset(15)
            $0.height.equalTo(26)
        }
        
        starImageView.snp.makeConstraints {
            $0.leading.equalTo(shopTitleLabel.snp.leading)
            $0.top.equalTo(shopTitleLabel.snp.bottom).offset(5.5)
            $0.width.height.equalTo(16)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.leading.equalTo(starImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(starImageView.snp.centerY)
            $0.height.equalTo(19)
        }
        
        reviewCountLabel.snp.makeConstraints {
            $0.leading.equalTo(ratingLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(starImageView.snp.centerY)
            $0.height.equalTo(19)
        }
        
        deliveryImageView.snp.makeConstraints {
            $0.leading.equalTo(shopTitleLabel.snp.leading)
            $0.top.equalTo(reviewCountLabel.snp.bottom).offset(3.5)
            $0.width.height.equalTo(16)
        }
        
        deliveryLabel.snp.makeConstraints {
            $0.leading.equalTo(deliveryImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(deliveryImageView.snp.centerY)
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
