//
//  ShopInfoCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import UIKit
import SnapKit
import Kingfisher

final class ShopInfoCollectionViewCell: UICollectionViewCell {
    
    private let shopImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let shopTitleLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let starImageView = UIImageView()
    
    private let ratingLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral400)
        $0.numberOfLines = 0
    }
    
    private let shopReadyView = ShopReadyView().then {
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.appColor(.neutral200).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // FIXME: - 이 "testimage.com"가 왜 로그에 뜨는지 모르겠음. 서버에도 없는데?!
    func configure(info: Shop) {
        if let urlString = info.images.first, let url = URL(string: urlString) {
            shopImageView.kf.setImage(
                with: url,
                placeholder: UIImage.appImage(asset: .defaultMenuImage),
                options: [.transition(.fade(0.2))]
            )
        } else {
            shopImageView.image = UIImage.appImage(asset: .defaultMenuImage)
        }
        
        shopTitleLabel.text = info.name
        shopReadyView.setShopTitle(text: info.name)
        shopReadyView.isHidden = info.isOpen
        starImageView.image = info.reviewCount > 0 ? UIImage.appImage(asset: .star) : UIImage.appImage(asset: .emptyStar)
        ratingLabel.text = "\(info.averageRate)"
        switch info.reviewCount {
        case 0: reviewCountLabel.text = "첫 번째 리뷰를 작성해보세요 :)"
        case 1...9: reviewCountLabel.text = "( 리뷰 \(info.reviewCount)개 )"
        default: reviewCountLabel.text = "( 리뷰 10+ 개 )"
        }
    }
}

extension ShopInfoCollectionViewCell {
    private func setUpLayouts() {
        [shopImageView, shopTitleLabel, starImageView, ratingLabel, reviewCountLabel, shopReadyView].forEach {
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
            $0.top.equalToSuperview().offset(39.5)
            $0.leading.equalTo(shopImageView.snp.trailing).offset(20)
            $0.height.equalTo(26)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(shopTitleLabel.snp.bottom).offset(5.5)
            $0.leading.equalTo(shopTitleLabel)
            $0.width.height.equalTo(16)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(4)
        }
        
        reviewCountLabel.snp.makeConstraints {
            $0.top.equalTo(starImageView.snp.top)
            $0.leading.equalTo(ratingLabel.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        shopReadyView.snp.makeConstraints {
            $0.top.leading.width.height.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
