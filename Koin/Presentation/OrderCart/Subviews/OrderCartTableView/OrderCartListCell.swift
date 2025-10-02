//
//  OrderCartListCell.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit
import Combine

final class OrderCartListCell: UITableViewCell {
    
    // MARK: - Properties
    let addQuantityPublisher = PassthroughSubject<Int, Never>()
    let minusQuantityPublisher = PassthroughSubject<Int, Never>()
    let deleteItemPublisher = PassthroughSubject<(id: Int, indexPath: IndexPath), Never>()
    let changeOptionPublisher = PassthroughSubject<Int, Never>()
    private(set) var cartMenuItemId: Int? = nil
    private var indexPath: IndexPath? = nil
    
    // MARK: - Components
    let insetBackgroundView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.clipsToBounds = true
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 24
    }
    let nameLabel = UILabel().then {
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardBold, size: 16)
    }
    let thumbnailImageView = UIImageView().then {
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    let priceTableView = OrderCartListCellPriceTableView().then {
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
    }
    let totalAmountLabel = UILabel().then {
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardBold, size: 15)
    }
    let changeOptionButton = UIButton().then {
        $0.setAttributedTitle(NSAttributedString(string: "옵션 변경", attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]), for: .normal)
        $0.setAttributedTitle(NSAttributedString(string: "옵션 변경", attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]), for: .selected)
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    let quantityBackgroundView = UIView().then {
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    let quantityLabel = UILabel().then {
        $0.textColor = .appColor(.neutral600)
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .center
    }
    let addButton = UIButton().then {
        $0.setImage(.appImage(asset: .addThin), for: .normal)
    }
    let minusButton = UIButton().then {
        $0.setImage(.appImage(asset: .minus), for: .normal)
    }
    let trashcanButton = UIButton().then {
        $0.setImage(.appImage(asset: .trashcanNew), for: .normal)
    }
    let separaterView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setAddTarget()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: CartItem, isFirstRow: Bool, isLastRow: Bool, indexPath: IndexPath) {
        cartMenuItemId = item.cartMenuItemId
        nameLabel.text = item.name
        if let menuThumbnailImageUrl = item.menuThumbnailImageUrl {
            thumbnailImageView.loadImage(from: menuThumbnailImageUrl)
        }
        setUpQuantity(quantity: item.quantity)
        let formatter = NumberFormatter().then { $0.numberStyle = .decimal }
        totalAmountLabel.text = "\(formatter.string(from: NSNumber(value: item.totalAmount)) ?? "-")원"
        priceTableView.configure(price: item.price, options: item.options)
        priceTableView.snp.makeConstraints {
            $0.height.equalTo(21 * (item.options.count+1))
        }
        
        setUpInsetBackgroundView(isFirstRow: isFirstRow, isLastRow: isLastRow)
        
        self.indexPath = indexPath
    }
}

extension OrderCartListCell {
    
    private func setAddTarget() {
        changeOptionButton.addTarget(self, action: #selector(changeOptionButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        trashcanButton.addTarget(self, action: #selector(trashcanButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - @objc
    @objc private func addButtonTapped() {
        guard let cartMenuItemId = cartMenuItemId else {
            return
        }
        addQuantityPublisher.send(cartMenuItemId)
        updateQuantity(diff: 1)
    }
    @objc private func minusButtonTapped() {
        guard let cartMenuItemId = cartMenuItemId else {
            return
        }
        minusQuantityPublisher.send(cartMenuItemId)
        updateQuantity(diff: -1)
    }
    @objc private func trashcanButtonTapped() {
        guard let cartMenuItemId = cartMenuItemId, let indexPath = indexPath else {
            return
        }
        deleteItemPublisher.send((id: cartMenuItemId, indexPath: indexPath))
    }
    @objc private func changeOptionButtonTapped() {
        guard let cartMenuItemId = cartMenuItemId else {
            return
        }
        changeOptionPublisher.send(cartMenuItemId)
    }
    
}

extension OrderCartListCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}

extension OrderCartListCell {
    
    func setUpInsetBackgroundView(isFirstRow: Bool, isLastRow: Bool) {
        switch (isFirstRow, isLastRow) {
        case (true, true):
            insetBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                       .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (true, false):
            insetBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (false, true):
            insetBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (false, false):
            insetBackgroundView.layer.maskedCorners = []
        }
        
        switch isLastRow {
        case true:
            separaterView.isHidden = true
            insetBackgroundView.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        case false:
            separaterView.isHidden = false
            insetBackgroundView.layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    private func setUpQuantity(quantity: Int) {
        quantityLabel.text = "\(quantity)"
        trashcanButton.isHidden = quantity == 1 ? false : true
        minusButton.isHidden = 1 < quantity ? false : true
    }
    
    private func updateQuantity(diff: Int) {
        guard let text: String = quantityLabel.text,
              var quantity: Int = Int(text) else {
            return
        }
        quantity += diff
        quantityLabel.text = "\(quantity)"
        trashcanButton.isHidden = quantity == 1 ? false : true
        minusButton.isHidden = 1 < quantity ? false : true
    }
    
}

extension OrderCartListCell {
    
    private func setUpLayout() {
        [nameLabel, thumbnailImageView, priceTableView, totalAmountLabel,
         changeOptionButton, quantityBackgroundView, quantityLabel, addButton, minusButton, trashcanButton,
         separaterView].forEach {
            insetBackgroundView.addSubview($0)
        }
        [insetBackgroundView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(26)
        }
        thumbnailImageView.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-24)
        }
        priceTableView.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(thumbnailImageView.snp.leading)
        }
        totalAmountLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(priceTableView.snp.bottom).offset(8)
        }
        quantityBackgroundView.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.width.equalTo(78)
            $0.top.equalTo(totalAmountLabel.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-12)
            $0.trailing.equalTo(thumbnailImageView)
        }
        addButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.centerY.trailing.equalTo(quantityBackgroundView)
        }
        quantityLabel.snp.makeConstraints {
            $0.center.equalTo(quantityBackgroundView)
        }
        [minusButton, trashcanButton].forEach {
            $0.snp.makeConstraints {
                $0.width.height.equalTo(32)
                $0.centerY.leading.equalTo(quantityBackgroundView)
            }
        }
        changeOptionButton.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.width.equalTo(68)
            $0.top.bottom.equalTo(quantityBackgroundView)
            $0.trailing.equalTo(quantityBackgroundView.snp.leading).offset(-8)
        }
        separaterView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        insetBackgroundView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
    private func configureView() {
        backgroundColor = .clear
        backgroundView = .none
        setUpLayout()
        setUpConstraints()
    }
}

