//
//  OrderCartBottomSheet.swift
//  koin
//
//  Created by 홍기정 on 9/30/25.
//

import UIKit
import Combine
import SnapKit

final class OrderCartBottomSheet: UIView {
    
    // MARK: - Properties
    let bottomSheetButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let priceLabel = UILabel().then {
        $0.font = .appFont(.pretendardSemiBold, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
    }
    private let isDeliveryAvailableLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.contentMode = .center
    }
    private let shoppingListButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50)
        $0.configuration = configuration
        $0.setAttributedTitle(NSAttributedString(
            string: "주문하기",
            attributes: [
                .font : UIFont.appFont(.pretendardSemiBold, size: 14),
                .foregroundColor : UIColor.appColor(.neutral0)
            ]), for: .normal)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(shopMinimumOrderAmount: Int, totalAmount: Int, finalPaymentAmount: Int, itemsCount: Int, isPickUp: Bool) {
        
        let formatter = NumberFormatter().then {
            $0.numberStyle = .decimal
        }
        priceLabel.text = (formatter.string(from: NSNumber(value: finalPaymentAmount)) ?? "-") + "원"
        
        if isPickUp {
            isDeliveryAvailableLabel.text = "주문 가능"
            configureButton(count: itemsCount, isEnabled: true)
            return
        } else {
            switch shopMinimumOrderAmount <= totalAmount {
            case true:
                isDeliveryAvailableLabel.text = "배달 가능"
                configureButton(count: itemsCount, isEnabled: true)
            case false:
                let difference = formatter.string(from: NSNumber(value: shopMinimumOrderAmount - totalAmount)) ?? "-"
                isDeliveryAvailableLabel.text = "\(difference)원 더 담으면 배달 가능"
                configureButton(count: itemsCount, isEnabled: false)
            }
        }
    }
    
    private func configureButton(count: Int, isEnabled: Bool) {
        switch count {
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
        setNeedsLayout()
        layoutIfNeeded()
        shoppingListButton.backgroundColor = isEnabled ? .appColor(.new500) : .appColor(.neutral300)
    }
}

extension OrderCartBottomSheet {
    
    private func addTargets() {
        shoppingListButton.addTarget(self, action: #selector(bottomSheetButtonTapped), for: .touchUpInside)
    }
    
    @objc private func bottomSheetButtonTapped() {
        bottomSheetButtonTappedPublisher.send()
    }
}
extension OrderCartBottomSheet {
    
    private func setUpConstraints() {
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
        if(!UIApplication.hasHomeButton()){
            separatorView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview().offset(-34)
            }
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
