//
//  ShopReadyView.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//

import UIKit
import SnapKit

final class ShopReadyView: UIView {
    
    // MARK: - UI Components
    
    private let shopReadyLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.textColor = UIColor.appColor(.neutral0)
    }
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular)).then {
        $0.backgroundColor = .black
        $0.alpha = 0.6
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        self.addSubview(visualEffectView)
        visualEffectView.layer.zPosition = -1
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualEffectView.frame = self.bounds
    }
    
    
    func setShopTitle(text: String) {
        shopReadyLabel.text = "영업을 준비중이에요"
    }
    
}

// MARK: UI Settings

extension ShopReadyView {
    private func setUpLayOuts() {
        [shopReadyLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shopReadyLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
