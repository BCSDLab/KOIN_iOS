//
//  OrderCartShopTitleHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit
import Combine

final class OrderCartShopTitleHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    let moveToShopPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let thumbnailImageView = UIImageView().then {
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    private let titleButton = UIButton()
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        addTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(shopThumbnailImageUrl: String?, shopName: String) {
        if let shopThumbnailImageUrl = shopThumbnailImageUrl {
            thumbnailImageView.loadImage(from: shopThumbnailImageUrl)
        }
        else {
            thumbnailImageView.image = nil
            titleButton.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(28)
            }
        }
        configureButton(shopName: shopName)
        setNeedsLayout()
        layoutIfNeeded()
    }
}

extension OrderCartShopTitleHeaderView {

    private func addTargets() {
        titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)
    }
    
    @objc private func titleButtonTapped() {
        moveToShopPublisher.send()
    }
}

extension OrderCartShopTitleHeaderView {
    
    private func configureButton(shopName: String) {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(shopName, attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardSemiBold, size: 18),
            .foregroundColor : UIColor.appColor(.neutral800)
        ]))
        configuration.image = .appImage(asset: .chevronRight)?.withTintColor(.appColor(.neutral800)).resize(to: CGSize(width: 16, height: 16))
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 14
        configuration.contentInsets = .zero
        titleButton.configuration = configuration
        titleButton.contentMode = .center
    }
    
    private func setUpLayout() {
        [thumbnailImageView, titleButton].forEach {
            contentView.addSubview($0)
        }
    }
    private func setUpConstaints() {
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(28)
        }
        titleButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
        }
    }
    private func configureView() {
        setUpLayout()
        setUpConstaints()
    }
}
