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
    let buttonDeliveryTappedPublisher = PassthroughSubject<Void, Never>()
    let buttonTakeOutTappedPublisher = PassthroughSubject<Void, Never>()
    
    private let selectedAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.appFont(.pretendardMedium, size: 14),
        .foregroundColor : UIColor.appColor(.neutral0)
    ]
    private let deselectedAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.appFont(.pretendardMedium, size: 14),
        .foregroundColor : UIColor.appColor(.neutral500)
    ]
    private let disabledAtrributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.appFont(.pretendardMedium, size: 14),
        .foregroundColor : UIColor.appColor(.neutral300)
    ]
    
    // MARK: - Components
    private let buttonDelivery = UIButton()
    private let buttonTakeOut = UIButton()
    private let selectedBackgroundView = UIView().then {
        $0.backgroundColor = .appColor(.new500)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isDeliveryAvailable: Bool, isTakeOutAvailable: Bool) {
        configureButtons(isDeliveryAvailable: isDeliveryAvailable, isTakeOutAvailable: isTakeOutAvailable)
        addTargets(isDeliveryAvailable: isDeliveryAvailable, isTakeOutAvailable: isTakeOutAvailable)
        
        if !isDeliveryAvailable {
            selectedBackgroundView.snp.remakeConstraints {
                $0.width.height.equalTo(buttonTakeOut)
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-4)
            }
        }
    }
}

extension OrderCartSegmentedControl {
    
    // MARK: - addTargets
    private func addTargets(isDeliveryAvailable: Bool, isTakeOutAvailable: Bool) {
        if isDeliveryAvailable && isTakeOutAvailable {
            buttonDelivery.addTarget(self, action: #selector(buttonDeliveryTapped), for: .touchUpInside)
            buttonTakeOut.addTarget(self, action: #selector(buttonTakeOutTapped), for: .touchUpInside)
        }
    }
    
    // MARK: - @objc
    @objc private func buttonDeliveryTapped() {
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
        UIView.transition(with: buttonTakeOut, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            self?.buttonTakeOut.setAttributedTitle(NSAttributedString(string: "포장", attributes: self?.deselectedAttributes), for: .normal)
        }
        buttonDeliveryTappedPublisher.send()
    }
    @objc private func buttonTakeOutTapped() {
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
        UIView.transition(with: buttonTakeOut, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            self?.buttonTakeOut.setAttributedTitle(NSAttributedString(string: "포장", attributes: self?.selectedAttributes), for: .normal)
        }
        buttonTakeOutTappedPublisher.send()
    }
}

extension OrderCartSegmentedControl {
    
    
    private func configureButtons(isDeliveryAvailable: Bool, isTakeOutAvailable: Bool) {
        switch (isDeliveryAvailable, isTakeOutAvailable) {
        case (true, true):
            buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: selectedAttributes), for: .normal)
            buttonTakeOut.setAttributedTitle(NSAttributedString(string: "포장", attributes: deselectedAttributes), for: .normal)
        case (true, false):
            buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: selectedAttributes), for: .normal)
            buttonTakeOut.setAttributedTitle(NSAttributedString(string: "포장", attributes: disabledAtrributes), for: .normal)
        case (false, true):
            buttonDelivery.setAttributedTitle(NSAttributedString(string: "배달", attributes: disabledAtrributes), for: .normal)
            buttonTakeOut.setAttributedTitle(NSAttributedString(string: "포장", attributes: selectedAttributes), for: .normal)
        default:
            return // 장바구니가 비어있음
        }
    }
    
    private func setUpLayouts() {
        [selectedBackgroundView, buttonDelivery, buttonTakeOut].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        buttonDelivery.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalTo(self.snp.centerX).offset(-2)
            $0.top.bottom.equalToSuperview().inset(4)
        }
        buttonTakeOut.snp.makeConstraints {
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
