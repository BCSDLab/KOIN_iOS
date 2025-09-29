//
//  OrderCartSegmentedControl.swift
//  koin
//
//  Created by 홍기정 on 9/25/25.
//

import UIKit
import Combine

final class OrderCartSegmentedControl: UIView {
 
    // MARK: - Properties
    var isDeliveryAvailable: Bool = false
    var isPickupAvailable: Bool = false
    
    let selectedAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.appFont(.pretendardMedium, size: 14),
        .foregroundColor : UIColor.appColor(.neutral0)
    ]
    let deselectedAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.appFont(.pretendardMedium, size: 14),
        .foregroundColor : UIColor.appColor(.neutral500)
    ]
    let disabledAtrributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.appFont(.pretendardMedium, size: 14),
        .foregroundColor : UIColor.appColor(.neutral300)
    ]
    
    // MARK: - Components
    let buttonDelivery = UIButton()
    let buttonPickup = UIButton()
    let selectedBackgroundView = UIView().then {
        $0.backgroundColor = .appColor(.new500)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        addTargets()
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isDeliveryAvailable: Bool, isPickupAvailable: Bool) {
        self.isDeliveryAvailable = isDeliveryAvailable
        self.isPickupAvailable = isPickupAvailable
        configureButtons()
    }
}

extension OrderCartSegmentedControl {
    
    // MARK: - addTargets
    private func addTargets() {
        buttonDelivery.addTarget(self, action: #selector(buttonDeliveryTapped), for: .touchUpInside)
        buttonPickup.addTarget(self, action: #selector(buttonPickupTapped), for: .touchUpInside)
    }
    
    // MARK: - @objc
    @objc private func buttonDeliveryTapped() {
        guard isDeliveryAvailable else { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.selectedBackgroundView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(4)
            }
            layoutIfNeeded()
        }
        UIView.transition(with: buttonDelivery, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            self?.buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: self?.selectedAttributes), for: .normal)
        }
        UIView.transition(with: buttonPickup, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            self?.buttonPickup.setAttributedTitle(NSAttributedString(string: "포장", attributes: self?.deselectedAttributes), for: .normal)
        }
    }
    @objc private func buttonPickupTapped() {
        guard isPickupAvailable else { return }
        UIView.animate(withDuration: 0.2) {[weak self] in
            guard let self = self else { return }
            self.selectedBackgroundView.snp.updateConstraints {
                let offset = (self.frame.width - 12)/2 + 8
                $0.leading.equalToSuperview().offset(offset)
            }
            layoutIfNeeded()
        }
        UIView.transition(with: buttonDelivery, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            self?.buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: self?.deselectedAttributes), for: .normal)
        }
        UIView.transition(with: buttonPickup, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            self?.buttonPickup.setAttributedTitle(NSAttributedString(string: "포장", attributes: self?.selectedAttributes), for: .normal)
        }
    }
}

extension OrderCartSegmentedControl {
    
    
    private func configureButtons() {
        switch (isDeliveryAvailable, isPickupAvailable) {
        case (true, true):
            buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: selectedAttributes), for: .normal)
            buttonPickup.setAttributedTitle(NSAttributedString(string: "포장", attributes: deselectedAttributes), for: .normal)
        case (true, false):
            buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: selectedAttributes), for: .normal)
            buttonPickup.setAttributedTitle(NSAttributedString(string: "포장", attributes: disabledAtrributes), for: .normal)
        case (false, true):
            buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: disabledAtrributes), for: .normal)
            buttonPickup.setAttributedTitle(NSAttributedString(string: "포장", attributes: selectedAttributes), for: .normal)
        default:
            print("invalid state")
        }
    }
    
    private func setUpLayouts() {
        [selectedBackgroundView, buttonDelivery, buttonPickup].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        buttonDelivery.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalTo(self.snp.centerX).offset(-2)
            $0.top.bottom.equalToSuperview().inset(4)
        }
        buttonPickup.snp.makeConstraints {
            $0.leading.equalTo(self.snp.centerX).offset(2)
            $0.trailing.equalToSuperview().offset(-4)
            $0.top.bottom.equalToSuperview().inset(4)
        }
        selectedBackgroundView.snp.makeConstraints {
            $0.width.height.equalTo(buttonDelivery)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
        }
    }
    
    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 10
        clipsToBounds = true
        setUpLayouts()
        setUpConstraints()
    }
}
