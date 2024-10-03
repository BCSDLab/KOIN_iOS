//
//  CallBenefitCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import UIKit

final class CallBenefitCollectionViewCell: UICollectionViewCell {
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit // 이미지 비율 유지하며 맞춤
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textAlignment = .center // 텍스트 가운데 정렬
    }
    
    // 스택뷰로 이미지와 텍스트를 수평 정렬
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal // 수평 스택
        stackView.alignment = .center // 가운데 정렬
        stackView.spacing = 8 // 아이템 간 간격
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCell(selected: Bool, benefit: Benefit) {
        iconImageView.loadImage(from: selected ? benefit.onImageURL : benefit.offImageURL)
        titleLabel.font = selected ? UIFont.appFont(.pretendardMedium, size: 14) : UIFont.appFont(.pretendardRegular, size: 14)
        titleLabel.textColor = selected ? UIColor.appColor(.primary500) : UIColor.appColor(.neutral500)
        titleLabel.text = benefit.title
        self.backgroundColor = selected ? .systemBackground : UIColor.appColor(.neutral50)
        layer.borderWidth = selected ? 1.0 : 0.0
    }
}

extension CallBenefitCollectionViewCell {
    private func setUpLayouts() {
        contentView.addSubview(stackView) // 스택뷰를 셀에 추가
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView.snp.centerX) // 스택뷰 수평 가운데 정렬
            make.centerY.equalTo(contentView.snp.centerY) // 스택뷰 수직 가운데 정렬
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24) // 아이콘 크기 설정
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = UIColor.appColor(.primary500).cgColor
    }
}
