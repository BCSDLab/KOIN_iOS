//
//  KeywordNotiCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/19/24.
//

import UIKit

final class KeywordNotiCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "keywordNotiCollectionViewCell"
    
    private let bellImageView = UIImageView().then {
        $0.image = .appImage(asset: .noticeBell)
    }

    private let cardTitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardBold, size: 13)
        $0.textColor = .appColor(.sub600)
    }
    
    private let cardSubtitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textColor = .appColor(.neutral600)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subTitle: String) {
        cardTitleLabel.setLineHeight(lineHeight: 1.5, text: title)
        cardSubtitleLabel.setLineHeight(lineHeight: 1.5, text: subTitle)
    }
}

extension KeywordNotiCollectionViewCell {
    private func setUpLayouts() {
        [bellImageView, cardTitleLabel, cardSubtitleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        bellImageView.snp.makeConstraints {
            $0.width.height.equalTo(72)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        cardTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalTo(bellImageView)
            
        }
        cardSubtitleLabel.snp.makeConstraints {
            $0.top.equalTo(cardTitleLabel.snp.bottom)
            $0.leading.equalTo(cardTitleLabel)
        }
    }
    
    private func configureView() {
        contentView.backgroundColor = .appColor(.neutral100)
        setUpLayouts()
        setUpConstraints()
    }
}


