//
//  OrderShopCollectionViewCell.swift
//  koin
//
//  Created by 이은지 on 6/30/25.
//

import UIKit
import SnapKit
import Kingfisher

final class OrderShopCollectionViewCell: UICollectionViewCell {
        
    private var itemRow: Int?
    
    // 프로퍼티로만 보유
    private var shopId: Int = 0
    private var orderableShopId: Int = 0
    private var minimumOrderLabel: Int = 0
    
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
    
    private let statusView = UIView().then {
        $0.backgroundColor = .black
        $0.alpha = 0.6
    }
    
    private let statusLabel = UILabel().then {
        $0.text = "영업이 종료된 가게에요!"
        $0.textColor = .white
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
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
        self.itemRow = itemRow
        
        shopId = info.shopId
        orderableShopId = info.orderableShopId
        
        if let urlString = info.imageUrls.first, let url = URL(string: urlString) {
            shopImageView.kf.setImage(
                with: url,
                placeholder: UIImage.appImage(asset: .defaultMenuImage)
            )
        } else {
            shopImageView.image = UIImage.appImage(asset: .defaultMenuImage)
        }
        
        shopTitleLabel.text = info.name
        
        // 별점
        starImageView.image = info.ratingAverage > 0
            ? UIImage.appImage(asset: .star)
            : UIImage.appImage(asset: .emptyStar)
        ratingLabel.text = String(format: "%.1f", info.ratingAverage)
        
        // 리뷰 개수
        switch info.reviewCount {
        case 0:
            reviewCountLabel.text = "첫 번째 리뷰를 작성해보세요 :)"
        case 1...9:
            reviewCountLabel.text = "(리뷰 \(info.reviewCount)개)"
        default:
            reviewCountLabel.text = "(리뷰 10+개)"
        }
        
        // 배달 정보
        if info.isDeliveryAvailable {
            deliveryLabel.text = "배달비 \(info.minimumDeliveryTip)원~\(info.maximumDeliveryTip)원"
        } else {
            deliveryLabel.text = "배달 불가"
        }
        
        // MARK: - mock 데이터 넣기
        // 아래 프로퍼티들에만 세팅 (뷰에는 아직 추가되지 않음)
        minimumOrderLabel = Int(info.minimumOrderAmount)
        statusView.isHidden  = info.isOpen
        statusLabel.isHidden = info.isOpen
    }
}

extension OrderShopCollectionViewCell {
    private func setUpLayouts() {
        [shopImageView, shopTitleLabel, starImageView, ratingLabel, reviewCountLabel, deliveryImageView, deliveryLabel, statusView, statusLabel].forEach {
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
        
        statusView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        statusLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
