//
//  NoticeListCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/30/24.
//

import UIKit

final class NoticeListCollectionViewCell: UICollectionViewCell {
    
    private let fireImageView = UIImageView().then {
        $0.image = .appImage(asset: .fireImage)
        $0.backgroundColor = .white
    }
    
    private let imageBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
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
        [imageBackgroundView, noticeGuideLabel, titleLabel].forEach {
            contentView.addSubview($0)
        }
        
        imageBackgroundView.addSubview(fireImageView)
    }
    
    private func setUpConstraints() {
        imageBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.width.equalTo(45)
            $0.height.equalTo(45)
            $0.centerY.equalToSuperview()
        }
        fireImageView.snp.makeConstraints {
            $0.width.equalTo(33)
            $0.height.equalTo(33)
            $0.centerX.centerY.equalToSuperview()
        }
        
        noticeGuideLabel.snp.makeConstraints {
            $0.leading.equalTo(fireImageView.snp.trailing).offset(22)
            $0.top.equalTo(fireImageView).offset(-15)
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

