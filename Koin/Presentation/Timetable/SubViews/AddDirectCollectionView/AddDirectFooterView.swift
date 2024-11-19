//
//  AddDirectFooterView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectFooterView: UICollectionReusableView {
    
    static let identifier = "AddDirectFooterView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddDirectFooterView {
   
}
extension AddDirectFooterView {
    private func setupViews() {
        self.backgroundColor = .systemBackground
        [].forEach {
            self.addSubview($0)
        }
    }
}
