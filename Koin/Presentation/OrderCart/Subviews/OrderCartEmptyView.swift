//
//  OrderCartEmptyView.swift
//  koin
//
//  Created by 홍기정 on 9/28/25.
//

import UIKit
import Combine

final class OrderCartEmptyView: UIView {
    
    // MARK: - Properties
    let addMenuButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Components
    private let cartImageView = UIImageView(image: .appImage(asset: .shoppingCartLarge))
    private let shadowSquareImageView = UIImageView(image: .appImage(asset: .shoppingCartShadowSquare))
    private let shadowOvaleImageView = UIImageView(image: .appImage(asset: .shoppingCartShadowOval))
    
    private let descriptionLabel = UILabel().then {
        $0.text = "장바구니가 비었어요."
        $0.textColor = .appColor(.neutral700)
        $0.font = .appFont(.pretendardSemiBold, size: 14)
    }
    private let addMenuButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("메뉴 추가", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardSemiBold, size: 13),
            .foregroundColor : UIColor.appColor(.neutral500)
        ]))
        configuration.image = .appImage(asset: .addGray)
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 16)
        $0.configuration = configuration
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.cornerRadius = 8
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        $0.layer.masksToBounds = false
    }
    
    // MARK: - Initiailizer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTarget()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OrderCartEmptyView {
    
    private func setAddTarget() {
        addMenuButton.addTarget(self, action: #selector(addMenuButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addMenuButtonTapped() {
        addMenuButtonTappedPublisher.send()
    }
}

extension OrderCartEmptyView {
    
    private func setUpLayout() {
        [shadowOvaleImageView, shadowSquareImageView, cartImageView, descriptionLabel, addMenuButton].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        descriptionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(22)
        }
        addMenuButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
        }
        shadowOvaleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-13)
        }
        shadowSquareImageView.snp.makeConstraints {
            $0.leading.equalTo(shadowOvaleImageView).offset(29.07)
            $0.bottom.equalTo(shadowOvaleImageView).offset(-10.4)
        }
        cartImageView.snp.makeConstraints {
            $0.leading.equalTo(shadowOvaleImageView).offset(26.8)
            $0.bottom.equalTo(shadowOvaleImageView).offset(-20.02)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setUpConstraints()
    }
}
