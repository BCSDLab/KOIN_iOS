//
//  ShopInfoCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import UIKit

final class ShopInfoCollectionViewCell: UICollectionViewCell {
    
    private let eventLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "이벤트 ")
        label.textAlignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardMedium, size: 8),
            .foregroundColor: UIColor.appColor(.primary300),
            .baselineOffset: 3
        ]
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage.appImage(asset: .lamp)
        imageAttachment.bounds = CGRect(x: 0, y: 3, width: 7, height: 7)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        label.layer.borderColor = UIColor.appColor(.primary300).cgColor
        label.layer.borderWidth = 0.5
        label.attributedText = attributedString
        label.backgroundColor = .systemBackground
        return label
    }()

    private let borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.appColor(.neutral200).cgColor
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let shopTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.neutral800)
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let benefitLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.primary300)
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    private let starImageView = UIImageView().then { _ in
    }
    
    private let ratingLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let reviewCountLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let shopReadyView: ShopReadyView = {
        let view = ShopReadyView(frame: .zero)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(info: Shop) {
        shopTitleLabel.text = info.name
        shopReadyView.setShopTitle(text: info.name)
        shopReadyView.isHidden = info.isOpen ? true : false
        eventLabel.isHidden = info.isEvent ? false : true
        starImageView.image = info.reviewCount > 0 ? UIImage.appImage(asset: .star) : UIImage.appImage(asset: .emptyStar)
        ratingLabel.text = "\(info.averageRate)"
        switch info.reviewCount {
        case 0: reviewCountLabel.text = "첫 번째 리뷰를 작성해보세요 :)"
        case 1...9: reviewCountLabel.text = "( 리뷰 \(info.reviewCount)개 )"
        default: reviewCountLabel.text = "( 리뷰 10+ 개 )"
        }
        
        if let detail = info.benefitDetail {
            benefitLabel.text = info.benefitDetail
        } else {
            benefitLabel.text = info.benefitDetails.first
        }
        benefitLabel.isHidden = info.isOpen ? false : true
    }
}

extension ShopInfoCollectionViewCell {
    private func setUpLayouts() {
        [borderView, shopTitleLabel, starImageView, ratingLabel, reviewCountLabel, shopReadyView, eventLabel, benefitLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        eventLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading).offset(8)
            make.width.equalTo(40)
            make.height.equalTo(14)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(eventLabel.snp.top).offset(4)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        shopTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.top).offset(12)
            make.leading.equalTo(self.snp.leading).offset(16)
        }
        benefitLabel.snp.makeConstraints { make in
            make.centerY.equalTo(shopTitleLabel.snp.centerY)
            make.leading.equalTo(shopTitleLabel.snp.trailing).offset(8)
        }
        
        starImageView.snp.makeConstraints { make in
            make.top.equalTo(shopTitleLabel.snp.bottom).offset(6)
            make.leading.equalTo(shopTitleLabel.snp.leading)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        ratingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(starImageView.snp.centerY)
            make.leading.equalTo(starImageView.snp.trailing).offset(3)
        }
        reviewCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(starImageView.snp.centerY)
            make.leading.equalTo(ratingLabel.snp.trailing).offset(3)
        }
        
        shopReadyView.snp.makeConstraints { make in
            make.height.width.leading.top.equalTo(borderView)
        }
    }
    
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

