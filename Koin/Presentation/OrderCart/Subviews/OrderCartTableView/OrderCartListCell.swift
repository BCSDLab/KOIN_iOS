//
//  OrderCartListCell.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//
/*
import UIKit

final class OrderCartListCell: UITableViewCell {
    
    // MARK: - Properties
    
    // MARK: - Components
    let nameLabel = UILabel().then {
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardSemiBold, size: 16)
    }
    let thumbnailImageView = UIImageView()
    let priceTableView = OrderCartListCellPriceTableView()
    let totalAmountLabel = UILabel().then {
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardSemiBold, size: 15)
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
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: CartItem) {
        nameLabel.text = item.name
        thumbnailImageView.loadImage(from: item.menuThumbnailImageUrl)
        configureQuantity(quantity: item.quantity)
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        totalAmountLabel.text = "\(formatter.string(from: NSNumber(value: item.totalAmount)) ?? "-")원"
        priceTableView.configure(price: item.price, options: item.options)
        
        priceTableView.snp.makeConstraints {
            $0.height.equalTo(21 * (item.options.count+1))
        }
    }
}

extension OrderCartListCell {
    
    private func configureQuantity(quantity: Int) {
        quantityLabel.text = "\(quantity)"
        
        trashcanButton.isHidden = quantity == 1 ? false : true
        minusButton.isHidden = 1 < quantity ? false : true
    }
    
    private func setUpLayout() {
        [nameLabel, thumbnailImageView, priceTableView, totalAmountLabel,
         changeOptionButton, quantityBackgroundView, quantityLabel, addButton, minusButton, trashcanButton].forEach {
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
        
        minusButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.trailing.equalTo(thumbnailImageView)
            $0.bottom.equalToSuperview().offset(-12)
        }
        quantityLabel.snp.makeConstraints {
            $0.centerY.equalTo(minusButton)
            $0.trailing.equalTo(minusButton.snp.leading).offset(-4)
        }
        [addButton, trashcanButton].forEach {
            $0.snp.makeConstraints {
                $0.width.height.equalTo(32)
                $0.trailing.equalTo(quantityLabel.snp.leading).offset(-4)
                $0.centerY.equalTo(minusButton)
            }
        }
        quantityBackgroundView.snp.makeConstraints {
            $0.leading.equalTo(addButton)
            $0.top.bottom.trailing.equalTo(minusButton)
        }
    }
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
*/
