//
//  MenuSectionFooterView.swift
//  koin
//
//  Created by 김나훈 on 4/11/24.
//


import UIKit

class MenuSectionFooterView: UICollectionReusableView {
    static let identifier = "MenuSectionFooterView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.appColor(.neutral100)
    }
}
