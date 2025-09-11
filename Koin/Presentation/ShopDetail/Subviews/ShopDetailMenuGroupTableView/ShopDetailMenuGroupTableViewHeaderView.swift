//
//  ShopDetailMenuGroupTableViewHeaderView.swift
//  koin
//
//  Created by 홍기정 on 9/9/25.
//

import UIKit
import SnapKit

final class ShopDetailMenuGroupTableViewHeaderView: UITableViewHeaderFooterView {
    
    private let label = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 20)
        $0.textColor = .appColor(.neutral800)
        $0.contentMode = .center
        $0.textAlignment = .left
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.height.equalTo(32)
            $0.top.bottom.equalToSuperview().inset(12)
            
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(groupName text: String) {
        label.text = text
    }
}
