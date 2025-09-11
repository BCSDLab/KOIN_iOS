//
//  ShopDetailBottomSheet.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import UIKit
import SnapKit

class ShopDetailBottomSheet: UIView {
    
    // MARK: - Component
    let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    let priceLabel = UILabel().then {
        $0.text = "0원"
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
    }
    let isDeliveryAvailableLabel = UILabel().then {
        $0.text = "배달 불가"
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.contentMode = .center
    }
    let shoppingListButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        $0.configuration = configuration
        $0.backgroundColor = .appColor(.new500)
        $0.setAttributedTitle(NSAttributedString(
            string: "장바구니 보기",
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : UIColor.appColor(.neutral0)
            ]), for: .normal)
        $0.setImage(UIImage.appImage(asset: .countIcon0)?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(price: Int, isDeliveryAvailable: Bool, numberOfShoppingList: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        priceLabel.text = formatter.string(from: NSNumber(value: price)) ?? "-" + "원"

        isDeliveryAvailableLabel.text = isDeliveryAvailable ? "배달 가능" : "배달 불가"
        
        switch numberOfShoppingList {
        case 0: shoppingListButton.setImage(.appImage(asset: .countIcon0), for: .normal)
        case 1: shoppingListButton.setImage(.appImage(asset: .countIcon1), for: .normal)
        case 2: shoppingListButton.setImage(.appImage(asset: .countIcon2), for: .normal)
        case 3: shoppingListButton.setImage(.appImage(asset: .countIcon3), for: .normal)
        case 4: shoppingListButton.setImage(.appImage(asset: .countIcon4), for: .normal)
        case 5: shoppingListButton.setImage(.appImage(asset: .countIcon5), for: .normal)
        case 6: shoppingListButton.setImage(.appImage(asset: .countIcon6), for: .normal)
        case 7: shoppingListButton.setImage(.appImage(asset: .countIcon7), for: .normal)
        case 8: shoppingListButton.setImage(.appImage(asset: .countIcon8), for: .normal)
        case 9: shoppingListButton.setImage(.appImage(asset: .countIcon9), for: .normal)
        default: shoppingListButton.setImage(.appImage(asset: .countIcon9Plus), for: .normal)
        }
    }
}

extension ShopDetailBottomSheet {
    
    private func setUpConstraints() {
        if(!UIApplication.hasHomeButton()){
            separatorView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview().offset(-34)
            }
        }
        priceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(29)
        }
        isDeliveryAvailableLabel.snp.makeConstraints {
            $0.leading.equalTo(priceLabel)
            $0.top.equalTo(priceLabel.snp.bottom)
            $0.height.equalTo(19)
        }
        shoppingListButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-32)
        }
    }

    
    private func setUpLayout() {
        [separatorView, priceLabel, isDeliveryAvailableLabel, shoppingListButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 32
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        layer.cornerRadius = 32
        layer.masksToBounds = false
        layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.12, x: 0, y: 24, blur: 60, spread: 0)
    }
    
    private func configureView() {
        setUpView()
        setUpLayout()
        setUpConstraints()
    }
}
