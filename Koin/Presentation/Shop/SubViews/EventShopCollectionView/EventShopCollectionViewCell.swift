//
//  EventShopCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 4/10/24.
//

import UIKit
import SnapKit

final class EventShopCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    var onTap: ((Int) -> Void)?
    var shopId: Int?

    // MARK: - UI Components
    private let koinEventLabel = UILabel().then {
        $0.text = "코인전용"
        $0.textColor = UIColor.appColor(.warning500)
        $0.font = UIFont.appFont(.pretendardBold, size: 12)
        $0.backgroundColor = .orange
        $0.textAlignment = .center
        $0.layer.cornerRadius = 9.5
        $0.layer.masksToBounds = true
    }

    private let eventImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .defaultMenuImage)
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }

    private let eventTextLabel = UILabel().then {
        $0.numberOfLines = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.image = nil
        eventTextLabel.text = ""
    }

    func configure(_ shop: EventDto) {
        updateEventText(shopName: shop.shopName)
        shopId = shop.shopId

        guard let imageList = shop.thumbnailImages else {
            eventImageView.image = UIImage.appImage(asset: .defaultMenuImage)
            return
        }

        if !imageList.isEmpty {
            eventImageView.loadImage(from: imageList[0])
        } else {
            eventImageView.image = UIImage.appImage(asset: .defaultMenuImage)
        }
    }

    @objc private func didTapCell() {
        onTap?(shopId ?? 0)
    }

    private func updateEventText(shopName: String) {
        let shopAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardBold, size: 20),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]
        let eventAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardBold, size: 14),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]
        let storeTitle = NSMutableAttributedString(string: shopName, attributes: shopAttributes)
        let eventText = NSMutableAttributedString(string: "에서\n코인 전용 할인혜택 받기!", attributes: eventAttributes)
        storeTitle.append(eventText)
        eventTextLabel.attributedText = storeTitle
    }
}

extension EventShopCollectionViewCell {
    private func setUpLayouts() {
        [koinEventLabel, eventImageView, eventTextLabel].forEach {
            contentView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        koinEventLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(16)
            $0.width.equalTo(54)
            $0.height.equalTo(19)
        }

        eventTextLabel.snp.makeConstraints {
            $0.leading.equalTo(koinEventLabel.snp.leading)
            $0.top.equalTo(koinEventLabel.snp.bottom).offset(2)
        }
        
        eventImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-19)
            $0.width.height.equalTo(100)
        }
    }

    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.appColor(.neutral100)
        contentView.layer.cornerRadius = 16
    }
}
