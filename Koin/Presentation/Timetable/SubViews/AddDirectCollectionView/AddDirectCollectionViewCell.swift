//
//  AddDirectCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import UIKit

final class AddDirectCollectionViewCell: UICollectionViewCell {
    
//    private let scheduleView = ClassComponentView(text: "일정명", isPoint: true).then {
//        $0.layer.cornerRadius = 4
//        $0.layer.masksToBounds = true
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        
    }
}

extension AddDirectCollectionViewCell {
    private func setUpLayouts() {
//        [scheduleView].forEach {
//            contentView.addSubview($0)
//        }
    }
    
    private func setUpConstraints() {
//        scheduleView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
