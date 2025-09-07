//
//  ShopDetailIsAvailableView.swift
//  koin
//
//  Created by 홍기정 on 9/6/25.
//

import UIKit
import SnapKit

class ShopDetailIsAvailableView: UIView {
    
    // MARK: - Components
    let label = UILabel().then {
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 12)
        $0.textColor = UIColor.appColor(.new300)
    }
    
    // MARK: - Initiailzier
    init(){
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - bind
    func bind(text: String) {
        label.text = text
    }
    
    // MARK: - Configure
    private func configureView(){
        backgroundColor = UIColor.appColor(.neutral0)
        layer.cornerRadius = 11.5
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
}
