//
//  ShopGuideView.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import UIKit

final class ShopGuideView: UIView {
    
    // MARK: - UI Components
    
    let shopLabel: UILabel = {
        let label = UILabel()
        label.text = "상점 목록"
        label.font = UIFont.appFont(.pretendardRegular, size: 14)
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: UI Settings
extension ShopGuideView {
    private func setUpLayOuts() {
        [shopLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shopLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(19)
            make.leading.equalTo(self.snp.leading).offset(16)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.backgroundColor = UIColor.appColor(.neutral100)
    }
}
