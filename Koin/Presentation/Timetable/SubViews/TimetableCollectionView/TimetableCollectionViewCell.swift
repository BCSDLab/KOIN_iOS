//
//  TimetableCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/9/24.
//

import UIKit

final class TimetableCollectionViewCell: UICollectionViewCell {
    
    private let timeLabel = InsetLabel(top: -35, left: 0, bottom: 0, right: 0).then {
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1.0
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .center
    }
    
    private let horizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.spacing = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateBackgroundColor(row: Int, column: Int, color: UIColor) {
           guard row < horizontalStackView.arrangedSubviews.count,
                 let verticalStackView = horizontalStackView.arrangedSubviews[row] as? UIStackView,
                 column < verticalStackView.arrangedSubviews.count else {
               return
           }
           
           // 특정 위치의 배경색 변경
           let targetView = verticalStackView.arrangedSubviews[column]
           targetView.backgroundColor = color
       }
    func configure(text: String) {
        timeLabel.text = text
    }
}

extension TimetableCollectionViewCell {
    private func setUpLayouts() {
        [timeLabel, horizontalStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        timeLabel.snp.makeConstraints { make in
            make.top.leading.height.equalToSuperview()
            make.width.equalTo(18)
        }
        horizontalStackView.snp.makeConstraints { make in
            make.top.trailing.height.equalToSuperview()
            make.leading.equalTo(timeLabel.snp.trailing)
        }
    }
    
    private func setUpStackView() {
        
        for _ in 0..<5 {
            let verticalStackView = UIStackView()
            verticalStackView.axis = .vertical
            verticalStackView.distribution = .fillEqually
            verticalStackView.alignment = .fill 
            verticalStackView.spacing = 0
            for _ in 0..<2 {
                let view = UIView()
                view.layer.borderColor = UIColor.appColor(.neutral300).cgColor
                view.layer.borderWidth = 1.0
                view.snp.makeConstraints { make in
                    make.height.equalTo(35)
                }
                verticalStackView.addArrangedSubview(view)
            }
            horizontalStackView.addArrangedSubview(verticalStackView)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpStackView()
    }
}
