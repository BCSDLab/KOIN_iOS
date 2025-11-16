//
//  ShopSummaryCustomButton.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit

final class ShopSummaryIntroductionButton: UIButton {
    
    // MARK: - UI Components
    private let leftImageView = UIImageView(image: UIImage.appImage(asset: .speaker))
    private let introductionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    private let rightImageView = UIImageView(image: UIImage.appImage(asset: .newChevronRight)?.withRenderingMode(.alwaysTemplate)).then {
        $0.tintColor = .appColor(.neutral500)
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(introduction: String?) {
        introductionLabel.setLineHeight(lineHeight: 1.6, text: introduction ?? "공지사항")
    }
}

extension ShopSummaryIntroductionButton {

    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 12
        
        [leftImageView, introductionLabel, rightImageView].forEach {
            addSubview($0)
        }
        
        leftImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        introductionLabel.snp.makeConstraints {
            $0.leading.equalTo(leftImageView.snp.trailing).offset(7)
            $0.trailing.equalTo(rightImageView.snp.leading).offset(-7)
            $0.centerY.equalToSuperview().offset(-4)
        }
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}
