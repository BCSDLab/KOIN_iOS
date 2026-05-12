//
//  LostItemKeywordLeftAlignedCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 5/12/26.
//

import UIKit

final class LostItemKeywordLeftAlignedCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let layoutGuide = UILayoutGuide()
    private let keywordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    private let deleteImageView = UIImageView(image: UIImage.appImage(asset: .lostItemDelete))
    private let addImageView = UIImageView(image: UIImage.appImage(asset: .lostItemAdd))
    
    // MARK: - Initialzier
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(keyword: String, action: LostItemKeywordLeftAlignedCollectionView.Action) {
        keywordLabel.text = keyword
        deleteImageView.isHidden = action != .delete
        addImageView.isHidden = action != .add
    }
}

extension LostItemKeywordLeftAlignedCollectionViewCell {
    
    private func configureView() {
        contentView.backgroundColor = UIColor.appColor(.neutral100)
        contentView.layer.cornerRadius = 17
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [keywordLabel, addImageView, deleteImageView].forEach {
            contentView.addSubview($0)
        }
        [layoutGuide].forEach {
            contentView.addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        keywordLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(layoutGuide)
        }
        [addImageView, deleteImageView].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(18)
                $0.leading.equalTo(keywordLabel.snp.trailing).offset(2)
                $0.centerY.trailing.equalTo(layoutGuide)
            }
        }
        layoutGuide.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
