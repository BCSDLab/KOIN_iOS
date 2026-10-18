//
//  DiningOperatingTimeFooterView.swift
//  koin
//
//  Created by 김나훈 on 6/8/24.
//

import UIKit

final class DiningOperatingTimeFooterView: UICollectionReusableView {
    static let identifier = "DiningOperatingTimeFooterView"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.appColor(.neutral400)
    }
    
 
}
