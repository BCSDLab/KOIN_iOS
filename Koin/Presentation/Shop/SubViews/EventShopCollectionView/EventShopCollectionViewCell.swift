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
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.image = nil
        eventTextLabel.text = ""
    }

    func configure(_ shop: EventDTO) {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        eventImageView.layer.sublayers?.first?.frame = eventImageView.bounds
    }

    @objc private func didTapCell() {
        onTap?(shopId ?? 0)
    }

    private func updateEventText(shopName: String) {
        let shopAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardBold, size: 18),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]
        let eventAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardMedium, size: 15),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]
        let storeTitle = NSMutableAttributedString(string: shopName, attributes: shopAttributes)
        let eventText = NSMutableAttributedString(string: "에서\n할인 혜택을 받아보세요!", attributes: eventAttributes)
        storeTitle.append(eventText)
        eventTextLabel.attributedText = storeTitle
    }
}

extension EventShopCollectionViewCell {
    private func setUpLayouts() {
        [eventImageView, eventTextLabel].forEach {
            contentView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        eventImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        eventTextLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(eventImageView.snp.top).offset(15)
        }
    }

    private func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = eventImageView.bounds

        let whiteColor = UIColor.appColor(.neutral100).withAlphaComponent(0.0).cgColor
        let blackColor40 = UIColor.black.withAlphaComponent(0.4).cgColor
        let blackColor50 = UIColor.black.withAlphaComponent(0.5).cgColor

        gradientLayer.colors = [whiteColor, blackColor40, blackColor50]
        gradientLayer.locations = [0.0, 0.4, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        eventImageView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        addGradientBackground()
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.appColor(.neutral100)
        contentView.layer.cornerRadius = 16
    }
}
