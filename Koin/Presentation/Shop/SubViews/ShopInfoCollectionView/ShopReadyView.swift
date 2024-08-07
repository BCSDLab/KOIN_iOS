//
//  ShopReadyView.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//

import UIKit

final class ShopReadyView: UIView {
    
    // MARK: - UI Components
    
    private let shopTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardBold, size: 14)
        label.textColor = UIColor.appColor(.yellow)
        return label
    }()
    
    private let shopReadyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        return label
    }()
    
    private let visualEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        effectView.backgroundColor = UIColor.appColor(.primary900)
        effectView.alpha = 0.6
        return effectView
    }()
    
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
        shopTitleLabel.text = text
        shopReadyLabel.text = text.hasFinalConsonant() ? "은 준비중입니다." : "는 준비중입니다."
    }
    
}

// MARK: UI Settings

extension ShopReadyView {
    private func setUpLayOuts() {
        [shopTitleLabel, shopReadyLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shopTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(16)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        shopReadyLabel.snp.makeConstraints { make in
            make.leading.equalTo(shopTitleLabel.snp.trailing)
            make.centerY.equalTo(shopTitleLabel.snp.centerY)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
  //      self.backgroundColor = UIColor.appColor(.readyGray)
    }
}
