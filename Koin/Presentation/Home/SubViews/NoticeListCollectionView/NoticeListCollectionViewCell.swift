//
//  NoticeListCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/30/24.
//

import UIKit

final class NoticeListCollectionViewCell: UICollectionViewCell {
    
    private let starImageView = UIImageView().then {
        $0.image = .appImage(asset: .popularStar)
    }

    private let noticeGuideLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 12)
        $0.textColor = .appColor(.bus1)
        $0.text = "지금 인기있는 공지"
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.font = .appFont(.pretendardBold, size: 14)
        $0.textColor = .appColor(.neutral500)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.setLineHeight(lineHeight: 1.3, text: title)
    }
}

extension NoticeListCollectionViewCell {
    private func setUpLayouts() {
        [noticeGuideLabel, titleLabel].forEach {
            contentView.addSubview($0)
        }
        
        addSubview(starImageView)
    }
    
    private func setUpConstraints() {
        starImageView.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        noticeGuideLabel.snp.makeConstraints {
            $0.leading.equalTo(starImageView.snp.trailing).offset(22)
            $0.top.equalTo(starImageView).offset(-15)
            $0.height.equalTo(19)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(noticeGuideLabel.snp.bottom)
            $0.leading.equalTo(noticeGuideLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
    
    private func configureView() {
        contentView.backgroundColor = .appColor(.neutral100)
        contentView.layer.cornerRadius = 8
        self.layer.cornerRadius = 8
        setUpLayouts()
        setUpConstraints()
    }
}

