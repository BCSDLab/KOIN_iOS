//
//  HomeTabBarButton.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SnapKit
import UIKit

final class HomeTabBarButton: UIControl {
    
    // MARK: - Layout
    private enum Layout {
        static let imageHeight: CGFloat = 24
        static let titleHeight: CGFloat = 16
        static let topPadding: CGFloat = 12
        static let contentWidth: CGFloat = 35
    }

    // MARK: - UI Components
    private let contentWrapperView = UIView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - Initializer
    init(title: String, imageAsset: ImageAsset) {
        super.init(frame: .zero)
        imageView.image = UIImage.appImage(asset: imageAsset)?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = title
        configureView()
        updateSelection(isSelected: false)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func updateSelection(isSelected: Bool) {
        let color = isSelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral800)
        imageView.tintColor = color
        titleLabel.textColor = color
    }
    
    func updateContentInsets(left: CGFloat, right: CGFloat) {
        contentView.snp.updateConstraints {
            $0.leading.equalToSuperview().offset(left)
            $0.trailing.equalToSuperview().offset(-right)
        }
    }
}

extension HomeTabBarButton {
    private func configureView() {
        setUpLayouts()
        setUpStyles()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        imageView.do {
            $0.contentMode = .scaleAspectFit
        }
        titleLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 10)
            $0.textAlignment = .center
        }
        
        subviews.forEach {
            $0.isUserInteractionEnabled = false
        }
    }
    
    private func setUpLayouts() {
        [imageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
        [contentView].forEach {
            contentWrapperView.addSubview($0)
        }
        [contentWrapperView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints {
            $0.height.equalTo(Layout.imageHeight)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.titleHeight)
            $0.top.equalTo(imageView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topPadding)
            $0.width.equalTo(Layout.contentWidth)
            $0.leading.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(0)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        contentWrapperView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
