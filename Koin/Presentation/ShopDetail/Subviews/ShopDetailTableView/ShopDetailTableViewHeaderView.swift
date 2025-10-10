//
//  ShopDetailTableViewHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import UIKit
import SnapKit

final class ShopDetailTableViewHeaderView: UITableViewHeaderFooterView {
    
    private let label = UILabel().then {
        $0.font = .appFont(.pretendardSemiBold, size: 20)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.height.equalTo(32)
            $0.centerY.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(groupName text: String) {
        label.text = text
    }
}
