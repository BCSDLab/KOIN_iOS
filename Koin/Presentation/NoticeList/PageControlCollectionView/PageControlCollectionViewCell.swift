//
//  PageControlCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import SnapKit
import Then
import UIKit

final class PageControlCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let pageNumberWrappedView = UIView().then {
        $0.layer.cornerRadius = 4
    }
    
    private let pageNumber = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 12)
        $0.textAlignment = .center
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(page: String, isSelected: Bool) {
        pageNumber.text = page
        if isSelected {
            pageNumberWrappedView.backgroundColor = .appColor(.primary500)
            pageNumber.textColor = .appColor(.neutral0)
        }
        else {
            pageNumberWrappedView.backgroundColor = .appColor(.neutral300)
            pageNumber.textColor = .appColor(.neutral600)
        }
    }
}

extension PageControlCollectionViewCell {
    private func setUpLayouts() {
        contentView.addSubview(pageNumberWrappedView)
        pageNumberWrappedView.addSubview(pageNumber)
    }
    
    private func setUpConstraints() {
        pageNumberWrappedView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        pageNumber.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
