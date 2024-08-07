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
    
    private let deliveryLabel: UILabel = {
        let label = UILabel()
        label.text = "배달"
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    private let cardLabel: UILabel = {
        let label = UILabel()
        label.text = "카드결제"
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.text = "계좌이체"
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
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
    
    func configure(info: ShopDTO) {
        shopTitleLabel.text = info.name
        deliveryLabel.textColor = info.delivery ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral300)
        cardLabel.textColor = info.payCard ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral300)
        accountLabel.textColor = info.payBank ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral300)
        shopReadyView.setShopTitle(text: info.name)
        shopReadyView.isHidden = info.isOpen ? true : false
        eventLabel.isHidden = info.isEvent ? false : true
    }
}

extension ShopInfoCollectionViewCell {
    private func setUpLayouts() {
        [borderView, shopTitleLabel, deliveryLabel, cardLabel, accountLabel, shopReadyView, eventLabel].forEach {
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
            make.leading.equalTo(self.snp.leading).offset(16)
            make.top.equalTo(eventLabel.snp.bottom).offset(5)
        }
        
        accountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(shopTitleLabel.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-16)
        }
        cardLabel.snp.makeConstraints { make in
            make.centerY.equalTo(shopTitleLabel.snp.centerY)
            make.trailing.equalTo(accountLabel.snp.leading).offset(-8)
        }
        deliveryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(shopTitleLabel.snp.centerY)
            make.trailing.equalTo(cardLabel.snp.leading).offset(-8)
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

