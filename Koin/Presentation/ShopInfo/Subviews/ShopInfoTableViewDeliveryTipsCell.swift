//
//  ShopInfoTableViewDeliveryTipsCell.swift
//  koin
//
//  Created by 홍기정 on 10/13/25.
//

import UIKit

final class ShopInfoTableViewDeliveryTipsCell: UITableViewCell {
    
    // MARK: - Components
    private let titleLabel = UILabel().then {
        $0.contentMode = .center
        $0.font = .appFont(.pretendardSemiBold, size: 15)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let deliveryTipsCollectionView = DeliveryTipsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.scrollDirection = .vertical
    }).then {
        $0.isScrollEnabled = false
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral50)
    }
    
    // MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, deliveryTips: [DeliveryTip]) {
        titleLabel.text = title
        deliveryTipsCollectionView.configure(deliveryTips: deliveryTips)
        deliveryTipsCollectionView.snp.makeConstraints {
            $0.height.equalTo(30 * deliveryTips.count)
        }
    }
}

extension ShopInfoTableViewDeliveryTipsCell {
    
    private func setUpLayout() {
        [titleLabel, deliveryTipsCollectionView, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        deliveryTipsCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-18)
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(6)
        }
    }
        
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
