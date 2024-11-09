//
//  TimetableCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/9/24.
//

import UIKit

final class TimetableCollectionViewCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
       
    }
}

extension TimetableCollectionViewCell {
    private func setUpLayouts() {
        [].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
 
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
