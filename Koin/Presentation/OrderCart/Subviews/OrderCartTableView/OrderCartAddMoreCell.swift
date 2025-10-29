//
//  OrderCartAddMoreCell.swift
//  koin
//
//  Created by 홍기정 on 9/29/25.
//

import UIKit
import Combine

final class OrderCartAddMoreCell: UITableViewCell {
 
    // MARK: - Properties
    let moveToShopPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Components
    private let insetBackgroundView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.layer.masksToBounds = false
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
    }
    private let button = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("더 담으러 가기", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardSemiBold, size: 15),
            .foregroundColor: UIColor.appColor(.new500)
        ]))
        configuration.image = .appImage(asset: .addGray)?.withTintColor(.appColor(.new500), renderingMode: .alwaysTemplate)
        configuration.imagePadding = 10
        configuration.imagePlacement = .leading
        $0.configuration = configuration
        $0.backgroundColor = .clear
        $0.contentMode = .center
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        addTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OrderCartAddMoreCell {
    
    private func addTargets() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        moveToShopPublisher.send()
    }
}

extension OrderCartAddMoreCell {
    
    private func configureView() {
        backgroundView = nil
        backgroundColor = .clear
        
        [insetBackgroundView, button].forEach {
            contentView.addSubview($0)
        }
        insetBackgroundView.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        button.snp.makeConstraints {
            $0.center.equalTo(insetBackgroundView)
        }
    }
}
